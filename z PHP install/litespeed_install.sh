#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

echo 'Set environment'
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"

echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	export DEBIAN_FRONTEND=noninteractive
	# install repo
		wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash
	# install litespeed
		apt-get install openlitespeed -y
	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
		apt-get install lsphp${PHP_VERSION}-*
		# create php bin
		if [[ "$PHP_VERSION" == "56" ]];then
			ln -sf /usr/local/lsws/lsphp${PHP_VERSION}/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		fi
	fi

	# Supervisor
		wget --no-check-certificate -O - $DOWN_URL/supervisor.sh | bash
	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# prepare etc start
	   	 wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash

	# clean os
	apt-get purge -y wget curl && \
	apt-get clean && \
	apt-get autoclean && \
	apt-get autoremove -y && \
	rm -rf /build && \
	rm -rf /tmp/* /var/tmp/* && \
	rm -rf /var/lib/apt/lists/*	

elif [[ -f /etc/redhat-release ]]; then
	# install repo
		rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm
	# install litespeed
		yum install -y openlitespeed
	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
	if [[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION=56;fi
	if [[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION=70;fi
	if [[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION=71;fi
	if [[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION=72;fi
		# create php bin
		if [[ "$PHP_VERSION" == "56" ]];then
			yum install -y lsphp${PHP_VERSION} lsphp${PHP_VERSION}-common lsphp${PHP_VERSION}-mysql lsphp${PHP_VERSION}-gd \
			lsphp${PHP_VERSION}-process lsphp${PHP_VERSION}-mbstring lsphp${PHP_VERSION}-xml lsphp${PHP_VERSION}-mcrypt \
			lsphp${PHP_VERSION}-pdo lsphp${PHP_VERSION}-imap lsphp${PHP_VERSION}-soap lsphp${PHP_VERSION}-bcmath
			ln -sf /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		elseif [[ "$PHP_VERSION" == "70" ]] || [[ "$PHP_VERSION" == "71" ]] || [[ "$PHP_VERSION" == "72" ]];then
			yum install -y lsphp${PHP_VERSION} lsphp${PHP_VERSION}-mcrypt lsphp${PHP_VERSION}-bcmath lsphp${PHP_VERSION}-common \
			lsphp${PHP_VERSION}-dba lsphp${PHP_VERSION}-dbg lsphp${PHP_VERSION}-devel lsphp${PHP_VERSION}-enchant lsphp${PHP_VERSION}-gd \
			lsphp${PHP_VERSION}-gmp lsphp${PHP_VERSION}-imap lsphp${PHP_VERSION}-intl lsphp${PHP_VERSION}-json lsphp${PHP_VERSION}-ldap \
			lsphp${PHP_VERSION}-mbstring lsphp${PHP_VERSION}-mysqlnd lsphp${PHP_VERSION}-odbc lsphp${PHP_VERSION}-opcache \
			lsphp${PHP_VERSION}-pdo lsphp${PHP_VERSION}-pear lsphp${PHP_VERSION}-pecl-apcu lsphp${PHP_VERSION}-pecl-apcu-devel \
			lsphp${PHP_VERSION}-pecl-apcu-panel lsphp${PHP_VERSION}-pecl-igbinary lsphp${PHP_VERSION}-pecl-igbinary-devel \
			lsphp${PHP_VERSION}-pecl-mcrypt lsphp${PHP_VERSION}-pecl-memcache lsphp${PHP_VERSION}-pecl-memcached lsphp${PHP_VERSION}-pecl-msgpack \
			lsphp${PHP_VERSION}-pecl-msgpack-devel lsphp${PHP_VERSION}-pecl-redis lsphp${PHP_VERSION}-pgsql lsphp${PHP_VERSION}-process \
			lsphp${PHP_VERSION}-pspell lsphp${PHP_VERSION}-recode lsphp${PHP_VERSION}-snmp lsphp${PHP_VERSION}-soap \
			lsphp${PHP_VERSION}-tidy lsphp${PHP_VERSION}-xml lsphp${PHP_VERSION}-xmlrpc lsphp${PHP_VERSION}-zip
		else
			echo "Not support your PHP version"
	fi

	# Supervisor
		wget --no-check-certificate -O - $DOWN_URL/supervisor.sh | bash
	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# prepare etc start
	   	 wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash

	# clean os
	yum clean all

else
    echo "Not support your OS"
    exit
fi