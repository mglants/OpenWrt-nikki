#!/bin/bash
# https://github.com/openwrt/openwrt/blob/main/include/download.mk

export MAKEFILE="${MAKEFILE:-Makefile}" \
&& cd "$(dirname "$MAKEFILE")" \
&& export MAKEFILE="$(basename "$MAKEFILE")"
export TOPDIR="$1"
export STAGING_DIR_HOST="${TOPDIR}/staging_dir/host"

export PATH="${STAGING_DIR_HOST}/bin:${PATH}"
MKFILE="$(sed -n '1,/^include \$(INCLUDE_DIR)\/package.mk/{s|:=|=|g;s|(|{|g;s|)|}|g;p}' "$MAKEFILE")"

set_value() {
	local val="$(echo "$MKFILE" | $([ -n "$3" ] && echo sed '1!G;h;$!d' || echo cat) | sed -n "${2}p" | sed -n 's|^'"$1"'=\(.*\)|\1|p')"
	eval "export $1=\"$val\""
}

set_value PKG_UPSTREAM_NAME
set_value PKG_NAME
set_value PKG_UPSTREAM_VERSION
set_value PKG_UPSTREAM_GITHASH
set_value PKG_VERSION

set_value PKG_SOURCE_URL '/^PKG_SOURCE_PROTO=git/,/^PKG_SOURCE_URL=/'
[ -n "$PKG_SOURCE_URL" ] || set_value PKG_SOURCE_URL '/^PKG_SOURCE_PROTO=git/,/^PKG_SOURCE_URL=/' 1
set_value PKG_SOURCE_VERSION
set_value PKG_SOURCE_SUBMODULES

set_value PKG_SOURCE_SUBDIR
[ -n "$PKG_SOURCE_SUBDIR" ] || export PKG_SOURCE_SUBDIR="${PKG_NAME}-${PKG_VERSION}"
set_value PKG_SOURCE '/^PKG_SOURCE_PROTO=git/,/^PKG_SOURCE=/'
[ -n "$PKG_SOURCE" ] || set_value PKG_SOURCE '/^PKG_SOURCE_PROTO=git/,/^PKG_SOURCE=/' 1
[ -n "$PKG_SOURCE" ] || export PKG_SOURCE="${PKG_SOURCE_SUBDIR}.tar.zst"



# sub-functions
# define dl_pack
dl_pack() {
	case "${1##*.}" in
		bz2) echo "bzip2 -c > $1";;
		gz) echo "gzip -nc > $1";;
		xz) echo "xz -zc -7e > $1";;
		zst) echo "zstd -T0 --ultra -20 -c > $1";;
		*)
			>&2 echo "ERROR: Unknown pack format for file $1"
			return 1
			;;
	esac
}

# define dl_tar_pack
dl_tar_pack() {
	eval "tar --numeric-owner --owner=0 --group=0 --mode=a-s --sort=name \
		\${TAR_TIMESTAMP:+--mtime=\"\$TAR_TIMESTAMP\"} -c $2 | $(dl_pack $1)"
}

# define DownloadMethod/rawgit
DownloadRawgit() {
	local URL="$PKG_SOURCE_URL" \
		SOURCE_VERSION="$PKG_SOURCE_VERSION" \
		SUBMODULES="$PKG_SOURCE_SUBMODULES" \
		FILE="$PKG_SOURCE" \
		SUBDIR="$PKG_SOURCE_SUBDIR"

    local OPTS="--no-checkout"

	echo "Checking out files from the git repository..."
	umask 022
	rm -rf ${SUBDIR}
	git clone ${OPTS} ${URL} ${SUBDIR}
	(cd ${SUBDIR} && umask 022 && git checkout ${SOURCE_VERSION})
	export TAR_TIMESTAMP=`cd ${SUBDIR} && git log -1 --format='@%ct'`

	echo "Generating formal git archive (apply .gitattributes rules)"
	(cd ${SUBDIR} && git config core.abbrev 8 && git archive --format=tar HEAD --output=../${SUBDIR}.tar.git)
	grep -q '\bskip\b' <<< "${SUBMODULES}" || tar --ignore-failed-read -C ${SUBDIR} -f ${SUBDIR}.tar.git -r .git .gitmodules 2>/dev/null

	rm -rf ${SUBDIR} && mkdir ${SUBDIR}
	tar -C ${SUBDIR} -xf ${SUBDIR}.tar.git
	(cd ${SUBDIR} && { grep -q '\bskip\b' <<< "${SUBMODULES}" || git submodule update --init --recursive -- ${SUBMODULES} && rm -rf .git .gitmodules; })

	echo "Packing checkout..."
	dl_tar_pack ${FILE} ${SUBDIR}
	echo "MIRROR_HASH: $(sha256sum ${FILE})"
	rm -rf ${SUBDIR}.tar.git ${SUBDIR} ${FILE}
}

# Main
DownloadRawgit
echo -ne "Press any key to continue..."
read -n 1 -s -r -t 60
