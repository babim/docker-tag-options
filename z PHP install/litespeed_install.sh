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
	# set location down
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	# set litespeed admin
	export LITESPEED_ADMIN=${LITESPEED_ADMIN:-admin}
	export LITESPEED_PASS=${LITESPEED_PASS:-admintest}
	# set ID litespeed run
	export auid=${auid:-33}
	export agid=${agid:-$auid}
	export auser=${auser:-www-data}

# set loop
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
		wget --no-check-certificate -O - $DOWN_URL/supervisor.sh | bash
	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# prepare etc start
	   	 wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
}

echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	export DEBIAN_FRONTEND=noninteractive
	# install repo
		wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash
	# install litespeed
		apt-get install openlitespeed -y
	# set admin password
		setlitespeedadmin
	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
	if [[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION1=56;
	elif [[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION1=70;
	elif [[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION1=71;
	elif [[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION1=72;
	else export PHP_VERSION1=$PHP_VERSION;fi
		apt-get install -y lsphp${PHP_VERSION1}-*
		# create php bin
		if [[ "$PHP_VERSION1" == "56" ]] || [[ "$PHP_VERSION1" == "55" ]] || [[ "$PHP_VERSION1" == "54" ]] || [[ "$PHP_VERSION1" == "53" ]];then
			apt-get install -y lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-common lsphp${PHP_VERSION1}-mysql lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-process lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-mcrypt \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-soap lsphp${PHP_VERSION1}-bcmath
			ln -sf /usr/local/lsws/lsphp${PHP_VERSION1}/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		elif [[ "$PHP_VERSION1" == "70" ]] || [[ "$PHP_VERSION1" == "71" ]] || [[ "$PHP_VERSION1" == "72" ]] || [[ "$PHP_VERSION1" == "73" ]];then
			apt-get install -y lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-mcrypt lsphp${PHP_VERSION1}-bcmath lsphp${PHP_VERSION1}-common \
			lsphp${PHP_VERSION1}-dba lsphp${PHP_VERSION1}-dbg lsphp${PHP_VERSION1}-devel lsphp${PHP_VERSION1}-enchant lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-gmp lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-intl lsphp${PHP_VERSION1}-json lsphp${PHP_VERSION1}-ldap \
			lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-mysqlnd lsphp${PHP_VERSION1}-odbc lsphp${PHP_VERSION1}-opcache \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-pear lsphp${PHP_VERSION1}-pecl-apcu lsphp${PHP_VERSION1}-pecl-apcu-devel \
			lsphp${PHP_VERSION1}-pecl-apcu-panel lsphp${PHP_VERSION1}-pecl-igbinary lsphp${PHP_VERSION1}-pecl-igbinary-devel \
			lsphp${PHP_VERSION1}-pecl-mcrypt lsphp${PHP_VERSION1}-pecl-memcache lsphp${PHP_VERSION1}-pecl-memcached lsphp${PHP_VERSION1}-pecl-msgpack \
			lsphp${PHP_VERSION1}-pecl-msgpack-devel lsphp${PHP_VERSION1}-pecl-redis lsphp${PHP_VERSION1}-pgsql lsphp${PHP_VERSION1}-process \
			lsphp${PHP_VERSION1}-pspell lsphp${PHP_VERSION1}-recode lsphp${PHP_VERSION1}-snmp lsphp${PHP_VERSION1}-soap \
			lsphp${PHP_VERSION1}-tidy lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-xmlrpc lsphp${PHP_VERSION1}-zip
		fi
	fi
	# Build mode
	if [[ "$BUILDMODE" == "on" ]] || [[ "$BUILDMODE" == "ON" ]] || [[ "$BUILDMODE" == "true" ]]; then
		apt-get install -y build-essential rcs libpcre3-dev libexpat1-dev libssl-dev libgeoip-dev libudns-dev zlib1g-dev \
			libxml2 libxml2-dev libpng-dev openssl libcurl4-gnutls-dev libc-client-dev libkrb5-dev libmcrypt-dev
	fi

	# prepare final
	preparefinal
	# clean os
	apt-get purge -y wget curl && \
	apt-get clean && \
	apt-get autoclean && \
	apt-get autoremove -y && \
	rm -rf /build && \
	rm -rf /tmp/* /var/tmp/* && \
	rm -rf /var/lib/apt/lists/*

	# forward request and error logs to docker log collector
	ln -sf /dev/stdout /usr/local/lsws/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/lsws/logs/error.log

elif [[ -f /etc/redhat-release ]]; then
	# install repo
		rpm -ivh http://rpms.litespeedtech.com/centos/litespeed-repo-1.1-1.el7.noarch.rpm
		yum install epel-release -y
	# install litespeed
		yum install -y openlitespeed
	# set admin password
		setlitespeedadmin
	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
	if [[ "$PHP_VERSION" == "5.6" ]];then export PHP_VERSION1=56;
	elif [[ "$PHP_VERSION" == "7.0" ]];then export PHP_VERSION1=70;
	elif [[ "$PHP_VERSION" == "7.1" ]];then export PHP_VERSION1=71;
	elif [[ "$PHP_VERSION" == "7.2" ]];then export PHP_VERSION1=72;
	else export PHP_VERSION1=$PHP_VERSION;fi
		# create php bin
		if [[ "$PHP_VERSION1" == "56" ]] || [[ "$PHP_VERSION1" == "55" ]] || [[ "$PHP_VERSION1" == "54" ]] || [[ "$PHP_VERSION1" == "53" ]];then
			yum install -y lsphp${PHP_VERSION1} lsphp${PHP_VERSION1}-common lsphp${PHP_VERSION1}-mysql lsphp${PHP_VERSION1}-gd \
			lsphp${PHP_VERSION1}-process lsphp${PHP_VERSION1}-mbstring lsphp${PHP_VERSION1}-xml lsphp${PHP_VERSION1}-mcrypt \
			lsphp${PHP_VERSION1}-pdo lsphp${PHP_VERSION1}-imap lsphp${PHP_VERSION1}-soap lsphp${PHP_VERSION1}-bcmath
			ln -sf /usr/local/lsws/lsphp54/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
		elif [[ "$PHP_VERSION1" == "70" ]] || [[ "$PHP_VERSION1" == "71" ]] || [[ "$PHP_VERSION1" == "72" ]] || [[ "$PHP_VERSION1" == "73" ]];then
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
	# Build mode
	if [[ "$BUILDMODE" == "on" ]] || [[ "$BUILDMODE" == "ON" ]] || [[ "$BUILDMODE" == "true" ]]; then
		yum groupinstall -y 'Development Tools'
	fi

	# prepare final
	preparefinal
	# clean os
	yum clean all

	# forward request and error logs to docker log collector
	ln -sf /dev/stdout /usr/local/lsws/logs/access.log \
	&& ln -sf /dev/stderr /usr/local/lsws/logs/error.log

else
    echo "Not support your OS"
    exit
fi