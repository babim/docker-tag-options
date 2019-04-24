#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

export IPSCAN=${IPSCAN:-3.5.5}
	install_package \
		ca-certificates-java fonts-dejavu-extra java-common libbonobo2-0 \
		libbonobo2-common libgnome-2-0 libgnome2-common libgnomevfs2-0 \
		libgnomevfs2-common liborbit-2-0 openjdk-8-jre openjdk-8-jre-headless
	FILETEMP=ipscan_${IPSCAN}_amd64.deb
		$download_save $FILETEMP https://github.com/angryip/ipscan/releases/download/$IPSCAN/$FILETEMP
		install_package $FILETEMP && remove_file $FILETEMP