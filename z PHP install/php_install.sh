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
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	# fix value version
	if [[ "$PHP_VERSION" == "56" ]];then export PHP_VERSION1=5.6;
	elif [[ "$PHP_VERSION" == "70" ]];then export PHP_VERSION1=7.0;
	elif [[ "$PHP_VERSION" == "71" ]];then export PHP_VERSION1=7.1;
	elif [[ "$PHP_VERSION" == "72" ]];then export PHP_VERSION1=7.2;
	else export PHP_VERSION1=$PHP_VERSION;fi

	# add repo php ubuntu
		wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php-repo.sh | bash
	# install PHP
		[[ ! -d /etc/apache2 ]] || apt-get install -y --force-yes php$PHP_VERSION1 libapache2-mod-php$PHP_VERSION1 && \
		[[ ! -d /etc/nginx ]] || apt-get install -y --force-yes php$PHP_VERSION1-fpm && \
		[[ ! -f /PHPFPM ]] || apt-get install -y --force-yes php$PHP_VERSION1-fpm

	# Fix run suck
		mkdir -p /run/php/

	# Supervisor
		wget --no-check-certificate -O - $DOWN_URL/supervisor_php.sh | bash

	# set loop
	phpfinal() {	
		# enable apache mod
			[[ ! -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl
		# Fix run suck
			[[ -d /run/php ]] || mkdir -p /run/php/
		# install composer
			wget -O -S https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
		# fix shortcut bin
			ln -sf /usr/bin/php$PHP_VERSION1 /etc/alternatives/php
		# install option for webapp (owncloud)
			apt-get install -y --force-yes smbclient ffmpeg ghostscript openexr openexr openexr libxml2 gamin
		# install oracle client extension
			wget --no-check-certificate -O - $DOWN_URL/oracle_extension.sh | bash
		}
	preparefinal() {
		# download entrypoint
			FILETEMP=/start.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
			chmod 755 $FILETEMP
		# prepare etc start
			wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
		}
	laravelinstall() {
		if [[ "$LARAVEL" == "true" ]];then
		# install laravel depend
			apt-get install -y --force-yes php-*dom php-*mbstring zip unzip git curl && \
			wget -O -S https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
			ln -sf /usr/bin/php$PHP_VERSION1 /etc/alternatives/php
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

	if [[ "$PHP_VERSION1" == "5.6" ]];then
		# install PHP
		echo "install PHP $PHP_VERSION1"
		apt-get install -y --force-yes imagemagick \
			php$PHP_VERSION1-json php$PHP_VERSION1-gd php$PHP_VERSION1-sqlite php$PHP_VERSION1-curl php$PHP_VERSION1-ldap php$PHP_VERSION1-mysql php$PHP_VERSION1-pgsql \
			php$PHP_VERSION1-imap php$PHP_VERSION1-tidy php$PHP_VERSION1-xmlrpc php$PHP_VERSION1-zip php$PHP_VERSION1-mcrypt php$PHP_VERSION1-memcache php$PHP_VERSION1-intl \
			php$PHP_VERSION1-mbstring php$PHP_VERSION1-sqlite3 php$PHP_VERSION1-sybase php$PHP_VERSION1-bcmath php$PHP_VERSION1-soap php$PHP_VERSION1-xml \
			php$PHP_VERSION1-phpdbg php$PHP_VERSION1-opcache php$PHP_VERSION1-bz2 php$PHP_VERSION1-odbc php$PHP_VERSION1-interbase php$PHP_VERSION1-gmp php$PHP_VERSION1-xsl
		# config
			fullphpdo

	elif [[ "$PHP_VERSION1" == "7.0" ]];then
		# install PHP
		echo "install PHP $PHP_VERSION1"
		apt-get install -y --force-yes imagemagick \
			php$PHP_VERSION1-cgi php$PHP_VERSION1-cli php$PHP_VERSION1-phpdbg libphp$PHP_VERSION1-embed php$PHP_VERSION1-dev php-xdebug sqlite3 \
			php$PHP_VERSION1-curl php$PHP_VERSION1-gd php$PHP_VERSION1-imap php$PHP_VERSION1-interbase php$PHP_VERSION1-intl php$PHP_VERSION1-ldap php$PHP_VERSION1-mcrypt php$PHP_VERSION1-readline php$PHP_VERSION1-odbc \
			php$PHP_VERSION1-pgsql php$PHP_VERSION1-pspell php$PHP_VERSION1-recode php$PHP_VERSION1-tidy php$PHP_VERSION1-xmlrpc php$PHP_VERSION1 php$PHP_VERSION1-json php-all-dev php$PHP_VERSION1-sybase \
			php$PHP_VERSION1-sqlite3 php$PHP_VERSION1-mysql php$PHP_VERSION1-opcache php$PHP_VERSION1-bz2 php$PHP_VERSION1-mbstring php$PHP_VERSION1-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION1-gmp php-xml php$PHP_VERSION1-xml php$PHP_VERSION1-bcmath php$PHP_VERSION1-enchant php$PHP_VERSION1-soap php$PHP_VERSION1-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo

	elif [[ "$PHP_VERSION1" == "7.1" ]];then
		# install PHP
		echo "install PHP $PHP_VERSION1"
		apt-get install -y --force-yes imagemagick \
			php$PHP_VERSION1-cgi php$PHP_VERSION1-cli php$PHP_VERSION1-phpdbg libphp$PHP_VERSION1-embed php$PHP_VERSION1-dev php-xdebug sqlite3 \
			php$PHP_VERSION1-curl php$PHP_VERSION1-gd php$PHP_VERSION1-imap php$PHP_VERSION1-interbase php$PHP_VERSION1-intl php$PHP_VERSION1-ldap php$PHP_VERSION1-mcrypt php$PHP_VERSION1-readline php$PHP_VERSION1-odbc \
			php$PHP_VERSION1-pgsql php$PHP_VERSION1-pspell php$PHP_VERSION1-recode php$PHP_VERSION1-tidy php$PHP_VERSION1-xmlrpc php$PHP_VERSION1 php$PHP_VERSION1-json php-all-dev php$PHP_VERSION1-sybase \
			php$PHP_VERSION1-sqlite3 php$PHP_VERSION1-mysql php$PHP_VERSION1-opcache php$PHP_VERSION1-bz2 php$PHP_VERSION1-mbstring php$PHP_VERSION1-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION1-gmp php-xml php$PHP_VERSION1-xml php$PHP_VERSION1-bcmath php$PHP_VERSION1-enchant php$PHP_VERSION1-soap php$PHP_VERSION1-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo

	elif [[ "$PHP_VERSION1" == "7.2" ]];then
		# install PHP
		echo "install PHP $PHP_VERSION1"
		apt-get install -y --force-yes imagemagick \
			php$PHP_VERSION1-cgi php$PHP_VERSION1-cli php$PHP_VERSION1-phpdbg libphp$PHP_VERSION1-embed php$PHP_VERSION1-dev php-xdebug sqlite3 \
			php$PHP_VERSION1-curl php$PHP_VERSION1-gd php$PHP_VERSION1-imap php$PHP_VERSION1-interbase php$PHP_VERSION1-intl php$PHP_VERSION1-ldap php$PHP_VERSION1-readline php$PHP_VERSION1-odbc \
			php$PHP_VERSION1-pgsql php$PHP_VERSION1-pspell php$PHP_VERSION1-recode php$PHP_VERSION1-tidy php$PHP_VERSION1-xmlrpc php$PHP_VERSION1 php$PHP_VERSION1-json php-all-dev php$PHP_VERSION1-sybase \
			php$PHP_VERSION1-sqlite3 php$PHP_VERSION1-mysql php$PHP_VERSION1-opcache php$PHP_VERSION1-bz2 php$PHP_VERSION1-mbstring php$PHP_VERSION1-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION1-gmp php-xml php$PHP_VERSION1-xml php$PHP_VERSION1-bcmath php$PHP_VERSION1-enchant php$PHP_VERSION1-soap php$PHP_VERSION1-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo
	fi
else
    echo "Not support your OS"
    exit
fi