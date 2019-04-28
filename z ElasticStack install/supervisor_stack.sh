#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# install supervisor
	install_supervisor

	# Supervisor config
		create_folder /var/log/supervisor/
		create_folder /etc/supervisor/conf.d/
		
		# download sypervisord config
		if [[ "$STACK_NEW" = "false" ]]; then
			FILETEMP=/etc/supervisor/supervisord.conf
				$download_save $FILETEMP $DOWN_URL/stack_config/3/supervisord/supervisord.conf
		else
			FILETEMP=/etc/supervisor/supervisord.conf
				$download_save $FILETEMP $DOWN_URL/stack_config/config/supervisord/supervisord.conf
				create_symlink /etc/supervisord.conf $FILETEMP
			FILETEMP=/etc/supervisor/conf.d/elasticsearch.conf
				$download_save $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/elasticsearch.conf
			FILETEMP=/etc/supervisor/conf.d/kibana.conf
				$download_save $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/kibana.conf
			FILETEMP=/etc/supervisor/conf.d/logstash.conf
				$download_save $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/logstash.conf
			FILETEMP=/etc/supervisor/conf.d/nginx.conf
				$download_save $FILETEMP $DOWN_URL/stack_config/config/supervisord/conf.d/nginx.conf
		fi