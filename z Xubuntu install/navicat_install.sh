#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

	FILETEMP=navicat_premium.tar.gz
		$download_save $FILETEMP http://media.matmagoc.com/$FILETEMP
		tar_extract $FILETEMP /opt && remove_file $FILETEMP
	FILETEMP=navicat_premium.tar.gz
		$download_save /root/Desktop/$FILETEMP http://media.matmagoc.com/$FILETEMP
		set_file_mod +x /root/Desktop/$FILETEMP