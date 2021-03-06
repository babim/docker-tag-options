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
		export SOFT=${SOFT:-wrk}
		export UNINSTALL="${DOWNLOAD_TOOL}"
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20benchmark%20install"

installsoft() {
		cd / && git clone https://github.com/wg/${SOFT}.git ${SOFT} && \
		cd ${SOFT} && make && cp ${SOFT} /usr/local/bin && \
		cd / && remove_filefolder /${SOFT}
}
dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		say "download entrypoint.."
	# visible code
		$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
		set_filefolder_mod +x $FILETEMP
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# install depend
		#apk add --no-cache alpine-sdk libgcc openssl-dev git linux-headers
		install_package ${SOFT}
	# install
	#	installsoft		
	# done
		dockerentry
		remove_package
		clean_os
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# Set frontend debian
		debian_cmd_interface
	# install depend
		install_package build-essential libssl-dev git
	# install
		installsoft
	# done
		dockerentry
		remove_package
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# install depend
		yum groupinstall 'Development Tools' -y
		install_package openssl-devel git 
	# install
		installsoft
	# done
		dockerentry
		clean_package
		clean_os
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi