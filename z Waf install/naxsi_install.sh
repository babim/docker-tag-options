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

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]]; then
	# set environment
	DEBIAN_FRONTEND=noninteractive
	NGINX_VERSION=${NGINX_VERSION:-"1.15.3"}
	NAXSI_VERSION=${NAXSI_VERSION:-"master"}
	ELASTICSEARCH_HOST=${ELASTICSEARCH_HOST:-"elasticsearch"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Waf%20install"
	export SOFT=naxsi
	
	# update and install dependencies
		install_package		    python-pip python-geoip logtail curl \
					    gcc make libpcre3-dev libssl-dev supervisor

	# add user www-data
	adduser --system --no-create-home --disabled-login --disabled-password --group www-data

	# Get nginx and naxsi-ui
	cd /usr/src/
	FILETEMP=nginx-${NGINX_VERSION}.tar.gz
		$download_save $FILETEMP "http://nginx.org/download/${$FILETEMP}"
	FILETEMP=${NAXSI_VERSION}.tar.gz
		$download_save $FILETEMP "https://github.com/nbs-system/naxsi/archive/${$FILETEMP}"
	tar_extract nginx-${NGINX_VERSION}.tar.gz && \
	tar_extract ${NAXSI_VERSION}.tar.gz

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
		--with-debug \
		--with-ipv6 \
		--with-http_ssl_module \
		--with-http_geoip_module \
		--without-http_auth_basic_module \
		--without-mail_pop3_module \
		--without-mail_smtp_module \
		--without-mail_imap_module \
		--without-http_uwsgi_module \
		--without-http_scgi_module \
		--with-http_v2_module \
		--prefix=/usr

	# Install nxapi / nxtool
	cd /usr/src/naxsi-${NAXSI_VERSION} && \
	dircopy naxsi_config/naxsi_core.rules /etc/nginx/

	# install nxapi for elasticsearch
	if [[ ! -z "${ELASTICSEARCH_HOST}" ]]; then
		cd nxapi && \
			pip install -r requirements.txt && \
			python setup.py install
	fi

	# download config files
		create_folder /etc/nginx/naxsi-local-rules
		create_folder /var/lib/nginx/body
	# download nginx conf.d
	remove_files /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
	FILETEMP=/etc/nginx/nginx.conf
		$download_save $FILETEMP $DOWN_URL/nginx/nginx.conf
	FILETEMP=/etc/nginx/sites-enabled/default.conf
		$download_save $FILETEMP $DOWN_URL/nginx/sites-enabled/default_naxsi.conf
	FILETEMP=/etc/nginx/http2-ssl.conf
		$download_save $FILETEMP $DOWN_URL/nginx/http2-ssl.conf
	FILETEMP=/etc/nginx/sites-enabled/kibana.conf
		$download_save $FILETEMP $DOWN_URL/nginx/sites-enabled/kibana.conf
	# download naxsi rules
	FILETEMP=/etc/nginx/naxsi.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/dokuwiki.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/dokuwiki.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/drupal.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/drupal.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/etherpad-lite.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/etherpad-lite.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/iris.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/iris.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/rutorrent.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/rutorrent.rules
	FILETEMP=/etc/nginx/naxsi-local-rules/zerobin.rules
		$download_save $FILETEMP $DOWN_URL/nginx/naxsi-local-rules/zerobin.rules
	# download naxsi config
	FILETEMP=/usr/local/etc/nxapi.json
		$download_save $FILETEMP $DOWN_URL/naxsi/nxapi.json

	# download entrypoint
	FILETEMP=/start.sh
		$download_save $FILETEMP $DOWN_URL/naxsi_start.sh
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