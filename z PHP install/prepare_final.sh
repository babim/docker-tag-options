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
    check_folder	/etc/nginx		&& create_folders /etc-start/nginx 			|| say "no need create nginx setting folder"
    check_folder	/etc/php		&& create_folders /etc-start/php 			|| say "no need create php setting folder"
    check_folder	/etc/apache2		&& create_folders /etc-start/apache2 			|| say "no need create apache2 setting folder"
    check_folder	/var/www		&& create_folders /etc-start/www 			|| say "no need create www folder"
    check_folder	/etc/supervisor		&& create_folders /etc-start/supervisor			|| say "no need create supervisor setting folder"
    check_folder	/etc/lsws		&& create_folders /etc-start/lsws			|| say "no need create litespeed setting folder"

# nginx
    check_folder	/etc/nginx		&& dircopy /etc/nginx/ /etc-start/nginx			|| say "no need copy nginx setting files"
# php
    check_folder	/etc/php		&& dircopy /etc/php/ /etc-start/php			|| say "no need copy php setting files"
# apache
    check_folder	/etc/apache2		&& dircopy /etc/apache2/ /etc-start/apache2		|| say "no need copy apache2 setting files"
# www data
    check_folder	/etc/www		&& dircopy /var/www/ /etc-start/www			|| say "no need copy www files"
# supervisor
    check_folder	/etc/supervisor		&& dircopy /etc/supervisor/ /etc-start/supervisor	|| say "no need copy supervisor setting files"
# litespeed
    check_folder	/etc/local/lsws		&& dircopy /usr/local/lsws/ /etc-start/lsws		|| say "no need copy litespeed setting files"
# end