	# install
	if [ ! -f "/etc/supervisor/supervisord.conf" ]; then
	apt-get install -y --no-install-recommends supervisor
	fi
	# Supervisor config
		[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
		[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
	# download sypervisord config
	FILETEMP=/etc/supervisor/supervisord.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/supervisord.conf
	FILETEMP=/etc/supervisord.conf
		[[ ! -f $FILETEMP ]] || ln -sf $FILETEMP /etc/supervisor/supervisord.conf
	FILETEMP=/etc/supervisor/conf.d/apache.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget --no-check-certificate -O $FILETEMP $DOWN_URL/supervisor/conf.d/apache.conf