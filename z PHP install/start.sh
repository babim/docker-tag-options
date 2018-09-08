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

if [ -d "/etc-start/nginx" ];then
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

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# set loop
setphpuser() {
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
	sed -i -E \
		-e "/^user = .*/cuser = $auser" \
		-e "/^group = .*/cgroup = $auser" \
	$VARIABLE/fpm/pool.d/www.conf
	fi
	done
fi
fi
}
setapacheuser() {
	#Set apache user
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_USER=$auser
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_GROUP=$auser
}
setnginxuser() {
#Set nginx user
if [ -d "/etc/nginx" ]; then
if [ -z "`ls /etc/nginx`" ]; then 
	if [ -f "/etc/nginx/nginx.conf" ]; then
	sed -i -E \
		-e "/^user  .*/cuser  $auser" \
	/etc/nginx/nginx.conf
	fi
fi
fi
}

 # Set environments
    TIMEZONE=${TIMEZONE:-Asia/Ho_Chi_Minh}
    PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT:-512M}
    MAX_UPLOAD=${MAX_UPLOAD:-520M}
    PHP_MAX_FILE_UPLOAD=${PHP_MAX_FILE_UPLOAD:-200}
    PHP_MAX_POST=${PHP_MAX_POST:-520M}
    MAX_INPUT_TIME=${MAX_INPUT_TIME:-3600}
    MAX_EXECUTION_TIME=${MAX_EXECUTION_TIME:-3600}
    DISPLAYERROR=${DISPLAYERROR:-ON}

phpvalue() {
	sed -i -E \
		-e "s|;*date.timezone =.*|date.timezone = ${TIMEZONE}|i" \
		-e "s|;*memory_limit =.*|memory_limit = ${MAX_UPLOAD}|i" \
		-e "s|;*upload_max_filesize =.*|upload_max_filesize = ${MAX_UPLOAD}|i" \
		-e "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" \
		-e "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" \
		-e "s/max_input_time = 60/max_input_time = ${MAX_INPUT_TIME}/" \
		-e "s/max_execution_time = 30/max_execution_time = ${MAX_EXECUTION_TIME}/" \
		-e "s/error_reporting = .*/error_reporting = E_ALL/" \
		-e "s/display_errors = .*/display_errors = ${DISPLAYERROR}/" \
	$VARIABLE/$FILETEMP
	}

	# set php value
	FILETEMP=php.ini
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/$FILETEMP" ]; then
		phpvalue
	fi
	done

	# set php fpm value
	FILETEMP=fpm/php.ini
	for VARIABLE in /etc/php/*
	do
	if [ -f "$VARIABLE/$FILETEMP" ]; then
		phpvalue
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
	elif [[ "$auid" == "0" ]] || [[ "$aguid" == "0" ]]; then
		echo "run in user root"
		export auser=root
		setapacheuser
		setphpuser
		setnginxuser
	elif id $auid >/dev/null 2>&1; then
	        echo "UID exists. Please change UID"
	else
	if id $auser >/dev/null 2>&1; then
	        echo "user exists"
		# usermod alpine
			#deluser $auser && delgroup $auser
			#addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
		# usermod ubuntu/debian
			usermod -u $auid $auser
			groupmod -g $agid $auser
		setapacheuser
		setphpuser
		setnginxuser
	else
		# create user alpine
		#addgroup -g $agid $auser && adduser -D -H -G $auser -s /bin/false -u $auid $auser
		# create user ubuntu/debian
		groupadd -g $agid $auser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $auser $auser
		setapacheuser
		setphpuser
		setnginxuser
	fi

	fi

# run PHP-fpm
if [ ! -f "/PHPFPM" ]; then 
	if [ -f "/usr/bin/php-fpm5.6" ]; then php-fpm5.6 -D; fi
	if [ -f "/usr/bin/php-fpm7.0" ]; then php-fpm7.0 -D; fi
	if [ -f "/usr/bin/php-fpm7.1" ]; then php-fpm7.1 -D; fi
	if [ -f "/usr/bin/php-fpm7.2" ]; then php-fpm7.2 -D; fi
fi
if [ ! -f "/etc/nginx/nginx.conf" ]; then 
	if [ -f "/usr/bin/php-fpm5.6" ]; then php-fpm5.6; fi
	if [ -f "/usr/bin/php-fpm7.0" ]; then php-fpm7.0; fi
	if [ -f "/usr/bin/php-fpm7.1" ]; then php-fpm7.1; fi
	if [ -f "/usr/bin/php-fpm7.2" ]; then php-fpm7.2; fi
fi

exec "$@"
