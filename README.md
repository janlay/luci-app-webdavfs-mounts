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

Place this directory under an OpenWrt package feed, then select `luci-app-webdavfs-mounts` in menuconfig or build it directly:

```sh
make package/luci-app-webdavfs-mounts/compile V=s
```
