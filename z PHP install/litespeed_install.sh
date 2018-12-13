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
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	export DEBIAN_FRONTEND=noninteractive
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
		wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash
		apt-get install openlitespeed -y
	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# prepare etc start
	   	 wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash

	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
		apt-get install lsphp56-* 
		ln -sf /usr/local/lsws/lsphp56/bin/lsphp /usr/local/lsws/fcgi-bin/lsphp5
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