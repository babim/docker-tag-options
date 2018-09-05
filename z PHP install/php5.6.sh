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
	# add repo php ubuntu
		curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php-repo-ubuntu.sh | bash
		apt-get update
	# install PHP
		export PHP_VERSION=5.6
		[[ ! -d /etc/apache2 ]] || apt-get install -y --force-yes php$PHP_VERSION libapache2-mod-php$PHP_VERSION && \
		[[ ! -d /etc/nginx ]] || apt-get install -y --force-yes php$PHP_VERSION-fpm && \
		[[ ! -f /PHPFPM ]] || apt-get install -y --force-yes php$PHP_VERSION-fpm && \
	    apt-get install -y --force-yes imagemagick curl \
		php$PHP_VERSION-json php$PHP_VERSION-gd php$PHP_VERSION-sqlite php$PHP_VERSION-curl php$PHP_VERSION-ldap php$PHP_VERSION-mysql php$PHP_VERSION-pgsql \
		php$PHP_VERSION-imap php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION-zip php$PHP_VERSION-mcrypt php$PHP_VERSION-memcache php$PHP_VERSION-intl \
		php$PHP_VERSION-mbstring imagemagick php$PHP_VERSION-sqlite3 php$PHP_VERSION-sybase php$PHP_VERSION-bcmath php$PHP_VERSION-soap php$PHP_VERSION-xml \
		php$PHP_VERSION-phpdbg php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-odbc php$PHP_VERSION-interbase php$PHP_VERSION-gmp php$PHP_VERSION-xsl
	# enable apache mod
		[[ ! -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl
	# Fix run suck
		[[ -d /run/php ]] || mkdir -p /run/php/
	# install composer
		curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
	# fix shortcut bin
		ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php
	# install option for webapp (owncloud)
		apt-get install -y --force-yes smbclient ffmpeg ghostscript openexr openexr openexr libxml2 gamin
	# install oracle client extension
		curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/oracle_extension.sh | bash
	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# prepare etc start
		curl -s $DOWN_URL/prepare_final.sh | bash
	# remove packages
		apt-get purge wget curl -y
else
    echo "Not support your OS"
    exit
fi