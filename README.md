# luci-app-webdavfs-mounts

LuCI management UI and init script for mounting WebDAV endpoints with `mount.webdavfs`.

## Files

- `htdocs/luci-static/resources/view/webdav-mounts.js`: LuCI view.
- `root/etc/init.d/webdav-mounts`: mount control init script.
- `root/etc/config/webdav-mounts`: default UCI config without mount entries.
- `root/usr/share/luci/menu.d/luci-app-webdav-mounts.json`: LuCI menu entry.
- `root/usr/share/rpcd/acl.d/luci-app-webdav-mounts.json`: rpcd ACL.

## Dependencies

- `curl`
- LuCI base runtime
- `/usr/sbin/mount.webdavfs` provided separately from [miquels/webdavfs](https://github.com/miquels/webdavfs).

## Build

Build a standalone `.ipk` into `build/`:

```sh
make
```

Build an OpenWrt 25 `.apk` with `apk mkpkg`:

```sh
make apk
```

This requires apk-tools v3 with `apk mkpkg`; the GitHub Action uses `alpine:3.23` for this lightweight build step.

Push a tag to build GitHub Release packages. Tags use the package version; `v0.2` builds `0.2-r1`, and `v0.2-r2` builds `0.2-r2`. Each release includes `.ipk` and OpenWrt 25 `.apk` packages.

Place this directory under an OpenWrt package feed, then select `luci-app-webdavfs-mounts` in menuconfig or build it directly:

```sh
make package/luci-app-webdavfs-mounts/compile V=s
```
