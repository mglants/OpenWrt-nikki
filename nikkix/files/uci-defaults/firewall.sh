#!/bin/sh

. "$IPKG_INSTROOT/etc/nikkix/scripts/include.sh"

uci -q batch <<-EOF > /dev/null
	del firewall.nikkix
	set firewall.nikkix=include
	set firewall.nikkix.type=script
	set firewall.nikkix.path=$FIREWALL_INCLUDE_SH
	set firewall.nikkix.fw4_compatible=1
	commit firewall
EOF
