#!/bin/sh
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd "$script_dir/.." && pwd)

pkg_name=${PKG_NAME:-luci-app-webdavfs-mounts}
pkg_version=${PKG_VERSION:-0.2}
pkg_release=${PKG_RELEASE:-1}
pkg_arch=${APK_ARCH:-${OPENWRT_PACKAGE_ARCH:-noarch}}
pkg_license=${PKG_LICENSE:-MIT}
pkg_maintainer=${PKG_MAINTAINER:-Janlay Wu}
pkg_description=${PKG_DESCRIPTION:-LuCI support for WebDAVFS mounts}
pkg_depends=${APK_DEPENDS:-${IPK_DEPENDS:-luci-base, curl}}
build_dir=${BUILD_DIR:-$repo_dir/build}

case "$build_dir" in
    /*) ;;
    *) build_dir="$repo_dir/$build_dir" ;;
esac

case "$pkg_release" in
    r*) version="$pkg_version-$pkg_release" ;;
    *) version="$pkg_version-r$pkg_release" ;;
esac

tmp_dir="$build_dir/.tmp-apk"
data_dir="$tmp_dir/data"
script_file="$tmp_dir/post-install"
output="$build_dir/${pkg_name}-${version}.apk"

require_tool() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "missing required tool: $1" >&2
        exit 1
    }
}

require_tool apk
require_tool find
require_tool mkdir
require_tool rm
require_tool tar

rm -rf "$tmp_dir"
mkdir -p "$data_dir" "$build_dir"

if [ -d "$repo_dir/root" ]; then
    (cd "$repo_dir/root" && COPYFILE_DISABLE=1 tar -cf - .) | (cd "$data_dir" && tar -xf -)
fi

if [ -d "$repo_dir/htdocs" ]; then
    mkdir -p "$data_dir/www"
    (cd "$repo_dir/htdocs" && COPYFILE_DISABLE=1 tar -cf - .) | (cd "$data_dir/www" && tar -xf -)
fi

find "$data_dir" -name '.DS_Store' -delete
find "$data_dir" -name '._*' -delete

if [ -f "$data_dir/etc/config/webdav-mounts" ]; then
    mkdir -p "$data_dir/usr/share/$pkg_name/defaults"
    cp "$data_dir/etc/config/webdav-mounts" "$data_dir/usr/share/$pkg_name/defaults/webdav-mounts"
    rm -f "$data_dir/etc/config/webdav-mounts"
fi

mkdir -p "$data_dir/etc/apk/protected_paths.d"
printf '%s\n' '!etc/config/webdav-mounts' > "$data_dir/etc/apk/protected_paths.d/$pkg_name.list"

find "$data_dir" -type d -exec chmod 0755 {} +
find "$data_dir" -type f -exec chmod 0644 {} +

if [ -f "$data_dir/etc/init.d/webdav-mounts" ]; then
    chmod 0755 "$data_dir/etc/init.d/webdav-mounts"
fi

cat > "$script_file" <<'EOF'
#!/bin/sh
set -eu

config=/etc/config/webdav-mounts
default_config=/usr/share/luci-app-webdavfs-mounts/defaults/webdav-mounts

if [ ! -e "$config" ] && [ -f "$default_config" ]; then
    mkdir -p /etc/config
    cp "$default_config" "$config"
    chmod 0600 "$config"
fi
EOF
chmod 0755 "$script_file"

rm -f "$output"

set -- \
    --compat 3.0.0 \
    --files "$data_dir" \
    --script "post-install:$script_file" \
    --output "$output" \
    --info "name:$pkg_name" \
    --info "version:$version" \
    --info "arch:$pkg_arch" \
    --info "description:$pkg_description" \
    --info "license:$pkg_license" \
    --info "maintainer:$pkg_maintainer" \
    --info "origin:$pkg_name"

depends_normalized=
old_ifs=$IFS
IFS=', '
for dep in $pkg_depends; do
    [ -n "$dep" ] || continue
    depends_normalized="${depends_normalized}${depends_normalized:+ }$dep"
done
IFS=$old_ifs

[ -z "$depends_normalized" ] || set -- "$@" --info "depends:$depends_normalized"

apk mkpkg "$@"
rm -rf "$tmp_dir"

printf 'Built %s\n' "$output"
