#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi
echo 'Check OS'
if [[ -f /etc/debian_version ]]; then
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Duplicati%20install"
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
		export DUPLICATI_VER=2.0.4.5-1
		export D_CODEPAGE=UTF-8
		export D_LANG=en_US
	apt-get update
	# install depends
		apt-get install -y --no-install-recommends expect libsqlite3-0 locales 
	# install duplicati
		wget -O duplicati.deb https://updates.duplicati.com/beta/duplicati_${DUPLICATI_VER}_all.deb
		dpkg -i duplicati.deb && apt-get install -f -y && rm -f duplicati.deb
	# fix locales
		localedef -v -c -i ${D_LANG} -f ${D_CODEPAGE} ${D_LANG}.${D_CODEPAGE} || :
    		update-locale LANG=${D_LANG}.${D_CODEPAGE}
   		cert-sync /etc/ssl/certs/ca-certificates.crt
	# download entrypoint
		FILETEMP=/start.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/start.sh && \
		chmod 755 $FILETEMP
	# remove packages
		wget --no-check-certificate -O - $DOWN_URL/clean.sh | bash
else
    echo "Not support your OS"
    exit
fi