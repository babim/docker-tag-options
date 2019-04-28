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
	FILETEMP=/etc/supervisor/supervisord.conf
		$download_save $FILETEMP $DOWN_URL/supervisor/supervisord.conf
		create_symlink /etc/supervisord.conf $FILETEMP
	# logstash
	FILETEMP=/etc/supervisor/conf.d/logstash.conf
		$download_save $FILETEMP $DOWN_URL/supervisor/conf.d/logstash.conf