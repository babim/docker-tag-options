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
	# set version php
	PHP_VERSION=${PHP_VERSION:-false}
}
setlitespeedadmin() {
## Set litespeed admin user
/usr/local/lsws/admin/misc/admpass.sh <<< "$LITESPEED_ADMIN
$LITESPEED_PASS
$LITESPEED_PASS
"
}
preparefinal() {
## Prepare value
	# Supervisor
		run_url $DOWN_URL/supervisor.sh
	# download entrypoint
		FILETEMP=/start.sh
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/start.sh
		set_filefolder_mod 755 $FILETEMP
	# prepare etc start
	   	 run_url $DOWN_URL/prepare_final.sh
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
	# install repo
		run_url http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh
	# install litespeed
		install_package openlitespeed
	# set admin password
		setlitespeedadmin
	# install php
	if has_value "${PHP_VERSION}" && ! check_value_false "${PHP_VERSION}"; then
	if 	[[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION1=56;
	elif 	[[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION1=70;
	elif 	[[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION1=71;
	elif 	[[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION1=72;
	else export PHP_VERSION1=$PHP_VERSION;fi
		install_package lsphp${PHP_VERSION1}-*
		# create php bin
		if [[ "$PHP_VERSION1" == "56" ]] || [[ "$PHP_VERSION1" == "55" ]] || [[ "$PHP_VERSION1" == "54" ]] || [[ "$PHP_VERSION1" == "53" ]];then
			install_package lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-common lsphp${PHP_VERSION1}-mysql lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-process lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-mcrypt \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-soap lsphp${PHP_VERSION1}-bcmath
			create_symlink /usr/local/lsws/lsphp${PHP_VERSION1}/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		elif [[ "$PHP_VERSION1" == "70" ]] || [[ "$PHP_VERSION1" == "71" ]] || [[ "$PHP_VERSION1" == "72" ]] || [[ "$PHP_VERSION1" == "73" ]];then
			install_package lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-mcrypt lsphp${PHP_VERSION1}-bcmath lsphp${PHP_VERSION1}-common \
			lsphp${PHP_VERSION1}-dba lsphp${PHP_VERSION1}-dbg lsphp${PHP_VERSION1}-devel lsphp${PHP_VERSION1}-enchant lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-gmp lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-intl lsphp${PHP_VERSION1}-json lsphp${PHP_VERSION1}-ldap \
			lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-mysqlnd lsphp${PHP_VERSION1}-odbc lsphp${PHP_VERSION1}-opcache \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-pear lsphp${PHP_VERSION1}-pecl-apcu lsphp${PHP_VERSION1}-pecl-apcu-devel \
			lsphp${PHP_VERSION1}-pecl-apcu-panel lsphp${PHP_VERSION1}-pecl-igbinary lsphp${PHP_VERSION1}-pecl-igbinary-devel \
			lsphp${PHP_VERSION1}-pecl-mcrypt lsphp${PHP_VERSION1}-pecl-memcache lsphp${PHP_VERSION1}-pecl-memcached lsphp${PHP_VERSION1}-pecl-msgpack \
			lsphp${PHP_VERSION1}-pecl-msgpack-devel lsphp${PHP_VERSION1}-pecl-redis lsphp${PHP_VERSION1}-pgsql lsphp${PHP_VERSION1}-process \
			lsphp${PHP_VERSION1}-pspell lsphp${PHP_VERSION1}-recode lsphp${PHP_VERSION1}-snmp lsphp${PHP_VERSION1}-soap \
			lsphp${PHP_VERSION1}-tidy lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-xmlrpc lsphp${PHP_VERSION1}-zip
		else
			say "Not support your PHP version"
		fi
	fi
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
	# install litespeed
		install_package openlitespeed
	# set admin password
		setlitespeedadmin
	# install php
	if has_value "${PHP_VERSION}" && ! check_value_false "${PHP_VERSION}"; then
	if 	[[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION1=56;
	elif 	[[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION1=70;
	elif 	[[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION1=71;
	elif 	[[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION1=72;
	else export PHP_VERSION1=$PHP_VERSION;fi
		# create php bin
		if [[ "$PHP_VERSION1" == "56" ]] || [[ "$PHP_VERSION1" == "55" ]] || [[ "$PHP_VERSION1" == "54" ]] || [[ "$PHP_VERSION1" == "53" ]];then
			install_package lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-common lsphp${PHP_VERSION1}-mysql lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-process lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-mcrypt \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-soap lsphp${PHP_VERSION1}-bcmath
			create_symlink /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		elif [[ "$PHP_VERSION1" == "70" ]] || [[ "$PHP_VERSION1" == "71" ]] || [[ "$PHP_VERSION1" == "72" ]] || [[ "$PHP_VERSION1" == "73" ]];then
			install_package lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-mcrypt lsphp${PHP_VERSION1}-bcmath lsphp${PHP_VERSION1}-common \
			lsphp${PHP_VERSION1}-dba lsphp${PHP_VERSION1}-dbg lsphp${PHP_VERSION1}-devel lsphp${PHP_VERSION1}-enchant lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-gmp lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-intl lsphp${PHP_VERSION1}-json lsphp${PHP_VERSION1}-ldap \
			lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-mysqlnd lsphp${PHP_VERSION1}-odbc lsphp${PHP_VERSION1}-opcache \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-pear lsphp${PHP_VERSION1}-pecl-apcu lsphp${PHP_VERSION1}-pecl-apcu-devel \
			lsphp${PHP_VERSION1}-pecl-apcu-panel lsphp${PHP_VERSION1}-pecl-igbinary lsphp${PHP_VERSION1}-pecl-igbinary-devel \
			lsphp${PHP_VERSION1}-pecl-mcrypt lsphp${PHP_VERSION1}-pecl-memcache lsphp${PHP_VERSION1}-pecl-memcached lsphp${PHP_VERSION1}-pecl-msgpack \
			lsphp${PHP_VERSION1}-pecl-msgpack-devel lsphp${PHP_VERSION1}-pecl-redis lsphp${PHP_VERSION1}-pgsql lsphp${PHP_VERSION1}-process \
			lsphp${PHP_VERSION1}-pspell lsphp${PHP_VERSION1}-recode lsphp${PHP_VERSION1}-snmp lsphp${PHP_VERSION1}-soap \
			lsphp${PHP_VERSION1}-tidy lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-xmlrpc lsphp${PHP_VERSION1}-zip
		else
			say "Not support your PHP version"
		fi
	fi
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