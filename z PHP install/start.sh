#!/bin/bash -e
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

export TERM=xterm

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
				-e "/^group = .*/cgroup = $aguser" \
			$VARIABLE/fpm/php-fpm.conf
			sed -i -E \
				-e "/^user = .*/cuser = $auser" \
				-e "/^group = .*/cgroup = $aguser" \
			$VARIABLE/fpm/pool.d/www.conf
			fi
			done
		fi
	fi
}
setapacheuser() {
	#Set apache user
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_USER=$auser
	[[ ! -d /etc/apache2 ]] || export APACHE_RUN_GROUP=$aguser
}
setnginxuser() {
#Set nginx user
	if [ -d "/etc/nginx" ]; then
		if [ -z "`ls /etc/nginx`" ]; then 
			if [ -f "/etc/nginx/nginx.conf" ]; then
			sed -i -E \
				-e "/^user  .*/cuser  $auser" \
				-e "/^group  .*/group  $aguser" \
			/etc/nginx/nginx.conf
			fi
		fi
	fi
}
setlitespeeduser() {
#Set litespeed user
	if [ -d "/usr/local/lsws" ]; then
		if [ -z "`ls /usr/local/lsws/conf`" ]; then 
			if [ -f "/usr/local/lsws/conf/$i" ]; then
			sed -i -E \
				-e "/^user  .*/cuser  $auser" \

			/usr/local/lsws/conf/$i
			fi
		fi
	fi
# set ID litespeed run
	chown -R $auser:$aguser /usr/local/lsws/autoupdate
	chown -R $auser:$aguser /usr/local/lsws/cachedata
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

# copy config supervisor
if [ -d "/etc/supervisor" ] && [ -d "/etc-start/supervisor" ];then
	if [ ! -f "/etc/supervisor/supervisord.conf" ]; then cp -R -f /etc-start/supervisor/* /etc/supervisor; fi
	    if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ] || [ "$SYNOLOGY" = "true" ] || [ "$SYNOLOGY" = "on" ]; then
	       echo "setup SYNOLOGY environment"
	       chmod -R 777 /etc/supervisor
	    fi
fi

# copy config apache
if [ -d "/etc/apache2" ] && [ -d "/etc-start/apache2" ]; then
	if [ -z "`ls /etc/apache2`" ]; then cp -R /etc-start/apache2/* /etc/apache2; fi
	    if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ] || [ "$SYNOLOGY" = "true" ] || [ "$SYNOLOGY" = "on" ]; then
	       echo "setup SYNOLOGY environment"
	       chmod -R 777 /etc/apache2
	    fi
fi

# copy config nginx
if [ -d "/etc/nginx" ] && [ -d "/etc-start/nginx" ];then
	if [ ! -f "/etc/nginx/nginx.conf" ]; then cp -R -f /etc-start/nginx/* /etc/nginx; fi
	    if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ] || [ "$SYNOLOGY" = "true" ] || [ "$SYNOLOGY" = "on" ]; then
	       echo "setup SYNOLOGY environment"
	       chmod -R 777 /etc/nginx
	    fi
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
		    if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ] || [ "$SYNOLOGY" = "true" ] || [ "$SYNOLOGY" = "on" ]; then
		       echo "setup SYNOLOGY environment"
		       chmod -R 777 /etc/php
		    fi
	fi
fi

# copy default litespeed
if [ -d "/usr/local/lsws" ] && [ -d "/etc-start/lsws" ]; then
	# copy all
	if [ -z "`ls /usr/local/lsws`" ]; then
		cp -R /etc-start/lsws/* /usr/local/lsws
		chmod -R 755 /usr/local/lsws
		chown -R lsadm:lsadm /usr/local/lsws/conf
		chown -R nobody:nogroup /usr/local/lsws/autoupdate
		chown -R nobody:nogroup /usr/local/lsws/cachedata
	    if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ] || [ "$SYNOLOGY" = "true" ] || [ "$SYNOLOGY" = "on" ]; then
	       echo "setup SYNOLOGY environment"
	       chmod -R 777 /usr/local/lsws
	    fi
	else
		# copy just missing
		for i in `ls /etc-start/lsws`; do
			if [ ! -d "/usr/local/lsws/$i" ] && [ -d "/etc-start/lsws/$i" ]; then
			cp -R /etc-start/lsws/$i //usr/local/lsws
			fi
		done
	fi
fi

# set ID docker run
export auid=${auid:-33}
export agid=${agid:-$auid}
export auser=${auser:-www-data}
export aguser=${aguser:-$auser}

	if [[ -z "${auid}" ]] || [[ "$auid" == "33" ]]; then
		echo "start"
	elif [[ "$auid" == "0" ]] || [[ "$aguid" == "0" ]]; then
		echo "run in user root"
		export auser=root
		setapacheuser
		setphpuser
		setnginxuser
		setlitespeeduser
	elif id $auid >/dev/null 2>&1; then
	        echo "UID exists. Please change UID"
	else
		if id $auser >/dev/null 2>&1; then
		        echo "user exists"
			if [[ -f /etc/alpine-release ]]; then
			# usermod alpine
				deluser $auser && delgroup $aguser
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# usermod ubuntu/debian
				usermod -u $auid $auser
				groupmod -g $agid $aguser
			fi
			setapacheuser
			setphpuser
			setnginxuser
			setlitespeeduser
		else
		        echo "create user"
			if [[ -f /etc/alpine-release ]]; then
			# create user alpine
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# create user ubuntu/debian
				groupadd -g $agid $aguser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $aguser $auser
			fi
			setapacheuser
			setphpuser
			setnginxuser
			setlitespeeduser
		fi
	fi

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

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

	# set nginx
	if [ -d "/etc/nginx" ]; then
		[[ -d /var/cache/nginx ]] || mkdir -p /var/cache/nginx
		[[ -d /var/log/nginx ]] || mkdir -p /var/log/nginx
		[[ ! -d /var/cache/nginx ]] || chown -R $auser /var/cache/nginx
		[[ ! -d /var/log/nginx ]] || chown -R $auser /var/log/nginx
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

# run programs
	# apache
if [[ -f "/usr/sbin/apache2ctl" ]] && [[ -f "/nosupervisor" ]]; then
	/usr/sbin/apache2ctl -DFOREGROUND
fi
	# nginx
if [[ -f "/usr/sbin/nginx" ]] && [[ -f "/nosupervisor" ]]; then
	/usr/sbin/nginx -g "daemon off;"
fi
	# php fpm 5.6
if [[ -f "/usr/sbin/php-fpm5.6 " ]] && [[ -f "/nosupervisor" ]]; then
	/usr/sbin/php-fpm5.6 -F
fi
	# php fpm 7.0
if [[ -f "/usr/sbin/php-fpm7.0 " ]] && [[ -f "/nosupervisor" ]]; then
	/usr/sbin/php-fpm7.0 -F
fi
	# php fpm 7.1
if [[ -f "/usr/sbin/apache2ctl" ]] && [[ -f "/nosupervisor" ]]; then
	/usr/sbin/php-fpm7.1 -F
fi
	# php fpm 7.2
if [[ -f "/usr/sbin/apache2ctl" ]] && [[ -f "/nosupervisor" ]]; then
	/usr/sbin/php-fpm7.2 -F
fi
	# litespeed
if [[ -f "/usr/local/lsws/bin/lswsctrl" ]] && [[ -f "/nosupervisor" ]]; then
## Set litespeed admin user
	LITESPEED_ADMIN=${LITESPEED_ADMIN:-admin}
	LITESPEED_PASS=${LITESPEED_PASS:-admintest}
/usr/local/lsws/admin/misc/admpass.sh <<< "$LITESPEED_ADMIN
$LITESPEED_PASS
$LITESPEED_PASS
"
	/usr/local/lsws/bin/lswsctrl start
	sleep infinity
fi

exec "$@"