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

# set loop
# set environment
setenvironment() {
	echo 'Set environment'
	# set location down
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	# set litespeed admin
	export LITESPEED_ADMIN=${LITESPEED_ADMIN:-admin}
	export LITESPEED_PASS=${LITESPEED_PASS:-admintest}
	# set ID litespeed run
	export auid=${auid:-33}
	export agid=${agid:-$auid}
	export auser=${auser:-www-data}
	export aguser=${aguser:-$auser}
}

setlitespeedadmin() {
## Set litespeed admin user
cat <<EOF > keystroke
$LITESPEED_ADMIN
$LITESPEED_PASS
$LITESPEED_PASS
EOF
	/usr/local/lsws/admin/misc/admpass.sh < keystroke
	# remove install files
	rm -f install.bin keystroke
}
preparefinal() {
## Prepare value
	# Supervisor
		run_url $DOWN_URL/supervisor.sh
	# download entrypoint
		FILETEMP=/start.sh
			$download_save $FILETEMP $DOWN_URL/start.sh
			set_filefolder_mod 755 $FILETEMP
	# prepare etc start
	   	 run_url $DOWN_URL/prepare_final.sh
}
install_php() {
if has_value "${PHP_VERSION}" && ! check_value_false "${PHP_VERSION}"; then

	if 	[[ "$PHP_VERSION" == "5.3" ]];then export PHP_VERSION=53;
	elif 	[[ "$PHP_VERSION" == "5.4" ]];then export PHP_VERSION=54;
	elif 	[[ "$PHP_VERSION" == "5.5" ]];then export PHP_VERSION=55;
	elif 	[[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION=56;
	elif 	[[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION=70;
	elif 	[[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION=71;
	elif 	[[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION=72;
	elif 	[[ "$PHP_VERSION" == "7.3" ]];then export PHP_VERSION=73;
	elif 	[[ "$PHP_VERSION" == "7.4" ]];then export PHP_VERSION=74;
	else return $FALSE;fi

	# create php bin
	if [[ "$PHP_VERSION" == "5.3" || "$PHP_VERSION" == "53" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "5.4" || "$PHP_VERSION" == "54" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "5.5" || "$PHP_VERSION" == "55" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "5.6" || "$PHP_VERSION" == "56" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "7.0" || "$PHP_VERSION" == "70" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "7.1" || "$PHP_VERSION" == "71" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "7.2" || "$PHP_VERSION" == "72" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "7.3" || "$PHP_VERSION" == "73" ]]; then
		install_package lsphp${PHP_VERSION}-*
	elif [[ "$PHP_VERSION" == "7.4" || "$PHP_VERSION" == "74" ]]; then
		install_package lsphp${PHP_VERSION}-*
	else
		say "Not support your PHP version"
	fi
fi
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
		installfonts
	# install depend for download key in script litespeed install
		install_package wget
	# install repo
		run_url http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh
	# install litespeed
		install_package openlitespeed
	# set admin password
		setlitespeedadmin
	# install php
		install_php
	# Build mode
	if check_value_true "$BUILDMODE"; then
		install_package build-essential rcs libpcre3-dev libexpat1-dev libssl-dev libgeoip-dev libudns-dev zlib1g-dev \
			libxml2 libxml2-dev libpng-dev openssl libcurl4-gnutls-dev libc-client-dev libkrb5-dev libmcrypt-dev
	fi

	# prepare final
		preparefinal
	# clean os
		clean_os

	# forward request and error logs to docker log collector
	create_symlink /dev/stdout /usr/local/lsws/logs/access.log \
	&& create_symlink /dev/stderr /usr/local/lsws/logs/error.log

elif [[ -f /etc/redhat-release ]]; then
	# install repo
		install_package http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm
		install_epel
		installfonts
	# install litespeed
cat <<EOF > keystroke
$LITESPEED_ADMIN
$LITESPEED_PASS
$LITESPEED_PASS
EOF
		install_package openlitespeed
rm -f keytroke
	# set admin password
		# setlitespeedadmin
	# install php
		install_php
	# Build mode
	if check_value_true "$BUILDMODE"; then
		yum groupinstall -y 'Development Tools'
	fi

	# prepare final
		preparefinal
	# clean os
		clean_os

	# forward request and error logs to docker log collector
	create_symlink /dev/stdout /usr/local/lsws/logs/access.log \
	&& create_symlink /dev/stderr /usr/local/lsws/logs/error.log

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
