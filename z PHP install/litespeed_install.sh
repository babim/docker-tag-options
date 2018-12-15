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
	if [[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION1=56;
	elif [[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION1=70;
	elif [[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION1=71;
	elif [[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION1=72;
	else export PHP_VERSION1=$PHP_VERSION;fi
		apt-get install -y lsphp${PHP_VERSION1}-*
		# create php bin
		if [[ "$PHP_VERSION" == "56" ]];then
			ln -sf /usr/local/lsws/lsphp${PHP_VERSION1}/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
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
	if [[ ! -z "${PHP_VERSION1}" ]]; then
	if [[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION1=56;
	elif [[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION1=70;
	elif [[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION1=71;
	elif [[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION1=72;
	else export PHP_VERSION1=$PHP_VERSION;fi
		# create php bin
		if [[ "$PHP_VERSION" == "56" ]];then
			yum install -y lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-common lsphp${PHP_VERSION1}-mysql lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-process lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-mcrypt \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-soap lsphp${PHP_VERSION1}-bcmath
			ln -sf /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		elif [[ "$PHP_VERSION" == "70" ]] || [[ "$PHP_VERSION" == "71" ]] || [[ "$PHP_VERSION" == "72" ]];then
			yum install -y lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-mcrypt lsphp${PHP_VERSION1}-bcmath lsphp${PHP_VERSION1}-common \
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
			echo "Not support your PHP version"
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
	yum clean all

else
    echo "Not support your OS"
    exit
fi