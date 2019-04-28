#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# prepare etc start
    remove_filefolder 	/etc-start
    create_folders	/etc-start/nginx \
			/etc-start/php \
			/etc-start/apache2 \
			/etc-start/www \
			/etc-start/supervisor \
			/etc-start/lsws
# nginx
    dircopy 		/etc/nginx/ 		/etc-start/nginx
# php
    dircopy 		/etc/php/ 		/etc-start/php
# apache
    dircopy 		/etc/apache2/ 		/etc-start/apache2
# www data
    dircopy 		/var/www/ 		/etc-start/www
# supervisor
    dircopy 		/etc/supervisor/ 	/etc-start/supervisor
# litespeed
    dircopy 		/usr/local/lsws/ 	/etc-start/lsws
# end