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

# set MACHINE_TYPE
MACHINE_TYPE=`uname -m`
[[ ${MACHINE_TYPE} == 'x86_64' ]] && echo "Your server is x86_64 system" || echo "Your server is x86 system"

setenvironment() {
		export SOFT=${SOFT:-KeyManager}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/KeyManager}
		#export EDITTION=${EDITTION:-essential}
		export FIXED=${FIXED:-false}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
	# database user
		export PUID=1000
		export PUNAME=postgres
		export PGID=1000
		export PGNAME=postgres
}
preparedata() {
	# prepare data start
	echo "Prepare data"
		create_folder /start/
		rsync_folder ${SOFT_HOME}/ /start
		remove_filefolder ${SOFT_HOME}/*
}
downloadentry() {
	# download docker entry
	echo "Download entrypoint"
		FILETEMP=/docker-entrypoint.sh
		remove_file
			$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
		set_filefolder_mod +x $FILETEMP
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
    say_err "Not support your OS"
    exit 1
	# addgroup -g $PGID $PGNAME \
	#  && adduser -SH -u $PUID -G $PGNAME -s /usr/sbin/nologin $PUNAME
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# install depend
		install_package rsync unzip
		groupadd -g $PGID $PGNAME && create_folder /home/postgres \
		&& useradd --system --uid $PUID -g $PGNAME -d /home/postgres -M --shell /usr/sbin/nologin $PUNAME
	# preparedata
		#preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# set environment
		setenvironment
	# install depend
		install_package rsync hostname unzip
		groupadd -g $PGID $PGNAME && create_folder /home/postgres \
		&& useradd --system --uid $PUID -g $PGNAME -d /home/postgres -M $PUNAME
	# preparedata
		#preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi