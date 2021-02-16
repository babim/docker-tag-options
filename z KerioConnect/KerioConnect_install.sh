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
	export SOFT=${SOFT:-KerioConnect}
	#export SOFTSUB=${SOFTSUB:-core}
	export KERIO_CONNECT_NOT_RUN=yes
# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20${SOFT}"
}

# install by OS
echo 'Check OS'
# OS - Debian linux
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		installfonts
	# Set frontend debian
		debian_cmd_interface
	# install depend
		say "Install depend packages..."
		update_os
		install_package wget cryptsetup dnsutils sysstat lsof
	test $KERBEROS=yes	&& (say "install kerberos"; install_package krb5-kdc krb5-admin-server) || say "no install kerberos"
	# Download Kerio Connect
	FILETEMP=kerio-connect-linux-64bit.deb
	test $FIXED=no		&& (check_file "${FILETEMP}" && say_warning "${FILETEMP} exist" || $download_save "${FILETEMP}" "http://download.kerio.com/dwn/${FILETEMP}") || (check_file "${FILETEMP}" && say_warning "${FILETEMP} exist" || $download_save "${FILETEMP}" "http://file.matmagoc.com/${FILETEMP}")
	# Install Kerio Connect
    		dpkg -i ${FILETEMP} || true && apt-get install -f
	# Set kerberos
	test $KERBEROS=yes	&& (say "set kerberos"; mv /etc/krb5.conf /opt/kerio/krb5.conf && ln -sf /opt/kerio/krb5.conf /etc/krb5.conf)
	## Set service ##
		dpkg --fsys-tarfile ${FILETEMP} | tar xOf - ./etc/init.d/kerio-connect > /etc/init.d/kerio-connect
		chmod +x /etc/init.d/kerio-connect && rm -f ${FILETEMP}
	## Prepare start ##
	## mkdir -p /opt-start/kerio && rsync -arvpz --numeric-ids /opt/kerio/ /opt-start/kerio && rm -rf /opt/kerio/*
		create_folder /opt-start && mv /opt/kerio /opt-start
	# Download Kerio Connect
	FILETEMP=start.sh
		say "Download start script..."
		check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save "${FILETEMP}" "${DOWN_URL}/${SOFT}_${FILETEMP}"
		say "Set start script permission..."
		set_filefolder_mod 755 "${FILETEMP}"				&& say "set done" || say_warning "file/folder not exist"
	# clean
		remove_download_tool
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    say_err "Not support your OS"
    exit 1
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
