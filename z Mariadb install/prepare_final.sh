#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# prepare etc start
    check_folder 	/etc-start	&& remove_folder /etc-start				|| say "/etc-start not exist"
# mysql
    create_folder 	/etc-start/mysql
    check_folder 	/etc/mysql	&& dircopy /etc/mysql /etc-start/mysql			|| say "no need copy mysql config"
# supervisor
    create_folder 	/etc-start/supervisor
    check_folder	/etc/supervisor	&& dircopy /etc/supervisor /etc-start/supervisor	|| say "no need copy mysql config"
