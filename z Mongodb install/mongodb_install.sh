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
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mongodb%20install"
	MONGO_PACKAGE=${MONGO_PACKAGE:-mongodb-org-unstable}
	MONGO_REPO=${MONGO_REPO:-repo.mongodb.org}

	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
		groupadd -r mongodb && useradd -r -g mongodb mongodb

	# install depend
		apt-get update \
		&& apt-get install -y ca-certificates gnupg dirmngr jq numactl

	# install gosu
		wget --no-check-certificate -O - $DOWN_URL/gosu_install.sh | bash
	# install js-yaml
		wget --no-check-certificate -O - $DOWN_URL/js-yaml_install.sh | bash

	# add repo
	if [ -f /etc/lsb-release ]; then
    		export OSRUN=ubuntu
		key='E162F504A20CDF15827F718D4B7C549A058F8B6B'
	elif [ -f /etc/debian_version ]; then
    		export OSRUN=debian
		key='2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5'
	fi		
		export GNUPGHOME="$(mktemp -d)"; \
		gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		gpg --export "$key" >> /etc/apt/trusted.gpg.d/mariadb.gpg; \
		command -v gpgconf > /dev/null && gpgconf --kill all || :; \
		rm -rf "$GNUPGHOME"; \
		apt-key list > /dev/null
		echo "deb http://$MONGO_REPO/apt/$OSRUN $OSDEB/${MONGO_PACKAGE%-unstable}/$MONGO_MAJOR multiverse" | tee "/etc/apt/sources.list.d/${MONGO_PACKAGE%-unstable}.list"

	# install mongodb
	set -x \
		&& apt-get update \
		&& apt-get install -y \
			${MONGO_PACKAGE}=$MONGO_VERSION \
			${MONGO_PACKAGE}-server=$MONGO_VERSION \
			${MONGO_PACKAGE}-shell=$MONGO_VERSION \
			${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
			${MONGO_PACKAGE}-tools=$MONGO_VERSION \
		&& rm -rf /var/lib/apt/lists/* \
		&& rm -rf /var/lib/mongodb \
		&& mv /etc/mongod.conf /etc/mongod.conf.orig

		mkdir -p /data/db /data/configdb \
		&& chown -R mongodb:mongodb /data/db /data/configdb

	# download entrypoint
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/mongodb_start.sh
		chmod 755 $FILETEMP

	# clean os
		apt-get purge -y wget curl && \
		apt-get clean && \
  		apt-get autoclean && \
  		apt-get autoremove -y && \
   		rm -rf /build && \
   		rm -rf /tmp/* /var/tmp/* && \
   		rm -rf /var/lib/apt/lists/*	
	
else
    echo "Not support your OS"
    exit
fi