#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Install RazorSQL"

# download and install
export RAZORSQL=${RAZORSQL:-7_4_10}
	#	wget http://file.matmagoc.com/razorsql_linux_x64.tar.gz
	#	tar -xzvpf razorsql${RAZORSQL}_linux_x64.tar.gz -C /opt && rm -f razorsql${RAZORSQL}_linux_x64.tar.gz
	FILETEMP=razorsql${RAZORSQL}_linux_x64.zip
		$download_save $FILETEMP https://s3.amazonaws.com/downloads.razorsql.com/downloads/${RAZORSQL}/$FILETEMP
		unzip_extract $FILETEMP /opt && remove_file $FILETEMP

	# register
	FILETEMP=razorsqlreg.tar.gz
		$download_save $FILETEMP http://file.matmagoc.com/$FILETEMP && \
		tar_extract $FILETEMP /root && remove_file $FILETEMP
	FILETEMP=razorsqlreg.tar.gz
		$download_save /root/Desktop/$FILETEMP http://file.matmagoc.com/$FILETEMP && \
		set_filefolder_mod +x /root/Desktop/$FILETEMP