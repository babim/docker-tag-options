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

# set environment
setenvironment() {
	export SOFT=${SOFT:-logstash}
	export SOFTHOME=${SOFTHOME:-"/usr/share/${SOFT}"}
	export OPENJDKV=${OPENJDKV:-8}
	export UNINSTALL="${DOWNLOAD_TOOL} ca-certificates gnupg openssl"
	env_openjdk_jre
	LS_URL=${LS_URL:-"https://artifacts.elastic.co/downloads/${SOFT}"}
	LS_TARBAL=${LS_TARBAL:-"${LS_URL}/${SOFT}-${LS_VERSION}.tar.gz"}
	LS_SETTINGS_DIR=${LS_SETTINGS_DIR:-"/usr/share/${SOFT}/config"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
}
# download entrypoint files
downloadentrypoint() {
	FILETEMP=/start.sh
	remove_file $FILETEMP
	$download_save $FILETEMP $DOWN_URL/${SOFT}_$FILETEMP
	set_file_mod 755 $FILETEMP
# Supervisor
	check_value_true "${SUPERVISOR}" && run_url $DOWN_URL/supervisor_${SOFT}.sh
# prepare etc start
	run_url $DOWN_URL/prepare_final.sh
}

# install by OS
echo 'Check OS'
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
		install_java_jre
			say "Install depend packages..."
		install_package ca-certificates gnupg openssl tini su-exec libzmq bash libc6-compat
	# make libzmq.so
		create_folder /usr/local/lib
		create_symlink /usr/lib/*/libzmq.so.3 /usr/local/lib/libzmq.so
	# ensure logstash user exists
		adduser -DH -s /sbin/nologin ${SOFT}
	# install logstash
		set -ex \
		&& cd /tmp \
		&& $download_save ${SOFT}.tar.gz "$LS_TARBAL" \
		&& tar -xzf ${SOFT}.tar.gz \
		&& mv ${SOFT}-$LS_VERSION ${SOFTHOME} \
		&& remove_filefolder /tmp/*
	# config setting
		if [[ "$LOGSTASH" = "1" ]] || [[ "$LOGSTASH" = "2" ]]; then
			if [ -f "$LS_SETTINGS_DIR/${SOFT}.yml" ]; then
				sed -ri 's!^(path.log|path.config):!#&!g' "$LS_SETTINGS_DIR/${SOFT}.yml"
			fi
		else
			if [ -f "$LS_SETTINGS_DIR/log4j2.properties" ]; then
				cp "$LS_SETTINGS_DIR/log4j2.properties" "$LS_SETTINGS_DIR/log4j2.properties.dist"
				truncate -s 0 "$LS_SETTINGS_DIR/log4j2.properties"
			fi
		fi

	if [[ "$LOGSTASH" = "6" ]]; then
		create_folder ${SOFTHOME}/config
		create_folder /usr/share/${SOFT}/pipeline
		FILETEMP=${SOFTHOME}/config/log4j2.properties
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/6/${SOFT}/log4j2.properties
		FILETEMP=${SOFTHOME}/config/${SOFT}.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/6/${SOFT}/${SOFT}.yml
		FILETEMP=${SOFTHOME}/pipeline/${SOFT}.conf
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/6/pipeline/default.conf
		downloadentrypoint
	else
		downloadentrypoint
	fi
	if [[ "$XPACK" = "true" ]]; then
		FILETEMP=${SOFTHOME}/config/${SOFT}.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/xpack/${SOFT}/${SOFT}.yml
	fi

	# clean
		clean_package
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi