#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Install RealVNC"

export REALVNC=${REALVNC:-6.4.0}
	cd /tmp && wget https://www.realvnc.com/download/file/vnc.files/VNC-Server-$REALVNC-Linux-x64.deb && dpkg -i VNC-Server-*.deb && \
	echo "vnclicense -add KCG8D-BADL3-L8K3F-TW4VF-XWD7A" > /vnckey.sh && \
	chmod +x /vnckey.sh
	rm -f /tmp/VNC-Server-*.deb