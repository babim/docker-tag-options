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
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Waf%20install"
	
	# update and install dependencies
	apt-get update
	apt-get install -y \
		git build-essential libpcre3 libpcre3-dev libssl-dev libtool autoconf \
		apache2-dev libxml2-dev libcurl4-openssl-dev

	# make modsecurity
	cd /usr/src/
		git clone https://github.com/SpiderLabs/ModSecurity.git /usr/src/modsecurity
	cd /usr/src/modsecurity
		./autogen.sh
		./configure --enable-standalone-module --disable-mlogc
	make

	#add user www-data
	adduser --system --no-create-home --disabled-login --disabled-password --group www-data

	#make nginx
	cd /usr/src/
		wget http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
		tar xvzf nginx-$NGINX_VERSION.tar.gz
	cd ../nginx-$NGINX_VERSION && ./configure \
		--conf-path=/etc/nginx/nginx.conf \
		--user=www-data \
		--group=www-data \
		--add-module=../modsecurity/nginx/modsecurity \
		--error-log-path=/var/log/nginx/error.log \
		--http-client-body-temp-path=/var/lib/nginx/body \
		--http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
		--http-log-path=/var/log/nginx/access.log \
		--http-proxy-temp-path=/var/lib/nginx/proxy \
		--lock-path=/var/lock/nginx.lock \
		--pid-path=/var/run/nginx.pid \
		--with-debug \
		--with-ipv6 \
		--with-http_ssl_module \
		--with-http_ssl_module \
		--with-http_geoip_module \
		--without-http_access_module \
		--without-http_auth_basic_module \
		--without-http_autoindex_module \
		--without-http_empty_gif_module \
		--without-http_fastcgi_module \
		--without-http_referer_module \
		--without-http_memcached_module \
		--without-http_scgi_module \
		--without-http_split_clients_module \
		--without-http_ssi_module \
		--without-http_uwsgi_module \
		--with-http_v2_module
	make
	make install

	# configure env
	ln -s /usr/src/nginx/sbin/nginx /bin/nginx
	cp /usr/src/modsecurity/unicode.mapping /etc/nginx/
	mkdir -p /opt/modsecurity/var/audit/

	# install owasp-modsecurity-crs signature
	git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/src/owasp-modsecurity-crs
		cp -R /usr/src/owasp-modsecurity-crs/rules/ /etc/nginx/conf/
		mv /etc/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf{.example,}
		mv /etc/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf{.example,}

	# clean file
	apt-get purge -y build-essential git
	rm /nginx-$NGINX_VERSION.tar.gz

	# download config files
		mkdir -p /var/lib/nginx/body
		mkdir -p /var/log/supervisor
		mkdir -p /etc/supervisor/conf.d/
	# download nginx conf.d
	FILETEMP=/etc/nginx/sites-available/default
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
	FILETEMP=/etc/nginx/sites-enabled/default
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
	FILETEMP=/etc/nginx/nginx.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/nginx.conf
	FILETEMP=/etc/nginx/sites-enabled/default.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/nginx/sites-enabled/default_modsecurity.conf
	FILETEMP=/etc/nginx/http2-ssl.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx/http2-ssl.conf

	# download nginx modsecurity
	FILETEMP=/etc/nginx/modsec_includes.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/modsecurity/modsec_includes.conf
	FILETEMP=/etc/nginx/modsecurity.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/modsecurity/modsecurity.conf
	FILETEMP=/etc/nginx/crs-setup.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/modsecurity/crs-setup.conf

	# download entrypoint
	FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/modsecurity_start.sh
		chmod 755 $FILETEMP

	# Supervisor
		wget --no-check-certificate -O - $DOWN_URL/supervisor_modsecurity.sh | bash
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