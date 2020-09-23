#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# set environment
setenvironment() {
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
		
	# fix value version
		has_equal "$PHP_VERSION" "56" 		&& export PHP_VERSION=5.6;
		has_equal "$PHP_VERSION" "70" 		&& export PHP_VERSION=7.0;
		has_equal "$PHP_VERSION" "71"		&& export PHP_VERSION=7.1;
		has_equal "$PHP_VERSION" "72"		&& export PHP_VERSION=7.2;
		has_equal "$PHP_VERSION" "73"		&& export PHP_VERSION=7.3;

	# add repo php ubuntu
		debian_add_repo ondrej/php
	# install PHP
		check_folder 	/etc/apache2 		&& install_package php$PHP_VERSION libapache2-mod-php$PHP_VERSION
		check_folder	/etc/nginx 		&& install_package php$PHP_VERSION-fpm
		check_file 	/PHPFPM 		&& install_package php$PHP_VERSION-fpm

	# Fix run suck
		create_folder 	/run/php/

	# Supervisor
		run_url $DOWN_URL/supervisor.sh

	# set loop
	phpfinal() {	
		# enable apache mod
			check_folder 		/etc/apache2 	&& a2enmod rewrite headers http2 ssl
		# Fix run suck
			check_folder 		/run/php	|| create_folder /run/php/
		# install composer
			install_php_composer
		# fix shortcut bin
			rm -f 			/etc/alternatives/php
			create_symlink 		/usr/bin/php$PHP_VERSION /etc/alternatives/php
		# install option for webapp (owncloud)
			install_package 	smbclient ffmpeg ghostscript openexr openexr openexr libxml2 gamin
		# install oracle client extension
			run_url $DOWN_URL/oracle_extension.sh
		}
	preparefinal() {
		# download entrypoint
			FILETEMP=/start.sh
				$download_save $FILETEMP $DOWN_URL/start.sh
				set_filefolder_mod 755 $FILETEMP
		# prepare etc start
			run_url $DOWN_URL/prepare_final.sh
		}
	laravelinstall() {
		if check_value_true "$LARAVEL" == "true";then
		# install laravel depend
			install_package 	php-*dom php-*mbstring zip unzip git curl
			install_php_composer
			create_symlink 		/usr/bin/php$PHP_VERSION /etc/alternatives/php
		# install laravel
			cd /etc-start/www 	&& git clone https://github.com/laravel/laravel && \
			cd laravel 		&& composer install && cp .env.example .env
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
			for VARIABLE in /etc/php/*; do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				phpvalue
			fi
			done
		echo "set php-fpm value"
			FILETEMP=fpm/php.ini
			for VARIABLE in /etc/php/*; do
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
			-e "s|^;*\(opcache.max_accelerated_files\) *=.*|\1 = 10000|" \
			-e "s|^;*\(opcache.memory_consumption\) *=.*|\1 = 128|" \
			-e "s|^;*\(opcache.revalidate_freq\) *=.*|\1 = 60|" \
			-e "s|^;*\(opcache.save_comments\) *=.*|\1 = 1|" \
		$VARIABLE/$FILETEMP
		}
	setopcachevalue() {
		# set php value
		echo "set php opcache value"
			FILETEMP=php.ini
			for VARIABLE in /etc/php/*; do
			if check_file "$VARIABLE/$FILETEMP"; then
				opcachevalue
			fi
			done
		# set php value
		echo "set php-fpm opcache value"
			FILETEMP=fpm/php.ini
			for VARIABLE in /etc/php/*; do
			if check_file "$VARIABLE/$FILETEMP"; then
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
			-e "s/^;clear_env = no$/clear_env = no/"		$VARIABLE/$FILETEMP
		if ! check_file "/etc/nginx/nginx.conf"; then
			sed -i -E \
			-e "s/listen =.*/listen = \/var\/run\/php-fpm.sock/g"	$VARIABLE/$FILETEMP
		fi
		}
	setphptweakfpm() {
		# set php value
		echo "set php-fpm tweak value"
			FILETEMP=fpm/pool.d/www.conf
			for VARIABLE in /etc/php/*; do
			if [ -f "$VARIABLE/$FILETEMP" ]; then
				phptweakfpm
			fi
			done
		}
	libreoffice_install() {
		if [[ "$LIBREOFFICE" == "true" ]] || [[ "$LIBREOFFICE" == "True" ]] || [[ "$LIBREOFFICE" == "TRUE" ]];then
			install_package libreoffice
		fi
		}
	fullphpdo() {
		# config
			phpfinal
			laravelinstall
			libreoffice_install
		# tweak
			setphpvalue
			setopcachevalue
			setphptweakfpm
		# final
			preparefinal
		}

	if [[ "$PHP_VERSION" == "5.6" ]];then
		# install PHP
		say "install PHP $PHP_VERSION"
		install_package imagemagick \
			php$PHP_VERSION-json php$PHP_VERSION-gd php$PHP_VERSION-sqlite php$PHP_VERSION-curl php$PHP_VERSION-ldap php$PHP_VERSION-mysql php$PHP_VERSION-pgsql \
			php$PHP_VERSION-imap php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION-zip php$PHP_VERSION-mcrypt php$PHP_VERSION-memcache php$PHP_VERSION-intl \
			php$PHP_VERSION-mbstring php$PHP_VERSION-sqlite3 php$PHP_VERSION-sybase php$PHP_VERSION-bcmath php$PHP_VERSION-soap php$PHP_VERSION-xml \
			php$PHP_VERSION-phpdbg php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-odbc php$PHP_VERSION-interbase php$PHP_VERSION-gmp php$PHP_VERSION-xsl \
			php-memcached php-pear php-xml
		# config
			fullphpdo

	elif [[ "$PHP_VERSION" == "7.0" ]];then
		# install PHP
		say "install PHP $PHP_VERSION"
		install_package imagemagick \
			php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
			php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-mcrypt php$PHP_VERSION-readline php$PHP_VERSION-odbc \
			php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
			php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo

	elif [[ "$PHP_VERSION" == "7.1" ]];then
		# install PHP
		say "install PHP $PHP_VERSION"
		install_package imagemagick \
			php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
			php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-mcrypt php$PHP_VERSION-readline php$PHP_VERSION-odbc \
			php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
			php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo

	elif [[ "$PHP_VERSION" == "7.2" ]];then
		# install PHP
		say "install PHP $PHP_VERSION"
		install_package imagemagick \
			php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
			php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-readline php$PHP_VERSION-odbc \
			php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
			php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo

	elif [[ "$PHP_VERSION" == "7.3" ]];then
		# install PHP
		say "install PHP $PHP_VERSION"
		install_package imagemagick \
			php$PHP_VERSION-cgi php$PHP_VERSION-cli php$PHP_VERSION-phpdbg libphp$PHP_VERSION-embed php$PHP_VERSION-dev php-xdebug sqlite3 \
			php$PHP_VERSION-curl php$PHP_VERSION-gd php$PHP_VERSION-imap php$PHP_VERSION-interbase php$PHP_VERSION-intl php$PHP_VERSION-ldap php$PHP_VERSION-readline php$PHP_VERSION-odbc \
			php$PHP_VERSION-pgsql php$PHP_VERSION-pspell php$PHP_VERSION-recode php$PHP_VERSION-tidy php$PHP_VERSION-xmlrpc php$PHP_VERSION php$PHP_VERSION-json php-all-dev php$PHP_VERSION-sybase \
			php$PHP_VERSION-sqlite3 php$PHP_VERSION-mysql php$PHP_VERSION-opcache php$PHP_VERSION-bz2 php$PHP_VERSION-mbstring php$PHP_VERSION-zip php-apcu php-imagick \
			php-memcached php-pear libsasl2-dev libssl-dev libcurl4-openssl-dev \
			php$PHP_VERSION-gmp php-xml php$PHP_VERSION-xml php$PHP_VERSION-bcmath php$PHP_VERSION-enchant php$PHP_VERSION-soap php$PHP_VERSION-xsl
		# disable libsslcommon2-dev
		# config
			fullphpdo
	fi

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
