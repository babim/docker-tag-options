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
	export SOFT=${SOFT:-kibana}
	export SOFTHOME=${SOFTHOME:-"/usr/share/${SOFT}"}
	export UNINSTALL="ca-certificates gnupg openssl"
	DOWNLOAD_URL=${DOWNLOAD_URL:-"https://artifacts.elastic.co/downloads/${SOFT}"}
	BIT=${BIT:-"$(uname -m)"}
	TARBAL=${TARBAL:-"${DOWNLOAD_URL}/${SOFT}-${KB_VERSION}-linux-${BIT}.tar.gz"}
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ElasticStack%20install"
}
# download entrypoint files
downloadentrypoint() {
FILETEMP=start.sh
	[[ "$KIBANA" = "6" ]] && $download_save /$FILETEMP $DOWN_URL/${SOFT}6_$FILETEMP || $download_save /$FILETEMP $DOWN_URL/${SOFT}_$FILETEMP
	set_file_mod 755 /$FILETEMP
# Supervisor
	check_value_true "$SUPERVISOR" && run_url $DOWN_URL/supervisor_${SOFT}.sh
# prepare etc start
	run_url $DOWN_URL/prepare_final.sh
}

# install by OS
echo 'Check OS'
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
			say "Install depend packages..."
		install_package nodejs su-exec tini
		install_package ca-certificates gnupg openssl
	# ensure kibana user exists
		adduser -DH -s /sbin/nologin ${SOFT}
	# install kibana
		cd /tmp
		  say "===> Install ${SOFT}..."
		  $download_save ${SOFT}.tar.gz "${TARBAL}"
		  tar -xf ${SOFT}.tar.gz
		  ls -lah
		FILETEMP=${SOFT}-$KB_VERSION-linux-${BIT}
		  check_folder $FILETEMP	&& mv $FILETEMP ${SOFTHOME} 	|| say "${FILETEMP} does not exist"
		FILETEMP=${SOFT}-oss-$KB_VERSION-linux-${BIT}
		  check_folder $FILETEMP	&& mv $FILETEMP ${SOFTHOME} 	|| say "${FILETEMP} does not exist"
	# Config after install
	if [[ "$KIBANA" = "4" ]]; then
		say "setting for kibana 4"
		remove_file ${SOFTHOME}/node/bin/node
		remove_file ${SOFTHOME}/node/bin/npm
		check_file /usr/bin/node 	&& create_symlink /usr/bin/node ${SOFTHOME}/node/bin/node	|| say_error "Not have nodejs"
		check_file /usr/lib/node_modules/npm/bin/npm-cli.js 	&& create_symlink /usr/lib/node_modules/npm/bin/npm-cli.js ${SOFTHOME}/node/bin/npm	|| say "search npm and create symlink"
		check_file /usr/bin/npm 	&& create_symlink /usr/lib/node_modules/npm/bin/npm-cli.js ${SOFTHOME}/node/bin/npm	|| say "search npm and create symlink"
		FILETEMP=${SOFTHOME}/config/${SOFT}.yml
		  if check_file ${FILETEMP}; then
			sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" ${FILETEMP}
			grep -q "^server\.host: '0.0.0.0'\$" ${FILETEMP}
	  	# ensure the default configuration is useful when using --link
			sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" ${FILETEMP}
			grep -q "^elasticsearch\.url: 'http://elasticsearch:9200'\$" ${FILETEMP}
		  else
			say "${FILETEMP} does not exist"
		  fi
	elif [[ "${KB_VERSION}" == "6.6.0" || "${KB_VERSION}" == "6.6.1" || "${KB_VERSION}" == "6.6.2" || "${KB_VERSION}" == "6.6.3" || "${KB_VERSION}" == "6.6.4" ]]; then
		say "setting for kibana 6.6.x"
		say "no need sed value"
	else
		FILETEMP=${SOFTHOME}/config/${SOFT}.yml
		  if check_file ${FILETEMP}; then
			sed -ri "s!^(\#\s*)?(server\.host:).*!\2 '0.0.0.0'!" ${FILETEMP}
			grep -q "^server\.host: '0.0.0.0'\$" ${FILETEMP}
	  	  # ensure the default configuration is useful when using --link
			sed -ri "s!^(\#\s*)?(elasticsearch\.url:).*!\2 'http://elasticsearch:9200'!" ${FILETEMP}
			grep -q "^elasticsearch\.url: 'http://elasticsearch:9200'\$" ${FILETEMP}
		  else
			say "${FILETEMP} does not exist"
		  fi
	fi
 	 # usr alpine nodejs and not bundled version
		say "sed node path ${FILETEMP}"
		bundled='NODE="${DIR}/node/bin/node"'
		apline_node='NODE="/usr/bin/node"'
	FILETEMP=${SOFTHOME}/bin/${SOFT}-plugin
		if check_folder ${FILETEMP}; then
			sed -i "s|$bundled|$apline_node|g" ${FILETEMP}
		else
			say "${FILETEMP} does not exist"
		fi
	FILETEMP=${SOFTHOME}/bin/${SOFT}
		if check_folder ${FILETEMP}; then
			sed -i "s|$bundled|$apline_node|g" ${FILETEMP}
		else
			say "${FILETEMP} does not exist"
		fi
		remove_filefolder ${SOFTHOME}/node
		set_filefolder_owner ${SOFT}:${SOFT} ${SOFTHOME}
	# clean
		remove_filefolder /var/cache/apk/*
		remove_filefolder /tmp/*
	
	if [[ "$KIBANA" = "4" ]]; then
		$download_save /usr/share/${SOFT}/config/${SOFT}.yml $DOWN_URL/${SOFT}_config/4/${SOFT}.yml
		downloadentrypoint
	else
		downloadentrypoint
	fi

	# clean
		remove_download_tool
		clean_package
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi