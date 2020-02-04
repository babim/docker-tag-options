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

# set loop
setenvironment() {
# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20acdcli%20install"
# uninstall app after install
	export UNINSTALL="git"
}
#install acdcli
installacdcli() {
	pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git
}
#install webdav
installwebdav() {
	install_package lighttpd lighttpd-mod_webdav lighttpd-mod_auth apache2-utils
## download webdav
	FILETEMP=webdav.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
}
# finish after install app
finish() {
## download entrypoint
	FILETEMP=entrypoint.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
## clean
	clean_package
	clean_os	
}

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		debian_cmd_interface
	# install python 3, fuse, and git
		install_package python3 python3-appdirs python3-dateutil python3-requests python3-sqlalchemy python3-pip git
	# install acdcli
		installacdcli
	# webdav
		check_value_true "${WEBDAV_OPTION}" && installwebdav
	# finish
		finish
elif [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
	# create dirs for the config, local mount point, and cloud destination
		#mkdir /config /cache /data /cloud
		create_folders /cache /data /cloud
	# set the cache, settings, and libfuse path accordingly
		export ACD_CLI_CACHE_PATH=/cache
		export ACD_CLI_SETTINGS_PATH=/cache
		export LIBFUSE_PATH=/usr/lib/libfuse.so.2
	# install python 3, fuse, and git
		install_package python3 fuse git && pip3 install --upgrade pip
	# install acd_cli
		installacdcli
	# webdav
		check_value_true "${WEBDAV_OPTION}" && installwebdav
	# finish
		finish
else
    say_err "Not support your OS"
    exit 1
fi