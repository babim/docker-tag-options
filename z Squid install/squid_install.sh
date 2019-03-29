#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# check permission root
echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# set environment
setenvironment() {
	export SOFT=${SOFT:-squid}
	export SQUID_USER=${SQUID_USER:-squid}
	export SQUID_CACHE_DIR=${SQUID_CACHE_DIR:-"/var/spool/squid${SQUID_VERSION}"}
	export SQUID_LOG_DIR=${SQUID_LOG_DIR:-"/var/log/squid${SQUID_VERSION}"}
	export SQUID_DIR=${SQUID_DIR:-"/squid"}
	export SQUID_CONFIG_DIR=${SQUID_CONFIG_DIR:-"/etc/squid${SQUID_VERSION}"}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Squid%20install"
}

# set command install
dockerentry() {
	# download docker entry
	FILETEMP=/docker-entrypoint.sh
	[[ -f $FILETEMP ]] && rm -f $FILETEMP
	wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_start.sh
	chmod +x $FILETEMP
}
cleanpackage() {
	# remove packages
	wget --no-check-certificate -O - $DOWN_URL/${SOFT}_clean.sh | bash
}
preparedata() {
	# change to one directory
	[ -d ${SQUID_CACHE_DIR} ] || mkdir -p ${SQUID_CACHE_DIR} && \
	[ -d ${SQUID_LOG_DIR} ] || mkdir -p ${SQUID_LOG_DIR} && \
	[ -d ${SQUID_DIR} ] || mkdir -p ${SQUID_DIR} && mkdir -p ${SQUID_DIR}_start && \
	mv ${SQUID_CACHE_DIR} ${SQUID_DIR}_start/cache && ln -sf ${SQUID_DIR}/cache ${SQUID_CACHE_DIR} && \
	mv ${SQUID_LOG_DIR} ${SQUID_DIR}_start/log && ln -sf ${SQUID_DIR}/log ${SQUID_LOG_DIR} && \
	mv ${SQUID_CONFIG_DIR} ${SQUID_DIR}_start/config && ln -sf ${SQUID_DIR}/config ${SQUID_CONFIG_DIR}
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install
	#export SQUID_VERSION=
		apk add --no-cache squid apache2-utils
 	#mv ${SQUID_CONFIG_DIR}/squid.conf ${SQUID_CONFIG_DIR}/squid.conf.dist
		dockerentry
		preparedata
		cleanpackage
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	export SQUID_VERSION=3
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# install depend
		apt-get update
		apt-get install -y squid${SQUID_VERSION} apache2-utils
		dockerentry
		preparedata
		cleanpackage
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    echo "Not support your OS"
    exit
# OS - other
else
    echo "Not support your OS"
    exit
fi