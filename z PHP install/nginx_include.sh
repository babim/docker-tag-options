#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# create folder
FILETEMP=/etc/nginx/include
	[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
FILETEMP=/etc/nginx/certs
	[[ -d $FILETEMP ]] || mkdir -p $FILETEMP

# downloads
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"

	# config default site
	FILETEMP=/etc/nginx/conf.d/default.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_config/default.conf
	FILETEMP=/etc/nginx/certs/default-ssl.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_config/default-ssl.conf
	# config ssl default
	FILETEMP=/etc/nginx/certs/example-cert.pem
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/ssl/example-cert.pem
	FILETEMP=/etc/nginx/certs/example-key.pem
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/ssl/example-key.pem
	# include
	FILETEMP=/etc/nginx/include/owncloud.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/owncloud.conf
	FILETEMP=/etc/nginx/include/phpparam.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/phpparam.conf
	FILETEMP=/etc/nginx/include/restrict.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/restrict.conf
	FILETEMP=/etc/nginx/include/rootwordpressclean.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/rootwordpressclean.conf
	FILETEMP=/etc/nginx/include/wordpress.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/wordpress.conf
	FILETEMP=/etc/nginx/include/wordpressmulti.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/wordpressmulti.conf
	FILETEMP=/etc/nginx/include/wpsupercache.conf
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/nginx_include/wpsupercache.conf