#!/bin/sh
set -eu

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd)
repo_dir=$(CDPATH= cd "$script_dir/.." && pwd)

pkg_name=${PKG_NAME:-luci-app-webdavfs-mounts}
pkg_version=${PKG_VERSION:-0.1.0}
pkg_release=${PKG_RELEASE:-1}
pkg_arch=${PKG_ARCH:-all}
pkg_license=${PKG_LICENSE:-MIT}
pkg_maintainer=${PKG_MAINTAINER:-Janlay Wu}
pkg_description=${PKG_DESCRIPTION:-LuCI support for WebDAVFS mounts}
pkg_depends=${IPK_DEPENDS:-luci-base, curl}
build_dir=${BUILD_DIR:-$repo_dir/build}

case "$build_dir" in
    /*) ;;
    *) build_dir="$repo_dir/$build_dir" ;;
esac

case "$pkg_release" in
    r*) version="$pkg_version-$pkg_release" ;;
    *) version="$pkg_version-r$pkg_release" ;;
esac

tmp_dir="$build_dir/.tmp-ipk"
data_dir="$tmp_dir/data"
control_dir="$tmp_dir/control"
ar_dir="$tmp_dir/ar"
output="$build_dir/${pkg_name}_${version}_${pkg_arch}.ipk"

require_tool() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "missing required tool: $1" >&2
        exit 1
    }
}

make_tar_gz() {
    out=$1
    src=$2

    rm -f "$out"
    COPYFILE_DISABLE=1 tar --uid 0 --gid 0 --uname root --gname root -czf "$out" -C "$src" .
}

for tool in ar awk du find mkdir rm tar; do
    require_tool "$tool"
done

rm -rf "$tmp_dir"
mkdir -p "$data_dir" "$control_dir" "$ar_dir" "$build_dir"

if [ -d "$repo_dir/root" ]; then
    (cd "$repo_dir/root" && COPYFILE_DISABLE=1 tar -cf - .) | (cd "$data_dir" && tar -xf -)
fi

if [ -d "$repo_dir/htdocs" ]; then
    mkdir -p "$data_dir/www"
    (cd "$repo_dir/htdocs" && COPYFILE_DISABLE=1 tar -cf - .) | (cd "$data_dir/www" && tar -xf -)
fi

find "$data_dir" -name '.DS_Store' -delete
find "$data_dir" -name '._*' -delete
find "$data_dir" -type d -exec chmod 0755 {} +
find "$data_dir" -type f -exec chmod 0644 {} +

if [ -f "$data_dir/etc/init.d/webdav-mounts" ]; then
    chmod 0755 "$data_dir/etc/init.d/webdav-mounts"
fi

if [ -f "$data_dir/etc/config/webdav-mounts" ]; then
    chmod 0600 "$data_dir/etc/config/webdav-mounts"
fi

installed_size=$(du -sk "$data_dir" | awk '{ print $1 }')

cat > "$control_dir/control" <<EOF
Package: $pkg_name
Version: $version
Depends: $pkg_depends
Source: $pkg_name
Section: luci
Architecture: $pkg_arch
Installed-Size: $installed_size
Maintainer: $pkg_maintainer
License: $pkg_license
Description: $pkg_description
EOF

if [ -f "$data_dir/etc/config/webdav-mounts" ]; then
    printf '%s\n' "/etc/config/webdav-mounts" > "$control_dir/conffiles"
fi

make_tar_gz "$ar_dir/control.tar.gz" "$control_dir"
make_tar_gz "$ar_dir/data.tar.gz" "$data_dir"
printf '2.0\n' > "$ar_dir/debian-binary"

rm -f "$output"
(cd "$ar_dir" && ar -cr "$output" debian-binary control.tar.gz data.tar.gz)
rm -rf "$tmp_dir"

printf 'Built %s\n' "$output"
