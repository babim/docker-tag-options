#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

#####################################
    ####### Set download tool #######
    ####### and load library ########
# check has package
function    machine_has() {
        hash "$1" > /dev/null 2>&1
        return $?; }
# Check and set download tool
echo "Check and set download tool..."
if machine_has "curl"; then
    source <(curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
elif machine_has "wget"; then
    source <(wget -qO- https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
else
    echo "without download tool"
    sleep 3
    exit 1
fi
download_option
#####################################

# need root to run
	require_root

	# set global environment
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Mongodb%20install"
	export MONGO_REPO=${MONGO_REPO:-repo.mongodb.org}
	export UNINSTALL="${DOWNLOAD_TOOL}"

# download entrypoint
downloadentry() {
FILETEMP=start.sh
	remove_file $FILETEMP
	$download_save /$FILETEMP $DOWN_URL/mongodb_$FILETEMP
	set_file_mod 755 /$FILETEMP
# Supervisor
	## Supervisor config
		create_folder /var/log/supervisor/
		create_folder /etc/supervisor/conf.d/
	## download sypervisord config
	FILETEMP=/etc/supervisor/supervisord.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/supervisor/supervisord.conf
	FILETEMP=/etc/supervisord.conf
		create_symlink $FILETEMP /etc/supervisor/supervisord.conf
	## mongodb
	FILETEMP=/etc/supervisor/conf.d/mongodb.conf
	 	remove_file $FILETEMP
	 	$download_save $FILETEMP $DOWN_URL/supervisor/conf.d/mongodb.conf
# prepare etc start
	run_url $DOWN_URL/prepare_final.sh
}

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
	debian_cmd_interface
	export MONGO_PACKAGE=${MONGO_PACKAGE:-mongodb-org-unstable}
	if [ -f /etc/lsb-release ]; then
    		export OSRUN=ubuntu
	elif [ -f /etc/debian_version ]; then
    		export OSRUN=debian
	fi

	# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
		groupadd -r mongodb && useradd -r -g mongodb mongodb

	# install depend
		install_package ca-certificates gnupg dirmngr jq numactl
	# install gosu
		install_gosu
	# install js-yaml
		install_js-yaml

	create_folder /docker-entrypoint-initdb.d
	# add repo
		run_url $DOWN_URL/mongodb_repo.sh
	# install mongodb
		# install lastest version
	if [ "$MONGO_MAJOR" == "4.1" ]; then
		install_package \
			${MONGO_PACKAGE}-unstable \
			${MONGO_PACKAGE}-unstable-server \
			${MONGO_PACKAGE}-unstable-shell \
			${MONGO_PACKAGE}-unstable-mongos \
			${MONGO_PACKAGE}-unstable-tools
	else
		install_package \
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
		remove_filefolder /var/lib/mongodb \
		&& mv /etc/mongod.conf /etc/mongod.conf.orig

		create_folder /data/db /data/configdb \
		&& set_filefolder_owner mongodb:mongodb /data/db /data/configdb

	# download entrypoint
		downloadentry

	# clean os
		clean_package
		clean_os	

elif [[ -f /etc/redhat-release ]]; then
	install_supervisor
	# set environment
	export MONGO_PACKAGE=${MONGO_PACKAGE:-mongodb-org}
	# install gosu
		install_gosu
	# install js-yaml
		install_js-yaml
	# add repo
		run_url $DOWN_URL/mongodb_repo.sh
	# install mongodb
		# install lastest version
		install_package \
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
		clean_package
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi