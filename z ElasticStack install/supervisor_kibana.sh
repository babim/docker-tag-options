	# install
	apk add --no-cache supervisor
		# Supervisor config
			[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
			[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
		# download sypervisord config
		FILETEMP=/etc/supervisor/supervisord.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/supervisor/supervisord.conf
		FILETEMP=/etc/supervisor/conf.d/kibana.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/supervisor/conf.d/kibana.conf