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
if [[ -f /etc/lsb-release ]]; then
	export DEBIAN_FRONTEND=noninteractive
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	export nginx=stable
	    echo "deb http://ppa.launchpad.net/nginx/$nginx/ubuntu xenial main" > /etc/apt/sources.list.d/nginx-$nginx.list && \
	    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C && \
	    apt-get update && apt-get install -y --force-yes nginx && \
	    chown -R www-data:www-data /var/lib/nginx && \
	    apt-get purge -y apache*

	# Fix run suck
	    mkdir -p /run/php/

	# create folder    
	[[ -d /var/cache/nginx ]] || mkdir -p /var/cache/nginx && \
	[[ -d /var/log/nginx ]] || mkdir -p /var/log/nginx

	# forward request and error logs to docker log collector
	ln -sf /dev/stdout /var/log/nginx/access.log
	ln -sf /dev/stderr /var/log/nginx/error.log

	# include
	    wget --no-check-certificate -O - $DOWN_URL/nginx_include.sh | bash

	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# prepare etc start
	   	 wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash

	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
		wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php_install.sh | bash
	else
		# clean os
		apt-get purge -y wget curl && \
		apt-get clean && \
  		apt-get autoclean && \
  		apt-get autoremove -y && \
   		rm -rf /build && \
   		rm -rf /tmp/* /var/tmp/* && \
   		rm -rf /var/lib/apt/lists/*	
	fi
else
    echo "Not support your OS"
    exit
fi