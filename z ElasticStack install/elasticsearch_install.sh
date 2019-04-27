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
	export SOFT=${SOFT:-elasticsearch}
	export SOFTHOME=${SOFTHOME:-"/usr/share/${SOFT}"}
	export OPENJDKV=${OPENJDKV:-8}
	env_openjdk_jre
	DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/${SOFT}"}
	ES_TARBAL=${ES_TARBAL:-"${DOWNLOAD_URL}/${SOFT}-${ES_VERSION}.tar.gz"}
	export UNINSTALL="${DOWNLOAD_TOOL}"
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
}
# download entrypoint files
downloadentrypoint() {
FILETEMP=start.sh
	remove_file /$FILETEMP
	cd /
if [[ "$ES" = "6" ]]; then
	$download_save /$FILETEMP $DOWN_URL/${SOFT}6_$FILETEMP
elif [[ "$ES" = "1" ]]; then
	$download_save /$FILETEMP $DOWN_URL/${SOFT}1_$FILETEMP
elif [[ "$ES" = "2" ]]; then
	$download_save /$FILETEMP $DOWN_URL/${SOFT}2_$FILETEMP
else
	$download_save /$FILETEMP $DOWN_URL/${SOFT}5_$FILETEMP
fi
	set_file_mod 755 /$FILETEMP
# Supervisor
	check_value_true "${SUPERVISOR}" && run_url $DOWN_URL/supervisor_${SOFT}.sh
# prepare etc start
	run_url $DOWN_URL/prepare_final.sh
# docker health check
FILETEMP=/usr/local/bin/docker-healthcheck
	remove_file $FILETEMP
	$download_save /$FILETEMP $DOWN_URL/${SOFT}_healthcheck/docker-healthcheck
	set_file_mod 755 /$FILETEMP
}
prepareconfig() {
FILETEMP=/usr/share/${SOFT}/config
	[[ -d $FILETEMP ]] || mkdir -p $FILETEMP
if [[ "$ES" = "1" ]]; then
	FILETEMP=/usr/share/${SOFT}/config/${SOFT}.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/1/${SOFT}.yml
	FILETEMP=/usr/share/${SOFT}/config/logging.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/1/logging.yml
elif [[ "$ES" = "2" ]]; then
	FILETEMP=/usr/share/${SOFT}/config/${SOFT}.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/2/${SOFT}.yml
	FILETEMP=/usr/share/${SOFT}/config/logging.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/2/logging.yml
else
	FILETEMP=/usr/share/${SOFT}/config/${SOFT}.yml
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/5/${SOFT}.yml
	FILETEMP=/usr/share/${SOFT}/config/log4j2.properties
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/5/log4j2.properties
fi
}
prepagelogrotage() {
	create_folder /etc/logrotate.d/${SOFT}
if [[ "$ES" = "1" ]] || [[ "$ES" = "2" ]]; then
	say "not download"
else
	FILETEMP=/etc/logrotate.d/${SOFT}/logrotate
	remove_file $FILETEMP
	$download_save $FILETEMP $DOWN_URL/${SOFT}_config/5/logrotate
fi
}

# install by OS
echo 'Check OS'
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
		install_java_jre
			say "Install depend packages..."
		install_package gnupg openssl tini su-exec libzmq bash libc6-compat
	# ensure elasticsearch user exists
		adduser -DH -s /sbin/nologin ${SOFT}
	# install elasticsearch
		cd /tmp \
		  && say "===> Install ${SOFT}..." \
		  && $download_save ${SOFT}.tar.gz "${ES_TARBAL}"; \
		  tar -xf ${SOFT}.tar.gz \
		  && ls -lah \
		  && mv ${SOFT}-$ES_VERSION ${SOFTHOME} \
		  && say "===> Creating ${SOFT} Paths..." \
		  && for path in \
		  	${SOFTHOME}/data \
		  	${SOFTHOME}/logs \
		  	${SOFTHOME}/config \
		  	${SOFTHOME}/config/scripts \
			${SOFTHOME}/tmp \
		  	${SOFTHOME}/plugins \
		  ; do \
		  create_folder "$path"; \
		  set_filefolder_owner ${SOFT}:${SOFT} "$path"; \
		  done \
		  && remove_filefolder /tmp/*
	
	if [[ "$ES" = "1" ]] || [[ "$ES" = "2" ]]; then
		prepareconfig
	# download entrypoint
		downloadentrypoint
	else
		prepagelogrotage
		prepareconfig
	# download entrypoint
		downloadentrypoint
	fi
	if check_value_true "${XPACK}"; then
		create_folder /usr/share/${SOFT}/config/x-pack
		FILETEMP=/usr/share/${SOFT}/config/x-pack/log4j2.properties
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/${SOFT}_config/x-pack/log4j2.properties
	fi

	# clean
		clean_package
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi