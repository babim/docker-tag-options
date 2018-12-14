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
	# logstash
	FILETEMP=/etc/supervisor/conf.d/logstash.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/logstash.conf