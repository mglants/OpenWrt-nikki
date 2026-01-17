include $(TOPDIR)/rules.mk

PKG_NAME:=nikkix
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/MetaCubeX/mihomo.git
PKG_SOURCE_VERSION:=v1.19.19
PKG_MIRROR_HASH:=b8dccfdddabacb81c9aa150a1946a5f3fe06f2b7f62c5c73300283abc107d84e

PKG_LICENSE:=GPL3.0+
PKG_MAINTAINER:=Joseph Mory <morytyann@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_BUILD_TIME:=$(shell date -u -Iseconds)

GO_PKG:=github.com/metacubex/mihomo
GO_PKG_LDFLAGS_X:=$(GO_PKG)/constant.Version=$(PKG_SOURCE_VERSION) $(GO_PKG)/constant.BuildTime=$(PKG_BUILD_TIME)
GO_PKG_TAGS:=with_gvisor

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/nikkix
  SECTION:=net
  CATEGORY:=Network
  TITLE:=A rule based proxy in Go.
  URL:=https://wiki.metacubex.one
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle +curl +yq firewall4 +ip-full +kmod-inet-diag +kmod-nft-socket +kmod-nft-tproxy +kmod-tun
  PROVIDES:=mihomo
endef

define Package/nikkix/description
  A rule based proxy in Go.
endef

define Package/nikkix/conffiles
/etc/config/nikkix
/etc/nikkix/mixin.yaml
endef

define Package/nikkix/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/nikkix
	$(INSTALL_DIR) $(1)/etc/nikkix/ucode
	$(INSTALL_DIR) $(1)/etc/nikkix/scripts
	$(INSTALL_DIR) $(1)/etc/nikkix/nftables
	$(INSTALL_DIR) $(1)/etc/nikkix/profiles
	$(INSTALL_DIR) $(1)/etc/nikkix/subscriptions
	$(INSTALL_DIR) $(1)/etc/nikkix/run
	$(INSTALL_DIR) $(1)/etc/nikkix/run/providers
	$(INSTALL_DIR) $(1)/etc/nikkix/run/providers/rule
	$(INSTALL_DIR) $(1)/etc/nikkix/run/providers/proxy

	$(INSTALL_DATA) $(CURDIR)/files/mixin.yaml $(1)/etc/nikkix/mixin.yaml

	$(INSTALL_BIN) $(CURDIR)/files/ucode/include.uc $(1)/etc/nikkix/ucode/include.uc
	$(INSTALL_BIN) $(CURDIR)/files/ucode/mixin.uc $(1)/etc/nikkix/ucode/mixin.uc
	$(INSTALL_BIN) $(CURDIR)/files/ucode/hijack.ut $(1)/etc/nikkix/ucode/hijack.ut

	$(INSTALL_BIN) $(CURDIR)/files/scripts/include.sh $(1)/etc/nikkix/scripts/include.sh
	$(INSTALL_BIN) $(CURDIR)/files/scripts/firewall_include.sh $(1)/etc/nikkix/scripts/firewall_include.sh
	$(INSTALL_BIN) $(CURDIR)/files/scripts/debug.sh $(1)/etc/nikkix/scripts/debug.sh

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/nikkix.conf $(1)/etc/config/nikkix

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/nikkix.init $(1)/etc/init.d/nikkix

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/firewall.sh $(1)/etc/uci-defaults/99_firewall_nikkix
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/init.sh $(1)/etc/uci-defaults/99_init_nikkix
	$(INSTALL_BIN) $(CURDIR)/files/uci-defaults/migrate.sh $(1)/etc/uci-defaults/99_migrate_nikkix

	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) $(CURDIR)/files/nikkix.upgrade $(1)/lib/upgrade/keep.d/nikkix
endef

define Package/nikkix/postrm
#!/bin/sh
if [ -z $${IPKG_INSTROOT} ]; then
	uci -q batch <<-EOF > /dev/null
		del firewall.nikkix
		commit firewall
	EOF
fi
endef

define Build/Prepare
	$(Build/Prepare/Default)
	$(RM) -r $(PKG_BUILD_DIR)/rules/logic_test
endef

$(eval $(call GoBinPackage,nikkix))
$(eval $(call BuildPackage,nikkix))
