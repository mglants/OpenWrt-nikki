#!/bin/sh

# Nikkix's uninstaller

# uninstall
if [ -x "/bin/opkg" ]; then
	opkg list-installed luci-i18n-nikkix-* | cut -d ' ' -f 1 | xargs opkg remove
	opkg remove luci-app-nikkix
	opkg remove nikkix
elif [ -x "/usr/bin/apk" ]; then
	apk list --installed --manifest luci-i18n-nikkix-* | cut -d ' ' -f 1 | xargs apk del
	apk del luci-app-nikkix
	apk del nikkix
fi
# remove config
rm -f /etc/config/nikkix
# remove files
rm -rf /etc/nikkix
# remove log
rm -rf /var/log/nikkix
# remove temp
rm -rf /var/run/nikkix
# remove feed
if [ -x "/bin/opkg" ]; then
	if grep -q nikkix /etc/opkg/customfeeds.conf; then
		sed -i '/nikkix/d' /etc/opkg/customfeeds.conf
	fi
	wget -O "nikkix.pub" "https://glantswrt.pages.dev/key-build.pub"
	opkg-key remove nikkix.pub
	rm -f nikkix.pub
elif [ -x "/usr/bin/apk" ]; then
	if grep -q nikkix /etc/apk/repositories.d/customfeeds.list; then
		sed -i '/nikkix/d' /etc/apk/repositories.d/customfeeds.list
	fi
	rm -f /etc/apk/keys/nikkix.pem
fi
