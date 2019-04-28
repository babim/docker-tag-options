#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# create folder
	create_folders /etc/nginx/include
	create_folders /etc/nginx/certs

# downloads
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"

	# config default site
	remove_files /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default.conf /etc/nginx/sites-enabled/default
	FILETEMP=/etc/nginx/sites-enabled/default.conf
		$download_save $FILETEMP $DOWN_URL/nginx_config/default.conf
	FILETEMP=/etc/nginx/http2-ssl.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_config/http2-ssl.conf

	# config ssl default
	FILETEMP=/etc/nginx/certs/example-cert.pem
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/ssl/example-cert.pem
	FILETEMP=/etc/nginx/certs/example-key.pem
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/ssl/example-key.pem
	FILETEMP=/etc/nginx/certs/ca-cert.pem
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/ssl/ca-cert.pem

	# include
	FILETEMP=/etc/nginx/include/owncloud.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/owncloud.conf
	FILETEMP=/etc/nginx/include/phpparam.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/phpparam.conf
	FILETEMP=/etc/nginx/include/restrict.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/restrict.conf
	FILETEMP=/etc/nginx/include/rootwordpressclean.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/rootwordpressclean.conf
	FILETEMP=/etc/nginx/include/wordpress.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/wordpress.conf
	FILETEMP=/etc/nginx/include/wordpressmulti.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/wordpressmulti.conf
	FILETEMP=/etc/nginx/include/wpsupercache.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/nginx_include/wpsupercache.conf