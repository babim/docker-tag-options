#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Install RealVNC"

export REALVNC=${REALVNC:-6.4.0}
	cd /tmp
	FILETEMP=VNC-Server-$REALVNC-Linux-x64.deb
		$download_save $FILETEMP https://www.realvnc.com/download/file/vnc.files/$FILETEMP
		install_package $FILETEMP
		echo "vnclicense -add KCG8D-BADL3-L8K3F-TW4VF-XWD7A" > /vnckey.sh
		set_filefolder_mod +x /vnckey.sh
		remove_file /tmp/$FILETEMP