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

# set MACHINE_TYPE
MACHINE_TYPE=${MACHINE_TYPE:-`uname -m`}
[[ ${MACHINE_TYPE} == 'x86_64' ]] && echo "Your server is x86_64 system" || echo "Your server is x86 system"

setenvironment() {
		export SOFT=${SOFT:-Acunetix}
		export FIXED=${FIXED:-false}
		export MANUAL=${MANUAL:-false}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Acunetix"
}
preparedata() {
	# prepare data start
	echo "Prepare data"
		create_folder /start/
		rsync_folder ${SOFT_HOME}/ /start
		remove_filefolder ${SOFT_HOME}/*
}
downloadentry() {
	# download docker entry
	echo "Download entrypoint"
	FILETEMP=/docker-entrypoint.sh
		if [[ ${MANUAL} == 'false' ]]; then
			$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
		else
			$download_save $FILETEMP $DOWN_URL/${SOFT}_manual.sh
		fi
	set_filefolder_mod +x $FILETEMP
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
    say_err "Not support your OS"
    exit 1
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		debian_cmd_interface
		setenvironment
	# install depend
		install_package libxtst6 libxdamage1 libgtk-3-0 libasound2 libnss3 libxss1 libx11-xcb1 sudo curl bzip2 expect
	# install openvas
		install_package openvas
		install_package openvas && openvas-manage-certs -f -a && openvas-setup
		openvasmd --rebuild
	# install clamav
		install_package clamav clamav-daemon
		echo "TCPSocket 3310" >> /etc/clamav/clamd.conf
		echo "TCPAddr 127.0.0.1" >> /etc/clamav/clamd.conf
	# preparedata
		#preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# set environment
		setenvironment
	# install depend
		install_package libxtst6 libxdamage1 libgtk-3-0 libasound2 libnss3 libxss1 libx11-xcb1 sudo curl bzip2 expect
	# install openvas
		install_package net-tools wget
		wget -q -O - http://www.atomicorp.com/installers/atomic |sh
		install_package openvas && openvas-setup
		openvasmd --rebuild
	# install clamav
		install_epel
		install_package clamd clamav clamav-filesystem clamav-lib clamav-data clamav-update
		echo "TCPSocket 3310" >> /etc/clamav/scan.conf
		echo "TCPAddr 127.0.0.1" >> /etc/clamav/scan.conf
	# preparedata
		#preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi