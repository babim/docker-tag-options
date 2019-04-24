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

# set environment
setenvironment() {
	DEBIAN_FRONTEND=noninteractive
	NGINX_VERSION=${NGINX_VERSION:-"1.15.3"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Waf%20install"
	export SOFT=modsecurity
}

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		debian_cmd_interface

	# update and install dependencies
	install_package \
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
		$download_save nginx-$NGINX_VERSION.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
		tar_extract nginx-$NGINX_VERSION.tar.gz
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
	create_symlink 	/usr/src/nginx/sbin/nginx /bin/nginx
	dircopy 	/usr/src/modsecurity/unicode.mapping /etc/nginx/
	create_folder 	/opt/modsecurity/var/audit/

	# install owasp-modsecurity-crs signature
	git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/src/owasp-modsecurity-crs
		dircopy /usr/src/owasp-modsecurity-crs/rules/ /etc/nginx/conf/
		mv 	/etc/nginx/conf/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf{.example,}
		mv 	/etc/nginx/conf/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf{.example,}

	# clean file
	remove_package build-essential git
	remove_file /nginx-$NGINX_VERSION.tar.gz

	# download config files
		create_folder 	/var/lib/nginx/body
		create_folder 	/var/log/supervisor
		create_folder 	/etc/supervisor/conf.d/

	# download nginx conf.d
	FILETEMP=/etc/nginx/sites-available/default
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
	FILETEMP=/etc/nginx/sites-enabled/default
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
	FILETEMP=/etc/nginx/nginx.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx/nginx.conf
	FILETEMP=/etc/nginx/sites-enabled/default.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx/sites-enabled/default_modsecurity.conf
	FILETEMP=/etc/nginx/http2-ssl.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx/http2-ssl.conf

	# download nginx modsecurity
	FILETEMP=/etc/nginx/modsec_includes.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/modsecurity/modsec_includes.conf
	FILETEMP=/etc/nginx/modsecurity.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/modsecurity/modsecurity.conf
	FILETEMP=/etc/nginx/crs-setup.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/modsecurity/crs-setup.conf

	# download entrypoint
	FILETEMP=/start.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		$download_save $FILETEMP $DOWN_URL/modsecurity_start.sh
		chmod 755 $FILETEMP

	# Supervisor
		run_url $DOWN_URL/supervisor_modsecurity.sh
	# prepare etc start
	   	run_url $DOWN_URL/prepare_final.sh
	# clean
		remove_download_tool
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi