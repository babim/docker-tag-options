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
	export SOFT=${SOFT:-IceWarp}
	#export SOFTSUB=${SOFTSUB:-core}
# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20${SOFT}"
}

# install by OS
echo 'Check OS'
# OS - Centos linux
if [[ -f /etc/redhat-release ]]; then
	# set environment
		installfonts
	# install depend
		say "Install depend packages..."
		install_epel && update_os
		install_package cryptsetup dnsutils sysstat lsof
	# install kerberos
	test $KERBEROS=yes	&& (say "install kerberos"; install_package krb5-server krb5-libs krb5-workstation) || say "no install kerberos"
	# install tools
		install_package htop nload
	# Download IceWarp
	FILETEMP="/icewarp-64bit.tar.gz"
	INSTALLTEMP="/install"
	INSTALLPATH="/opt/icewarp"
	test $FIXED=yes		&& (check_file "${FILETEMP}" && say_warning "${FILETEMP} exist" || $download_save "${FILETEMP}" "https://file.matmagoc.com${FILETEMP}") || say "Error! Without version from officical host"
	# Install IceWarp
    		mkdir ${INSTALLTEMP} && \
		tar xzf ${FILETEMP} --strip-components=1 -C ${INSTALLTEMP} ;\
		sed -i 's?>/dev/tty??' ${INSTALLTEMP}/platform ;\
		${INSTALLTEMP}/install.sh --auto --install-dir ${INSTALLPATH} && \
		${INSTALLPATH}/icewarpd.sh --stop ;\
		remove_folder ${INSTALLTEMP}
	# Set kerberos
	test $KERBEROS=yes	&& (say "set kerberos"; mv /etc/krb5.conf ${INSTALLPATH}/krb5.conf && ln -sf ${INSTALLPATH}/krb5.conf /etc/krb5.conf)
	## Prepare start ##
	## mkdir -p /opt-start/icewarp && rsync -arvpz --numeric-ids /opt/icewarp/ /opt-start/icewarp && rm -rf /opt/icewarp/*
		create_folder /opt-start && mv ${INSTALLPATH} /opt-start
	# Download IceWarp start entry
	FILETEMP=start.sh
		say "Download start script..."
		check_file /"${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save /"${FILETEMP}" "https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20IceWarp_${FILETEMP}"
		#say "Set start script permission..."
		set_filefolder_mod 755 "${FILETEMP}"				&& say "set done" || say_warning "file/folder not exist"
	# clean
		remove_download_tool
		clean_os
else
    say_err "Not support your OS"
    exit 1
fi
