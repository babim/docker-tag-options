#!/bin/bash -e
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

export TERM=xterm

# copy config apache
if [ -d "/etc/apache2" ] && [ -d "/etc-start/apache2" ]; then
if [ -z "`ls /etc/apache2`" ]; then cp -R /etc-start/apache2/* /etc/apache2; fi
fi

# copy config nginx
if [ -d "/etc/nginx" ] && [ -d "/etc-start/nginx" ];then
if [ ! -f "/etc/nginx/nginx.conf" ]; then cp -R -f /etc-start/nginx/* /etc/nginx; fi
fi

# copy default www
if [ -d "/var/www" ] && [ -d "/etc-start/www" ]; then
if [ -z "`ls /var/www`" ]; then
	cp -R /etc-start/www/* /var/www
	chown -R www-data:www-data /var/www
fi
fi

# copy config php
if [ -d "/etc/php" ] && [ -d "/etc-start/php" ]; then
if [ -z "`ls /etc/php`" ]; then 
	cp -R /etc-start/php/* /etc/php
fi
fi

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

setnginxphpvalue() {
#Set nginx user
if [ -z "`ls /etc/nginx`" ]; then 
	if [ -f "/etc/nginx/nginx.conf" ]; then
	sed -i -E \
		-e "/^client_max_body_size  .*/cclient_max_body_size  $PHP_MAX_POST" \
		-e "/^keepalive_timeout  .*/ckeepalive_timeout  $MAX_INPUT_TIME" \
	/etc/nginx/nginx.conf
	fi
fi
}

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

	# set nginx php value
	if [ -d "/etc/nginx" ]; then
		setnginxphpvalue
	fi

# Pass real-ip to logs when behind ELB, etc
if [[ "$REAL_IP_HEADER" == "1" ]] ; then
 sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/sites-available/default.conf
 sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/conf.d/default.conf
 if [ ! -z "$REAL_IP_FROM" ]; then
  sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/conf.d/default.conf
 fi
fi
# Do the same for SSL sites
if [ -f /etc/nginx/sites-available/default-ssl.conf ]; then
 if [[ "$REAL_IP_HEADER" == "1" ]] ; then
  sed -i "s/#real_ip_header X-Forwarded-For;/real_ip_header X-Forwarded-For;/" /etc/nginx/sites-available/default-ssl.conf
  sed -i "s/#set_real_ip_from/set_real_ip_from/" /etc/nginx/conf.d/default-ssl.conf
  if [ ! -z "$REAL_IP_FROM" ]; then
   sed -i "s#172.16.0.0/12#$REAL_IP_FROM#" /etc/nginx/conf.d/default-ssl.conf
  fi
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
	#remove
	if [ "$MODSECURITY" = "false" ] && [ -f /MODSECURITY.check ]; then
		apt-get purge libapache2-mod-security2 -y
		rm -f /MODSECURITY.check
	fi

	# install pagespeed
	if [[ "$PAGESPEED" = "true" ]]; then
		if [ -z "`ls /etc/apache2`" ]; then
			apt-get install -y --force-yes wget
			wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
			dpkg -i mod-pagespeed-stable_current_amd64.deb
			rm -f mod-pagespeed-stable_current_amd64.deb
		else
			echo "Not have Apache2 on this Server"
		fi
	   	touch /PAGESPEED.check
	fi
	#remove
	if [ "$PAGESPEED" = "false" ] && [ -f /PAGESPEED.check ]; then
		apt-get purge *pagespeed* -y
		rm -f /PAGESPEED.check
	fi

exec "$@"
