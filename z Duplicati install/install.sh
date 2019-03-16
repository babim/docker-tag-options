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
		apt-get install -y --no-install-recommends expect libsqlite3-0 locales \
			libmono-2.0-1 libmono-system-configuration-install4.0-cil libmono-system-data4.0-cil \
			libmono-system-drawing4.0-cil libmono-system-net4.0-cil libmono-system-net-http4.0-cil \
			libmono-system-net-http-webrequest4.0-cil libmono-system-runtime-serialization4.0-cil \
			libmono-system-servicemodel4.0a-cil libmono-system-servicemodel-discovery4.0-cil \
			libmono-system-serviceprocess4.0-cil libmono-system-transactions4.0-cil \
			libmono-system-web4.0-cil libmono-system-web-services4.0-cil libmono-microsoft-csharp4.0-cil \
			libappindicator3-0.1-cil
		# libappindicator0.1-cil
	# install missing depend
		wget -O missing1.deb http://mirrors.kernel.org/ubuntu/pool/universe/liba/libappindicator/libappindicator0.1-cil_12.10.1+18.04.20180322.1-0ubuntu1_all.deb
		dpkg -i missing1.deb && rm -f missing1.deb
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