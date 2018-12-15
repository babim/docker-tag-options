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
echo 'Check OS'
	# install
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	if [ ! -f "/etc/supervisor/supervisord.conf" ]; then
	apt-get install -y --no-install-recommends supervisor
	fi
elif [[ -f /etc/redhat-release ]]; then
	if [ ! -f "/etc/supervisor/supervisord.conf" ]; then
	yum install -y supervisor
	fi
elif [[ -f /etc/alpine-release ]]; then
	apk add --no-cache supervisor
else
    echo "Not support your OS"
    exit
fi
	# Supervisor config
		[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
		[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
	# download sypervisord config
	FILETEMP=/etc/supervisor/supervisord.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/supervisord.conf
	FILETEMP=/etc/supervisord.conf
		[[ ! -f $FILETEMP ]] || ln -sf $FILETEMP /etc/supervisor/supervisord.conf
	# php
if [[ ! -z "${PHP_VERSION}" ]]; then
	if [[ "$PHP_VERSION" == "56" ]];then export PHP_VERSION1=5.6;
	elif [[ "$PHP_VERSION" == "70" ]];then export PHP_VERSION1=7.0;
	elif [[ "$PHP_VERSION" == "71" ]];then export PHP_VERSION1=7.1;
	elif [[ "$PHP_VERSION" == "72" ]];then export PHP_VERSION1=7.2;
	else export PHP_VERSION1=$PHP_VERSION;fi
	FILETEMP=/etc/supervisor/conf.d/phpfpm-${PHP_VERSION}.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/phpfpm-${PHP_VERSION}.conf
fi
	# apache
if [[ -f "/usr/sbin/apache2ctl" ]]; then
	FILETEMP=/etc/supervisor/conf.d/apache.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/apache.conf
fi
	# nginx
if [[ -f "/usr/sbin/nginx" ]]; then
	FILETEMP=/etc/supervisor/conf.d/nginx.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/nginx.conf
fi
	# litespeed
if [[ -f "/usr/local/lsws/bin/lswsctrl" ]]; then
	FILETEMP=/etc/supervisor/conf.d/litespeed.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/litespeed.conf
fi