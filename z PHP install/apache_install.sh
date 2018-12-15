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
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	MODSECURITY=${MODSECURITY:-false}
	PAGESPEED=${PAGESPEED:-false}
	# add repo apache
		add-apt-repository ppa:ondrej/apache2 -y

	# install apache
		apt-get update && apt-get install apache2 -y --force-yes
	# enable apache mod
	  	[[ ! -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl

	# default config with mod rewrite
	CONFIGMODREWRITE=${CONFIGMODREWRITE:-true}
	if [[ "$CONFIGMODREWRITE" = "true" ]]; then
		# config default site
		FILETEMP=/etc/apache2/sites-available
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		FILETEMP=/etc/apache2/sites-available/000-default.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/apache_config/000-default.conf
		FILETEMP=/etc/apache2/sites-available/default-ssl.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/apache_config/default-ssl.conf
		# config ssl default
		FILETEMP=/etc/apache2/certs
			[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
		FILETEMP=/etc/apache2/certs/example-cert.pem
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/ssl/example-cert.pem
		FILETEMP=/etc/apache2/certs/example-key.pem
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/ssl/example-key.pem
		FILETEMP=/etc/apache2/certs/ca-cert.pem
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/ssl/ca-cert.pem
	fi

	# install modsecurity
	if [[ "$MODSECURITY" = "true" ]]; then
		if [ -z "`ls /etc/apache2`" ]; then
			apt-get install -y --force-yes libapache2-mod-security2
			a2enmod security2
		else
			echo "Not have Apache2 on this Server"
		fi
		touch /MODSECUROTY.check
	fi
	# install pagespeed
	if [[ "$PAGESPEED" = "true" ]]; then
		if [ -z "`ls /etc/apache2`" ]; then
			wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
			dpkg -i mod-pagespeed-stable_current_amd64.deb
			rm -f mod-pagespeed-stable_current_amd64.deb
		else
			echo "Not have Apache2 on this Server"
		fi
	   	touch /PAGESPEED.check
	fi

	# install php
	if [[ ! -z "${PHP_VERSION}" ]]; then
		wget --no-check-certificate -O - $DOWN_URL/php_install.sh | bash
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

else
    echo "Not support your OS"
    exit
fi