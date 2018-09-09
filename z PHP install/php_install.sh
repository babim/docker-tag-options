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
	# Set environment
		export DEBIAN_FRONTEND=noninteractive
		DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	# add repo php ubuntu
		wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php-repo.sh | bash
		apt-get update
	# install PHP
		[[ ! -d /etc/apache2 ]] || apt-get install -y --force-yes php$PHP_VERSION libapache2-mod-php$PHP_VERSION && \
		[[ ! -d /etc/nginx ]] || apt-get install -y --force-yes php$PHP_VERSION-fpm && \
		[[ ! -f /PHPFPM ]] || apt-get install -y --force-yes php$PHP_VERSION-fpm
	# set loop
	phpfinal() {	
		# enable apache mod
			[[ ! -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl
		# Fix run suck
			[[ -d /run/php ]] || mkdir -p /run/php/
		# install composer
			wget -O -S https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
		# fix shortcut bin
			ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php
		# install option for webapp (owncloud)
			apt-get install -y --force-yes smbclient ffmpeg ghostscript openexr openexr openexr libxml2 gamin
		# install oracle client extension
			wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/oracle_extension.sh | bash
		}
	preparefinal() {
		# download entrypoint
			FILETEMP=/start.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
			chmod 755 $FILETEMP
		# prepare etc start
			wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
		# remove packages
			apt-get purge wget curl -y
		}
	laravelinstall() {
		if [[ "$LARAVEL" == "true" ]];then
		# install laravel depend
			apt-get install -y php-*dom php-*mbstring zip unzip git curl && \
			wget -O -S https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
			ln -sf /usr/bin/php$PHP_VERSION /etc/alternatives/php
		# install laravel
			cd /etc-start/www && git clone https://github.com/laravel/laravel && \
			cd laravel && composer install && cp .env.example .env
		fi
		}
	phpvalue() {
		sed -i -E \
			-e "s/error_reporting =.*/error_reporting = E_ALL/" \
		$VARIABLE/$FILETEMP
		}
	setphpvalue() {
		# set php value
		echo "set php value"
			FILETEMP=php.ini
			for VARIABLE in /etc/php/*
			do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				phpvalue
			fi
			done
		echo "set php-fpm value"
			FILETEMP=fpm/php.ini
			for VARIABLE in /etc/php/*
			do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				phpvalue
			fi
			done
		}
	opcachevalue() {
		sed -i -E \
			-e "s|^;*\(opcache.enable\) *=.*|\1 = 1|" \
			-e "s|^;*\(opcache.enable_cli\) *=.*|\1 = 1|" \
			-e "s|^;*\(opcache.fast_shutdown\) *=.*|\1 = 1|" \
			-e "s|^;*\(opcache.interned_strings_buffer\) *=.*|\1 = 8|" \
			-e "s|^;*\(opcache.max_accelerated_files\) *=.*|\1 = 4000|" \
			-e "s|^;*\(opcache.memory_consumption\) *=.*|\1 = 128|" \
			-e "s|^;*\(opcache.revalidate_freq\) *=.*|\1 = 60|" \
		$VARIABLE/$FILETEMP
		}
	setopcachevalue() {
		# set php value
		echo "set php opcache value"
			FILETEMP=php.ini
			for VARIABLE in /etc/php/*
			do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				opcachevalue
			fi
			done
		# set php value
		echo "set php-fpm opcache value"
			FILETEMP=fpm/php.ini
			for VARIABLE in /etc/php/*
			do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				opcachevalue
			fi
			done
		}
	phptweakfpm() {
		sed -i -E \
			-e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
			-e "s/pm.max_children = 5/pm.max_children = 4/g" \
			-e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
			-e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
			-e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
			-e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
			-e "s/;listen.mode = 0660/listen.mode = 0666/g" \
			-e "s/^;clear_env = no$/clear_env = no/" \
		$VARIABLE/$FILETEMP
		if [ ! -f "/etc/nginx/nginx.conf" ]; then
			sed -i -E \
			-e "s/listen =.*/listen = \/var\/run\/php-fpm.sock/g" \
		$VARIABLE/$FILETEMP
		fi
		}
	setphptweakfpm() {
		# set php value
		echo "set php-fpm tweak value"
			FILETEMP=fpm/pool.d/www.conf
			for VARIABLE in /etc/php/*
			do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				phptweakfpm
			fi
			done
		}
	cleanos() {
		# clean os
			apt-get purge -y wget curl && \
			apt-get clean && \
  			apt-get autoclean && \
  			apt-get autoremove -y && \
   			rm -rf /build && \
   			rm -rf /tmp/* /var/tmp/* && \
	   		rm -rf /var/lib/apt/lists/*	
		}
	fullphpdo() {
		# config
			phpfinal
			laravelinstall
		# tweak
			setphpvalue
			setopcachevalue
			setphptweakfpm
		# final
			preparefinal
		}

if [[ "$PHP_VERSION" == "5.6" ]];then
	# install PHP
	apt-get install -y --force-yes imagemagick curl \
		php$PHP_VERSION-json php$PHP_VERSION-gd php$PHP_VERSION-sqlite php$PHP_VERSION-curl php$PHP_VERSION-ldap php$PHP_VERSION-mysql php$PHP_VERSION-pgsql \
		php$PHP_VERSION-imap php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION-zip php$PHP_VERSION-mcrypt php$PHP_VERSION-memcache php$PHP_VERSION-intl \
		php$PHP_VERSION-mbstring imagemagick php$PHP_VERSION-sqlite3 php$PHP_VERSION-sybase php$PHP_VERSION-bcmath php$PHP_VERSION-soap php$PHP_VERSION-xml \
		php$PHP_VERSION-phpdbg php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-odbc php$PHP_VERSION-interbase php$PHP_VERSION-gmp php$PHP_VERSION-xsl
	# config
		fullphpdo

elif [[ "$PHP_VERSION" == "7.0" ]];then
	# install PHP
	apt-get install -y --force-yes imagemagick curl \
		php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
		php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-mcrypt php$PHP_VERSION-readline php$PHP_VERSION-odbc \
		php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
		php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
		php-memcached php-pear libsasl2-dev libssl-dev libsslcommon2-dev libcurl4-openssl-dev \
		php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
	# config
		fullphpdo

elif [[ "$PHP_VERSION" == "7.1" ]];then
	# install PHP
	apt-get install -y --force-yes imagemagick curl \
		php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
		php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-mcrypt php$PHP_VERSION-readline php$PHP_VERSION-odbc \
		php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
		php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
		php-memcached php-pear libsasl2-dev libssl-dev libsslcommon2-dev libcurl4-openssl-dev \
		php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
	# config
		fullphpdo

elif [[ "$PHP_VERSION" == "7.2" ]];then
	# install PHP
	apt-get install -y --force-yes imagemagick curl \
		php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
		php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-readline php$PHP_VERSION-odbc \
		php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
		php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
		php-memcached php-pear libsasl2-dev libssl-dev libsslcommon2-dev libcurl4-openssl-dev \
		php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
	# config
		fullphpdo
fi
else
    echo "Not support your OS"
    exit
fi