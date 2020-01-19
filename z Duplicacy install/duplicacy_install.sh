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
	export SOFT=${SOFT:-duplicacy}
	export VERSION_DUPLICACY=${VERSION_DUPLICACY:-2.3.0  }
#		export SOFTSUB=${SOFTSUB:-core}
	export VERSION_DUPLICACY_WEB=${VERSION_DUPLICACY_WEB:-1.1.0}
	export ARCHITECTURE=${ARCHITECTURE:-linux_x64}
	export _URL_DUPLICACY="$(                                                                \
      printf https://github.com/gilbertchen/duplicacy/releases/download/v%s/duplicacy_%s_%s      \
      $VERSION_DUPLICACY $ARCHITECTURE $VERSION_DUPLICACY                                        \
    )"
	export _URL_DUPLICACY_WEB="$(                                                            \
      printf https://acrosync.com/duplicacy-web/duplicacy_web_%s_%s                              \
      $ARCHITECTURE $VERSION_DUPLICACY_WEB                                                       \
    )"
	export _BIN_DUPLICACY=/usr/local/bin/duplicacy
	export _BIN_DUPLICACY_WEB=/usr/local/bin/duplicacy_web
	export _DIR_WEB=~/.duplicacy-web
	export _DIR_CONF=/etc/duplicacy
	export _DIR_CACHE=/var/cache/duplicacy  

# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Duplicacy%20install"
}
# set command install
installduplicacy() {
# download, check, and install duplicacy
    FILETEMP="$_BIN_DUPLICACY"
    check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save "${FILETEMP}" "$_URL_DUPLICACY"
    chmod +x "${FILETEMP}"

    # downlooad, check, and install the web UI
    FILETEMP="$_BIN_DUPLICACY_WEB"
    check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save "${FILETEMP}" "$_URL_DUPLICACY_WEB"
    chmod +x "${FILETEMP}"

    # create some dirs
    create_folders ${_DIR_CACHE}/repositories ${_DIR_CACHE}/stats ${_DIR_WEB}/bin /var/lib/dbus

    # duplicacy_web expects to find the CLI binary in a certain location
    # https://forum.duplicacy.com/t/run-web-ui-in-a-docker-container/1505/2
    ln -s $_BIN_DUPLICACY ${_DIR_WEB}/bin/duplicacy_${ARCHITECTURE}_${VERSION_DUPLICACY}

    # redirect the log to stdout
    ln -s /dev/stdout /var/log/duplicacy_web.log

    # stage the rest of the web directory
    ln -s ${_DIR_CONF}/settings.json  ${_DIR_WEB}/settings.json
    ln -s ${_DIR_CONF}/duplicacy.json ${_DIR_WEB}/duplicacy.json
    ln -s ${_DIR_CONF}/licenses.json  ${_DIR_WEB}/licenses.json
    ln -s ${_DIR_CONF}/filters        ${_DIR_WEB}/filters
    ln -s ${_DIR_CACHE}/stats         ${_DIR_WEB}/stats

# download docker entry
    FILETEMP=/docker-entrypoint.sh
    $download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
    chmod +x "${FILETEMP}"
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
			echo "Install depend packages..."
		install_package ca-certificates
	# Install
		installduplicacy
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		debian_cmd_interface
	# install depend
			echo "Install depend packages..."
		install_package ca-certificates
	# Install
		installduplicacy
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    say_err "Not support your OS"
    exit 1
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi