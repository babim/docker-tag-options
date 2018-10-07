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
	# set global environment
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mongodb%20install"
	export MONGO_REPO=${MONGO_REPO:-repo.mongodb.org}

	# download entrypoint
	downloadentry() {
		FILETEMP=/start.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/mongodb_start.sh
		chmod 755 $FILETEMP
	# Supervisor
		wget --no-check-certificate -O - $DOWN_URL/supervisor_mongodb.sh | bash
	# prepare etc start
		wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash
		}

if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
	export DEBIAN_FRONTEND=noninteractive
	export MONGO_PACKAGE=${MONGO_PACKAGE:-mongodb-org-unstable}
	if [ -f /etc/lsb-release ]; then
    		export OSRUN=ubuntu
	elif [ -f /etc/debian_version ]; then
    		export OSRUN=debian
	fi

	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
		groupadd -r mongodb && useradd -r -g mongodb mongodb

	# install depend
		apt-get update \
		&& apt-get install -y ca-certificates gnupg dirmngr jq numactl

	# install gosu
		wget --no-check-certificate -O - $DOWN_URL/gosu_install.sh | bash
	# install js-yaml
		wget --no-check-certificate -O - $DOWN_URL/js-yaml_install.sh | bash

	mkdir /docker-entrypoint-initdb.d
	# add repo
		wget --no-check-certificate -O - $DOWN_URL/mongodb_repo.sh | bash
	# install mongodb
	set -x \
		&& apt-get update
		# install lastest version
	if [ "$MONGO_MAJOR" == "4.1" ]; then
		apt-get install -y \
			${MONGO_PACKAGE}-unstable \
			${MONGO_PACKAGE}-unstable-server \
			${MONGO_PACKAGE}-unstable-shell \
			${MONGO_PACKAGE}-unstable-mongos \
			${MONGO_PACKAGE}-unstable-tools
	else
		apt-get install -y \
			${MONGO_PACKAGE} \
			${MONGO_PACKAGE}-server \
			${MONGO_PACKAGE}-shell \
			${MONGO_PACKAGE}-mongos \
			${MONGO_PACKAGE}-tools
	fi
		# install correct version
		#	${MONGO_PACKAGE}=$MONGO_VERSION \
		#	${MONGO_PACKAGE}-server=$MONGO_VERSION \
		#	${MONGO_PACKAGE}-shell=$MONGO_VERSION \
		#	${MONGO_PACKAGE}-mongos=$MONGO_VERSION \
		#	${MONGO_PACKAGE}-tools=$MONGO_VERSION
		rm -rf /var/lib/mongodb \
		&& mv /etc/mongod.conf /etc/mongod.conf.orig

		mkdir -p /data/db /data/configdb \
		&& chown -R mongodb:mongodb /data/db /data/configdb

	# download entrypoint
		downloadentry

	# clean os
		apt-get purge -y wget curl && \
		apt-get clean && \
  		apt-get autoclean && \
  		apt-get autoremove -y && \
   		rm -rf /build && \
   		rm -rf /tmp/* /var/tmp/* && \
   		rm -rf /var/lib/apt/lists/*	

elif [[ -f /etc/redhat-release ]]; then
	yum install -y supervisor
	# set environment
	export MONGO_PACKAGE=${MONGO_PACKAGE:-mongodb-org}
	# install gosu
		wget --no-check-certificate -O - $DOWN_URL/gosu_install.sh | bash
	# install js-yaml
		wget --no-check-certificate -O - $DOWN_URL/js-yaml_install.sh | bash
	# add repo
		wget --no-check-certificate -O - $DOWN_URL/mongodb_repo.sh | bash
	# install mongodb
		# install lastest version
		yum install -y \
			${MONGO_PACKAGE} \
			${MONGO_PACKAGE}-server \
			${MONGO_PACKAGE}-shell \
			${MONGO_PACKAGE}-mongos \
			${MONGO_PACKAGE}-tools
		# install correct version
		#	${MONGO_PACKAGE}-$MONGO_VERSION \
		#	${MONGO_PACKAGE}-server-$MONGO_VERSION \
		#	${MONGO_PACKAGE}-shell-$MONGO_VERSION \
		#	${MONGO_PACKAGE}-mongos-$MONGO_VERSION \
		#	${MONGO_PACKAGE}-tools-$MONGO_VERSION
	# download entrypoint
		downloadentry
	# clean os
		yum clean all

else
    echo "Not support your OS"
    exit
fi