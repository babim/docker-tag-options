#!/bin/bash -e
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

export TERM=xterm

if [ -d "/etc-start/apache2" ];then
# copy config apache
if [ -d "/etc/apache2" ]; then
if [ -z "`ls /etc/apache2`" ]; then cp -R /etc-start/apache2/* /etc/apache2; fi
fi
fi

if [ -d "/start/nginx" ];then
# copy config nginx
if [ ! -f "/etc/nginx/nginx.conf" ]; then cp -R -f /etc-start/nginx/* /etc/nginx; fi
fi

# copy default www
if [ -d "/var/www" ]; then
if [ -z "`ls /var/www`" ]; then
	cp -R /etc-start/www/* /var/www
	chown -R www-data:www-data /var/www
fi
fi

# copy config php
if [ -d "/etc/php" ]; then
if [ -z "`ls /etc/php`" ]; then 
	cp -R /etc-start/php/* /etc/php

 # Set environments
    TIMEZONE1=${TIMEZONE:-Asia/Ho_Chi_Minh}
    PHP_MEMORY_LIMIT1=${PHP_MEMORY_LIMIT:-512M}
    MAX_UPLOAD1=${MAX_UPLOAD:-520M}
    PHP_MAX_FILE_UPLOAD1=${PHP_MAX_FILE_UPLOAD:-200}
    PHP_MAX_POST1=${PHP_MAX_POST:-520M}
    MAX_INPUT_TIME1=${MAX_INPUT_TIME:-3600}
    MAX_EXECUTION_TIME1=${MAX_EXECUTION_TIME:-3600}
	
	# set php value
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/php.ini" ]; then
	sed -i -E \
		-e "s|;*date.timezone =.*|date.timezone = ${TIMEZONE1}|i" \
		-e "s|;*memory_limit =.*|memory_limit = ${MAX_UPLOAD1}|i" \
		-e "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD1}|i" \
		-e "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD1}|i" \
		-e "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST1}|i" \
		-e "s/max_input_time = 60/max_input_time = ${MAX_INPUT_TIME1}/" \
		-e "s/max_execution_time = 30/max_execution_time = ${MAX_EXECUTION_TIME1}/" \
		-e "s/error_reporting = .*/error_reporting = E_ALL/" \
		-e "s/display_errors = .*/display_errors = On/" \
	$VARIABLE/php.ini
	fi
	done

	# set opcache
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/php.ini" ]; then
	sed -i -E \
		-e "s|^;*\(opcache.enable\) *=.*|\1 = 1|" \
		-e "s|^;*\(opcache.enable_cli\) *=.*|\1 = 1|" \
		-e "s|^;*\(opcache.fast_shutdown\) *=.*|\1 = 1|" \
		-e "s|^;*\(opcache.interned_strings_buffer\) *=.*|\1 = 8|" \
		-e "s|^;*\(opcache.max_accelerated_files\) *=.*|\1 = 4000|" \
		-e "s|^;*\(opcache.memory_consumption\) *=.*|\1 = 128|" \
		-e "s|^;*\(opcache.revalidate_freq\) *=.*|\1 = 60|" \
	$VARIABLE/php.ini
	fi
	done
fi
fi


# set ID docker run
agid=${agid:-$auid}
auser=${auser:-www-data}

	# set nginx
	if [ -d "/etc/nginx" ]; then
	[[ -d /var/cache/nginx ]] || mkdir -p /var/cache/nginx
	[[ -d /var/log/nginx ]] || mkdir -p /var/log/nginx
	[[ ! -d /var/cache/nginx ]] || chown -R $auser /var/cache/nginx
	[[ ! -d /var/log/nginx ]] || chown -R $auser /var/log/nginx
	fi

if [[ -z "${auid}" ]]; then
  echo "start"
elif [[ "$auid" = "0" ]] || [[ "$aguid" == "0" ]]; then
	echo "run in user root"
	export auser=root
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_USER=$auser
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_GROUP=$auser
	#Set php user
if [ -d "/etc/php" ]; then
if [ -z "`ls /etc/php`" ]; then 
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/fpm/php-fpm.conf" ]; then
	sed -i -E \
		-e "/^user = .*/cuser = $auser" \
		-e "/^group = .*/cgroup = $auser" \
	$VARIABLE/fpm/php-fpm.conf
	fi
	done
fi
fi
elif id $auid >/dev/null 2>&1; then
        echo "UID exists. Please change UID"
else
if id $auser >/dev/null 2>&1; then
        echo "user exists"

	#Set php user
if [ -d "/etc/php" ]; then
if [ -z "`ls /etc/php`" ]; then 
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/fpm/php-fpm.conf" ]; then
	sed -i -E \
		-e "/^user = .*/cuser = $auser" \
		-e "/^group = .*/cgroup = $auser" \
	$VARIABLE/fpm/php-fpm.conf
	fi
	done
fi
fi

	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_USER=$auser
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_GROUP=$auser
	# usermod alpine
		#deluser $auser && delgroup $auser
		#addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
	# usermod ubuntu/debian
		usermod -u $auid $auser
		groupmod -g $agid $auser
else
        echo "user does not exist"
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_USER=$auser
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_GROUP=$auser
	# create user alpine
	#addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
	# create user ubuntu/debian
	groupadd -g $agid $auser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $auser $auser

	#Set php user
if [ -d "/etc/php" ]; then
if [ -z "`ls /etc/php`" ]; then 
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/fpm/php-fpm.conf" ]; then
	sed -i -E \
		-e "/^user = .*/cuser = $auser" \
		-e "/^group = .*/cgroup = $auser" \
	$VARIABLE/fpm/php-fpm.conf
	fi
	done
fi
fi

fi

fi

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# run PHP-fpm
if [ ! -f "/PHPFPM" ]; then 
if [ -f "/usr/bin/php-fpm5.6" ]; then php-fpm5.6 -D; fi
if [ -f "/usr/bin/php-fpm7.0" ]; then php-fpm7.0 -D; fi
if [ -f "/usr/bin/php-fpm7.1" ]; then php-fpm7.1 -D; fi
if [ -f "/usr/bin/php-fpm7.2" ]; then php-fpm7.2 -D; fi
fi

exec "$@"
