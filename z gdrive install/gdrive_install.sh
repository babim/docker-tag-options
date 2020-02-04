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
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20gdrive%20install"
	export DRIVE_PATH=${DRIVE_PATH:-/mnt/gdrive}
# uninstall app after install
	export UNINSTALL=""
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
	# install depend
		install_package gnupg
	# install google-drive-ocamlfuse
		echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list
		echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F639B041
		apt-get update
		apt-get install -yy google-drive-ocamlfuse fuse
		echo "user_allow_other" >> /etc/fuse.conf
	# finish
		rm /var/log/apt/* /var/log/alternatives.log /var/log/bootstrap.log /var/log/dpkg.log
		finish
else
    say_err "Not support your OS"
    exit 1
fi