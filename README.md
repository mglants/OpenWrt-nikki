![GitHub License](https://img.shields.io/github/license/mglants/nikkix?style=for-the-badge&logo=github) ![GitHub Tag](https://img.shields.io/github/v/release/mglants/nikkix?style=for-the-badge&logo=github) ![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/mglants/nikkix/total?style=for-the-badge&logo=github) ![GitHub Repo stars](https://img.shields.io/github/stars/mglants/nikkix?style=for-the-badge&logo=github) [![Telegram](https://img.shields.io/badge/Telegram-gray?style=for-the-badge&logo=telegram)](https://t.me/nikkixnikkix_org)

English | [Русский](README.ru.md)

# Nikkix

Transparent Proxy with Mihomo on OpenWrt.
)

## Fork Notice

This project is a fork of **Nikki**.
Original repository: https://github.com/nikkinikki-org/OpenWrt-nikki

Changes in this fork:

- HWID Support
- Removed Chinese lists
- TPROXY by default

## Prerequisites

- OpenWrt >= 23.05
- Linux Kernel >= 5.13
- firewall4

## Feature

- Transparent Proxy (Redirect/TPROXY/TUN, IPv4 and/or IPv6)
- Access Control
- Profile Mixin
- Profile Editor
- Scheduled Restart
- HWID Support

## Install & Update

### A. Install From Feed (Recommended)

1. Add Feed

```shell
# only needs to be run once
wget -O - https://github.com/mglants/nikkix/raw/refs/heads/main/feed.sh | ash
```

2. Install

```shell
# you can install from shell or `Software` menu in LuCI
# for opkg
opkg install nikkix
opkg install luci-app-nikkix
# for apk
apk add nikkix
apk add luci-app-nikkix
```

### B. Install From Release

```shell
wget -O - https://github.com/mglants/nikkix/raw/refs/heads/main/install.sh | ash
```

## Uninstall & Reset

```shell
wget -O - https://github.com/mglants/nikkix/raw/refs/heads/main/uninstall.sh | ash
```

## How To Use

See [Wiki](https://github.com/mglants/nikkix/wiki)

## How does it work

1. Mixin and Update profile.
2. Run mihomo.
3. Set scheduled restart.
4. Set ip rule/route
5. Generate nftables and apply it.

Note that the steps above may change base on config.

## Compilation

```shell
# add feed
echo "src-git nikkix https://github.com/mglants/nikkix.git;main" >> "feeds.conf.default"
# update & install feeds
./scripts/feeds update -a
./scripts/feeds install -a
# make package
make package/luci-app-nikkix/compile
```

The package files will be found under `bin/packages/your_architecture/nikkix`.

## Dependencies

- ca-bundle
- curl
- yq
- firewall4
- ip-full
- kmod-inet-diag
- kmod-nft-socket
- kmod-nft-tproxy
- kmod-tun

## Contributors

[![Contributors](https://contrib.rocks/image?repo=nikkinikki-org/nikki)](https://github.com/nikkinikki-org/nikki/graphs/contributors)
[![Contributors](https://contrib.rocks/image?repo=mglants/nikkix)](https://github.com/mglants/nikkix/graphs/contributors)

## Special Thanks

- [@ApoisL](https://github.com/apoiston)
- [@xishang0128](https://github.com/xishang0128)

## Recommended Proxy Provider

HWID supported providers is recommended power by
