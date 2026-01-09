#!/bin/sh

. "$IPKG_INSTROOT/etc/nikkix/scripts/include.sh"

# since v1.18.0

mixin_rule=$(uci -q get nikkix.mixin.rule); [ -z "$mixin_rule" ] && uci set nikkix.mixin.rule=0

mixin_rule_provider=$(uci -q get nikkix.mixin.rule_provider); [ -z "$mixin_rule_provider" ] && uci set nikkix.mixin.rule_provider=0

# since v1.19.0

mixin_ui_path=$(uci -q get nikkix.mixin.ui_path); [ -z "$mixin_ui_path" ] && uci set nikkix.mixin.ui_path=ui

uci show nikkix | grep -E 'nikkix\.@rule\[[[:digit:]]+\].match=' | sed 's/nikkix.@rule\[\([[:digit:]]\+\)\].match=.*/rename nikkix.@rule[\1].match=matcher/' | uci batch

# since v1.19.1

proxy_fake_ip_ping_hijack=$(uci -q get nikkix.proxy.fake_ip_ping_hijack); [ -z "$proxy_fake_ip_ping_hijack" ] && uci set nikkix.proxy.fake_ip_ping_hijack=0

# since v1.20.0

mixin_api_port=$(uci -q get nikkix.mixin.api_port); [ -n "$mixin_api_port" ] && {
	uci del nikkix.mixin.api_port
	uci set nikkix.mixin.api_listen="[::]:$mixin_api_port"
}

mixin_dns_port=$(uci -q get nikkix.mixin.dns_port); [ -n "$mixin_dns_port" ] && {
	uci del nikkix.mixin.dns_port
	uci set nikkix.mixin.dns_listen="[::]:$mixin_dns_port"
}

# since v1.22.0

proxy_transparent_proxy=$(uci -q get nikkix.proxy.transparent_proxy); [ -n "$proxy_transparent_proxy" ] && {
	uci rename nikkix.proxy.transparent_proxy=enabled
	uci rename nikkix.proxy.tcp_transparent_proxy_mode=tcp_mode
	uci rename nikkix.proxy.udp_transparent_proxy_mode=udp_mode

	uci add nikkix router_access_control
	uci set nikkix.@router_access_control[-1].enabled=1
	proxy_bypass_user=$(uci -q get nikkix.proxy.bypass_user); [ -n "$proxy_bypass_user" ] && {
		for router_access_control_user in $proxy_bypass_user; do
			uci add_list nikkix.@router_access_control[-1].user="$router_access_control_user"
		done
	}
	proxy_bypass_group=$(uci -q get nikkix.proxy.bypass_group); [ -n "$proxy_bypass_group" ] && {
		for router_access_control_group in $proxy_bypass_group; do
			uci add_list nikkix.@router_access_control[-1].group="$router_access_control_group"
		done
	}
	proxy_bypass_cgroup=$(uci -q get nikkix.proxy.bypass_cgroup); [ -n "$proxy_bypass_cgroup" ] && {
		for router_access_control_cgroup in $proxy_bypass_cgroup; do
			uci add_list nikkix.@router_access_control[-1].cgroup="$router_access_control_cgroup"
		done
	}
	uci set nikkix.@router_access_control[-1].proxy=0

	uci add nikkix router_access_control
	uci set nikkix.@router_access_control[-1].enabled=1
	uci set nikkix.@router_access_control[-1].proxy=1

	uci add_list nikkix.proxy.lan_inbound_interface=lan

	proxy_access_control_mode=$(uci -q get nikkix.proxy.access_control_mode)

	[ "$proxy_access_control_mode" != "all" ] && {
		proxy_acl_ip=$(uci -q get nikkix.proxy.acl_ip); [ -n "$proxy_acl_ip" ] && {
			for ip in $proxy_acl_ip; do
				uci add nikkix lan_access_control
				uci set nikkix.@lan_access_control[-1].enabled=1
				uci add_list nikkix.@lan_access_control[-1].ip="$ip"
				[ "$proxy_access_control_mode" = "allow" ] && uci set nikkix.@lan_access_control[-1].proxy=1
				[ "$proxy_access_control_mode" = "block" ] && uci set nikkix.@lan_access_control[-1].proxy=0
			done
		}
		proxy_acl_ip6=$(uci -q get nikkix.proxy.acl_ip6); [ -n "$proxy_acl_ip6" ] && {
			for ip6 in $proxy_acl_ip6; do
				uci add nikkix lan_access_control
				uci set nikkix.@lan_access_control[-1].enabled=1
				uci add_list nikkix.@lan_access_control[-1].ip6="$ip6"
				[ "$proxy_access_control_mode" = "allow" ] && uci set nikkix.@lan_access_control[-1].proxy=1
				[ "$proxy_access_control_mode" = "block" ] && uci set nikkix.@lan_access_control[-1].proxy=0
			done
		}
		proxy_acl_mac=$(uci -q get nikkix.proxy.acl_mac); [ -n "$proxy_acl_mac" ] && {
			for mac in $proxy_acl_mac; do
				uci add nikkix lan_access_control
				uci set nikkix.@lan_access_control[-1].enabled=1
				uci add_list nikkix.@lan_access_control[-1].mac="$mac"
				[ "$proxy_access_control_mode" = "allow" ] && uci set nikkix.@lan_access_control[-1].proxy=1
				[ "$proxy_access_control_mode" = "block" ] && uci set nikkix.@lan_access_control[-1].proxy=0
			done
		}
	}

	[ "$proxy_access_control_mode" != "allow" ] && {
		uci add nikkix lan_access_control
		uci set nikkix.@lan_access_control[-1].enabled=1
		uci set nikkix.@lan_access_control[-1].proxy=1
	}

	uci del nikkix.proxy.access_control_mode
	uci del nikkix.proxy.acl_ip
	uci del nikkix.proxy.acl_ip6
	uci del nikkix.proxy.acl_mac
	uci del nikkix.proxy.acl_interface
	uci del nikkix.proxy.bypass_user
	uci del nikkix.proxy.bypass_group
	uci del nikkix.proxy.bypass_cgroup
}

# since v1.23.0

routing=$(uci -q get nikkix.routing); [ -z "$routing" ] && {
	uci set nikkix.routing=routing
	uci set nikkix.routing.tproxy_fw_mark=0x80
	uci set nikkix.routing.tun_fw_mark=0x81
	uci set nikkix.routing.tproxy_rule_pref=1024
	uci set nikkix.routing.tun_rule_pref=1025
	uci set nikkix.routing.tproxy_route_table=80
	uci set nikkix.routing.tun_route_table=81
	uci set nikkix.routing.cgroup_id=0x12061206
	uci set nikkix.routing.cgroup_name=nikkix
}

proxy_tun_timeout=$(uci -q get nikkix.proxy.tun_timeout); [ -z "$proxy_tun_timeout" ] && uci set nikkix.proxy.tun_timeout=30

proxy_tun_interval=$(uci -q get nikkix.proxy.tun_interval); [ -z "$proxy_tun_interval" ] && uci set nikkix.proxy.tun_interval=1

# since v1.23.1

uci show nikkix | grep -o -E 'nikkix\.@router_access_control\[[[:digit:]]+\]=router_access_control' | cut -d '=' -f 1 | while read -r router_access_control; do
	for router_access_control_cgroup in $(uci -q get "$router_access_control.cgroup"); do
		[ -d "/sys/fs/cgroup/$router_access_control_cgroup" ] && continue
		[ -d "/sys/fs/cgroup/services/$router_access_control_cgroup" ] && {
			uci del_list "$router_access_control.cgroup=$router_access_control_cgroup"
			uci add_list "$router_access_control.cgroup=services/$router_access_control_cgroup"
		}
	done
done

# since v1.23.3

uci show nikkix | grep -o -E 'nikkix\.@router_access_control\[[[:digit:]]+\]=router_access_control' | cut -d '=' -f 1 | while read -r router_access_control; do
	router_access_control_proxy=$(uci -q get "$router_access_control.proxy")
	router_access_control_dns=$(uci -q get "$router_access_control.dns")
	[ -z "$router_access_control_dns" ] && uci set "$router_access_control.dns=$router_access_control_proxy"
done

uci show nikkix | grep -o -E 'nikkix\.@lan_access_control\[[[:digit:]]+\]=lan_access_control' | cut -d '=' -f 1 | while read -r lan_access_control; do
	lan_access_control_proxy=$(uci -q get "$lan_access_control.proxy")
	lan_access_control_dns=$(uci -q get "$lan_access_control.dns")
	[ -z "$lan_access_control_dns" ] && uci set "$lan_access_control.dns=$lan_access_control_proxy"
done

# since v1.24.0

proxy_reserved_ip=$(uci -q get nikkix.proxy.reserved_ip); [ -z "$proxy_reserved_ip" ] && {
	uci add_list nikkix.proxy.reserved_ip=0.0.0.0/8
	uci add_list nikkix.proxy.reserved_ip=10.0.0.0/8
	uci add_list nikkix.proxy.reserved_ip=127.0.0.0/8
	uci add_list nikkix.proxy.reserved_ip=100.64.0.0/10
	uci add_list nikkix.proxy.reserved_ip=169.254.0.0/16
	uci add_list nikkix.proxy.reserved_ip=172.16.0.0/12
	uci add_list nikkix.proxy.reserved_ip=192.168.0.0/16
	uci add_list nikkix.proxy.reserved_ip=224.0.0.0/4
	uci add_list nikkix.proxy.reserved_ip=240.0.0.0/4
}

proxy_reserved_ip6=$(uci -q get nikkix.proxy.reserved_ip6); [ -z "$proxy_reserved_ip6" ] && {
	uci add_list nikkix.proxy.reserved_ip6=::/128
	uci add_list nikkix.proxy.reserved_ip6=::1/128
	uci add_list nikkix.proxy.reserved_ip6=::ffff:0:0/96
	uci add_list nikkix.proxy.reserved_ip6=100::/64
	uci add_list nikkix.proxy.reserved_ip6=64:ff9b::/96
	uci add_list nikkix.proxy.reserved_ip6=2001::/32
	uci add_list nikkix.proxy.reserved_ip6=2001:10::/28
	uci add_list nikkix.proxy.reserved_ip6=2001:20::/28
	uci add_list nikkix.proxy.reserved_ip6=2001:db8::/32
	uci add_list nikkix.proxy.reserved_ip6=2002::/16
	uci add_list nikkix.proxy.reserved_ip6=fc00::/7
	uci add_list nikkix.proxy.reserved_ip6=fe80::/10
	uci add_list nikkix.proxy.reserved_ip6=ff00::/8
}

# since v1.24.3

routing_tproxy_fw_mask=$(uci -q get nikkix.routing.tproxy_fw_mask); [ -z "$routing_tproxy_fw_mask" ] && uci set nikkix.routing.tproxy_fw_mask=0xFF
routing_tun_fw_mask=$(uci -q get nikkix.routing.tun_fw_mask); [ -z "$routing_tun_fw_mask" ] && uci set nikkix.routing.tun_fw_mask=0xFF

procd=$(uci -q get nikkix.procd); [ -z "$procd" ] && {
	uci set nikkix.procd=procd
	uci set nikkix.procd.fast_reload=$(uci -q get nikkix.config.fast_reload)
	uci set nikkix.procd.env_safe_paths=$(uci -q get nikkix.env.safe_paths)
	uci set nikkix.procd.env_disable_loopback_detector=$(uci -q get nikkix.env.disable_loopback_detector)
	uci set nikkix.procd.env_disable_quic_go_gso=$(uci -q get nikkix.env.disable_quic_go_gso)
	uci set nikkix.procd.env_disable_quic_go_ecn=$(uci -q get nikkix.env.disable_quic_go_ecn)
	uci set nikkix.procd.env_skip_system_ipv6_check=$(uci -q get nikkix.env.skip_system_ipv6_check)
	uci del nikkix.config.fast_reload
	uci del nikkix.env
}

# commit
uci commit nikkix

# exit with 0
exit 0
