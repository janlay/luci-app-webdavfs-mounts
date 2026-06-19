PKG_NAME?=luci-app-webdavfs-mounts
PKG_VERSION?=0.2
PKG_RELEASE?=1
PKG_LICENSE?=MIT
PKG_MAINTAINER?=Janlay Wu
PKG_ARCH?=all
APK_ARCH?=noarch
LUCI_TITLE?=LuCI support for WebDAVFS mounts
LUCI_DEPENDS?=+curl
IPK_DEPENDS?=luci-base, curl

ifndef TOPDIR

.PHONY: all package apk clean

all: package

package:
	@PKG_NAME='$(PKG_NAME)' \
	PKG_VERSION='$(PKG_VERSION)' \
	PKG_RELEASE='$(PKG_RELEASE)' \
	PKG_LICENSE='$(PKG_LICENSE)' \
	PKG_MAINTAINER='$(PKG_MAINTAINER)' \
	PKG_ARCH='$(PKG_ARCH)' \
	PKG_DESCRIPTION='$(LUCI_TITLE)' \
	IPK_DEPENDS='$(IPK_DEPENDS)' \
	BUILD_DIR='$(CURDIR)/build' \
	./scripts/build-ipk.sh

apk:
	@PKG_NAME='$(PKG_NAME)' \
	PKG_VERSION='$(PKG_VERSION)' \
	PKG_RELEASE='$(PKG_RELEASE)' \
	PKG_LICENSE='$(PKG_LICENSE)' \
	PKG_MAINTAINER='$(PKG_MAINTAINER)' \
	APK_ARCH='$(APK_ARCH)' \
	PKG_DESCRIPTION='$(LUCI_TITLE)' \
	APK_DEPENDS='$(IPK_DEPENDS)' \
	BUILD_DIR='$(CURDIR)/build' \
	./scripts/build-apk.sh

clean:
	rm -rf build

else

PKG_SOURCE_DIR:=$(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/luci-app-webdavfs-mounts
  SECTION:=luci
  CATEGORY:=LuCI
  SUBMENU:=3. Applications
  TITLE:=$(LUCI_TITLE)
  DEPENDS:=+luci-base +curl
  PKGARCH:=$(PKG_ARCH)
endef

define Package/luci-app-webdavfs-mounts/description
$(LUCI_TITLE)
endef

define Build/Prepare
	rm -rf $(PKG_BUILD_DIR)
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(PKG_SOURCE_DIR)/root $(PKG_BUILD_DIR)/
	$(CP) $(PKG_SOURCE_DIR)/htdocs $(PKG_BUILD_DIR)/
endef

define Build/Compile
endef

define Package/luci-app-webdavfs-mounts/install
	$(INSTALL_DIR) $(1)/
	$(CP) $(PKG_BUILD_DIR)/root/* $(1)/
	$(INSTALL_DIR) $(1)/www
	$(CP) $(PKG_BUILD_DIR)/htdocs/* $(1)/www/
	chmod 0755 $(1)/etc/init.d/webdav-mounts
	chmod 0600 $(1)/etc/config/webdav-mounts
endef

define Package/luci-app-webdavfs-mounts/conffiles
/etc/config/webdav-mounts
endef

$(eval $(call BuildPackage,luci-app-webdavfs-mounts))

endif
