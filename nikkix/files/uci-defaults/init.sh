#!/bin/sh

. "$IPKG_INSTROOT/etc/nikkix/scripts/include.sh"

# check nikkix.config.init
init=$(uci -q get nikkix.config.init); [ -z "$init" ] && return

# generate random string for api secret and authentication password
random=$(awk 'BEGIN{srand(); printf "%06d", int(rand() * 1000000)}')

# set nikkix.mixin.api_secret
uci set nikkix.mixin.api_secret="$random"

# set nikkix.@authentication[0].password
uci set nikkix.@authentication[0].password="$random"

# remove nikkix.config.init
uci del nikkix.config.init

# commit
uci commit nikkix

# exit with 0
exit 0
