	# install
	apk add --no-cache supervisor
		# Supervisor config
			[[ -d /var/log/supervisor ]] || mkdir -p /var/log/supervisor/
			[[ -d /etc/supervisor/conf.d ]] || mkdir -p /etc/supervisor/conf.d/
		FILETEMP=/etc/supervisord.conf
			[[ ! -f $FILETEMP ]] || ln -sf /etc/supervisor/supervisord.conf $FILETEMP
		# download sypervisord config
		if [[ "$STACK_NEW" = "false" ]]; then
			FILETEMP=/etc/supervisor/supervisord.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/3/supervisord/supervisord.conf
		else
		FILETEMP=/etc/supervisor/supervisord.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/supervisord/supervisord.conf
		FILETEMP=/etc/supervisor/conf.d/elasticsearch.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/elasticsearch.conf
		FILETEMP=/etc/supervisor/conf.d/kibana.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/kibana.conf
		FILETEMP=/etc/supervisor/conf.d/logstash.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/logstash.conf
		FILETEMP=/etc/supervisor/conf.d/nginx.conf
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/nginx.conf
		fi