#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Install Navicat"

	FILETEMP=navicat_premium.tar.gz
		$download_save $FILETEMP http://file.matmagoc.com/$FILETEMP
		tar_extract $FILETEMP /opt && remove_file $FILETEMP
	FILETEMP=navicat_premium.tar.gz
		$download_save /root/Desktop/$FILETEMP http://file.matmagoc.com/$FILETEMP
		set_file_mod +x /root/Desktop/$FILETEMP