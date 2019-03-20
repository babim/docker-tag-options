#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# check permission root
echo 'Check root'
if [[ "x$(id -u)" != 'x0' ]]; then
	echo 'Error: this script can only be executed by root'
	exit 1
fi
MACHINE_TYPE=`uname -m`
if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
	echo x64
else
	echo x86
fi

preparedata() {
	# prepare data start
	echo "Prepare data"
		mkdir /start/
		rsync -arvpz --numeric-ids ${SOFT_HOME}/ /start
		rm -rf ${SOFT_HOME}/*
}
downloadentry() {
	# download docker entry
	echo "Download entrypoint"
		FILETEMP=/docker-entrypoint.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_start.sh
		chmod +x $FILETEMP
}
cleanmanageengine() {
	# remove packages
	echo "Remove packages"
		wget --no-check-certificate -O - $DOWN_URL/${SOFT}_clean.sh | bash
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
    echo "Not support your OS"
    exit
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# install depend
		apt-get update && apt-get install -y rsync
#		preparedata
		downloadentry
	# clean
		cleanmanageengine
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# install depend
		yum install -y rsync
#		preparedata
		downloadentry
	# clean
		cleanmanageengine
# OS - other
else
    echo "Not support your OS"
    exit
fi