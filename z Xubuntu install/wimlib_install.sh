#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Install Wimlib"

export WIMLIB=${WIMLIB:-1.14.1}
	install_package libxml2-dev ntfs-3g-dev ntfs-3g libfuse-dev libattr1-dev libssl-dev pkg-config build-essential automake
	cd /tmp
	FILETEMP=wimlib-${WIMLIB}
	$download_save $FILETEMP.tar.gz https://wimlib.net/downloads/$FILETEMP.tar.gz
	tar_extract $FILETEMP.tar.gz
	cd $FILETEMP
	./configure
	make
	make install && ldconfig
	cd ..
	remove_filefolder /tmp/winlib*