#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

#####################################
    ####### Set download tool #######
    ####### and load library ########
# check has package
function    machine_has() {
        hash "$1" > /dev/null 2>&1
        return $?; }
# Check and set download tool
echo "Check and set download tool..."
if machine_has "curl"; then
    source <(curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
elif machine_has "wget"; then
    source <(wget -qO- https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
else
    echo "without download tool"
    sleep 3
    exit 1
fi
download_option
#####################################

# need root to run
	require_root

# set environment
setenvironment() {
	export SOFT=${SOFT:-squid}
	export SQUID_USER=${SQUID_USER:-squid}
	export SQUID_CACHE_DIR=${SQUID_CACHE_DIR:-"/var/spool/squid${SQUID_VERSION}"}
	export SQUID_LOG_DIR=${SQUID_LOG_DIR:-"/var/log/squid${SQUID_VERSION}"}
	export SQUID_DIR=${SQUID_DIR:-"/squid"}
	export SQUID_CONFIG_DIR=${SQUID_CONFIG_DIR:-"/etc/squid${SQUID_VERSION}"}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Squid%20install"
}

# set command install
dockerentry() {
	# download docker entry
	FILETEMP=/docker-entrypoint.sh
		remove_file 		$FILETEMP
		$download_save 		$FILETEMP $DOWN_URL/${SOFT}_start.sh
		set_filefolder_mod +x 	$FILETEMP
}
preparedata() {
	# change to one directory
	create_folders ${SQUID_CACHE_DIR} ${SQUID_LOG_DIR} ${SQUID_DIR} ${SQUID_DIR}_start
	create_folders ${SQUID_DIR}_start/cache ${SQUID_DIR}_start/log ${SQUID_DIR}_start/config
	dircopy ${SQUID_CACHE_DIR} ${SQUID_DIR}_start/cache && create_symlink ${SQUID_DIR}/cache ${SQUID_CACHE_DIR}
	dircopy ${SQUID_LOG_DIR} ${SQUID_DIR}_start/log && create_symlink ${SQUID_DIR}/log ${SQUID_LOG_DIR}
	dircopy ${SQUID_CONFIG_DIR} ${SQUID_DIR}_start/config && create_symlink ${SQUID_DIR}/config ${SQUID_CONFIG_DIR}
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install
	#export SQUID_VERSION=
		install_package squid apache2-utils
 	#mv ${SQUID_CONFIG_DIR}/squid.conf ${SQUID_CONFIG_DIR}/squid.conf.dist
		dockerentry
		preparedata
	# clean
		remove_download_tool
		clean_os
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	export SQUID_VERSION=3
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# install depend
		install_packagesquid${SQUID_VERSION} apache2-utils
		dockerentry
		preparedata
	# clean
		remove_download_tool
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    	# set environment
		setenvironment
	#export SQUID_VERSION=3
	# install depend
		install_package squid${SQUID_VERSION} httpd
		dockerentry
		preparedata
	# clean
		remove_download_tool
		clean_os
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi