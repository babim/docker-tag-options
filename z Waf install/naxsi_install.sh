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
if [[ -f /etc/debian_version ]]; then
	# set environment
	DEBIAN_FRONTEND=noninteractive
	NGINX_VERSION=${NGINX_VERSION:-"1.15.3"}
	NAXSI_VERSION=${NAXSI_VERSION:-"master"}
	ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST:-"elasticsearch"}
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Waf%20install"
	
	# update and install dependencies
		apt-get update
		apt-get install -y --no-install-recommends \
					    python-pip python-geoip logtail curl \
					    gcc make libpcre3-dev libssl-dev supervisor

	# add user www-data
	adduser --system --no-create-home --disabled-login --disabled-password --group www-data

	# Get nginx and naxsi-ui
	cd /usr/src/ && \
		wget "http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz" && \
		wget "https://github.com/nbs-system/naxsi/archive/${NAXSI_VERSION}.tar.gz" && \
	tar zxvf nginx-${NGINX_VERSION}.tar.gz && \
	tar zxvf ${NAXSI_VERSION}.tar.gz

	# Build and install nginx + naxsi
	cd /usr/src/nginx-${NGINX_VERSION} && ./configure \
		--conf-path=/etc/nginx/nginx.conf \
		--user=www-data \
		--group=www-data \
		--add-module=../naxsi-master/naxsi_src/ \
		--error-log-path=/var/log/nginx/error.log \
		--http-client-body-temp-path=/var/lib/nginx/body \
		--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
		--http-log-path=/var/log/nginx/access.log \
		--http-proxy-temp-path=/var/lib/nginx/proxy \
		--lock-path=/var/lock/nginx.lock \
		--pid-path=/var/run/nginx.pid \
		--with-http_ssl_module \
		--with-http_geoip_module \
		--without-mail_pop3_module \
		--without-mail_smtp_module \
		--without-mail_imap_module \
		--without-http_uwsgi_module \
		--without-http_scgi_module \
		--with-http_v2_module \
		--prefix=/usr

	# Install nxapi / nxtool
	cd /usr/src/naxsi-${NAXSI_VERSION} && \
	cp naxsi_config/naxsi_core.rules /etc/nginx/

	# install nxapi for elasticsearch
	if [[ ! -z "${ELASTICSEARCH_HOST}" ]]; then
		cd nxapi && \
			pip install -r requirements.txt && \
			python setup.py install
	fi

	# Supervisor config
		[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
		[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
	# download sypervisord config
	FILETEMP=/etc/supervisor/supervisord.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/supervisord.conf
	FILETEMP=/etc/supervisor/conf.d/nginx.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/nginx.conf
	FILETEMP=/etc/supervisor/conf.d/nxtool.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/nxtool.conf

	# download config files
		mkdir -p /etc/nginx/naxsi-local-rules
		mkdir -p /var/lib/nginx/body
	# download nginx conf.d
	FILETEMP=/etc/nginx/nginx.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/nginx.conf
	FILETEMP=/etc/nginx/conf.d/default.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/conf.d/default_naxsi.conf
	FILETEMP=/etc/nginx/http2-ssl.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx/http2-ssl.conf
	FILETEMP=/etc/nginx/conf.d/kibana.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/conf.d/kibana.conf
	# download naxsi rules
	FILETEMP=/etc/nginx/naxsi.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/dokuwiki.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/dokuwiki.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/drupal.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/drupal.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/etherpad-lite.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/etherpad-lite.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/iris.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/iris.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/rutorrent.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/rutorrent.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/zerobin.rules
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/zerobin.rules
	# download naxsi config
	FILETEMP=/usr/local/etc/nxapi.json
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/naxsi/nxapi.json

	# download entrypoint
	FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/start.sh
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

else
    echo "Not support your OS"
    exit
fi