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
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Netdata%20install"
	# set uninstall app
		export UNINSTALL="libmnl-dev gcc make git autoconf automake"
}
# install symlink
symlinkcreate() {
	create_symlink /dev/stdout /var/log/netdata/access.log
	create_symlink /dev/stdout /var/log/netdata/debug.log
	create_symlink /dev/stderr /var/log/netdata/error.log
}
# install netdata
installnetdata() {
	# fetch netdata
	git clone https://github.com/firehol/netdata.git /netdata.git --depth=1
	cd /netdata.git
	# use the provided installer
	./netdata-installer.sh --dont-wait --dont-start-it
	# remove git
	cd /
	remove_filefolder /netdata.git
	# prepare data
	create_folder /etc-start
	dircopy /etc/netdata /etc-start/
}
# download docker entrypoint
downloadentry() {
	# download docker entry
	FILETEMP=/docker-entrypoint.sh
		$download_save $FILETEMP $DOWN_URL/netdata_start.sh
		set_file_mod +x $FILETEMP
}
# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
	install_package alpine-sdk bash curl zlib-dev util-linux-dev libmnl-dev gcc make git autoconf automake pkgconfig python logrotate
	install_package nodejs ssmtp
	# install netdata
		installnetdata
	# download docker entrypoint
		downloadentry
	# del dev tool
		clean_package
		clean_os
	# symlink access log and error log to stdout/stderr
		symlinkcreate
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		debian_cmd_interface
	# some mirrors have issues, i skipped httpredir in favor of an eu mirror
	echo "deb http://ftp.nl.debian.org/debian/ stretch main" > /etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
	# install dependencies for build
	install_package zlib1g-dev uuid-dev libmnl-dev gcc make curl git autoconf autogen automake pkg-config netcat-openbsd jq
	install_package autoconf-archive lm-sensors nodejs python python-mysqldb python-yaml
	install_package msmtp msmtp-mta apcupsd fping
	# install netdata
		installnetdata
	# symlink access log and error log to stdout/stderr
		symlinkcreate
	# download docker entrypoint
		downloadentry
	# del dev tool
		clean_package
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# set environment
		setenvironment
	# install dependencies for build, need EPEL repo
	yum install -y autoconf automake curl gcc git libmnl-devel libuuid-devel lm_sensors make \
			MySQL-python nc pkgconfig python python-psycopg2 PyYAML zlib-devel
	# install netdata
		installnetdata
	# symlink access log and error log to stdout/stderr
		symlinkcreate
	# download docker entrypoint
		downloadentry
	# del dev tool
		clean_package
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi