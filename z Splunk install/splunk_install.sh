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
	export SOFT=${SOFT:-splunk}
#		export SOFTSUB=${SOFTSUB:-core}
	export auser=${SPLUNK_USER:-splunk}
	export aguser=${SPLUNK_GROUP:-splunk}

# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Splunk%20install"
}
# set command install
splunk_adduser() {
# add splunk:splunk user
	groupadd -r ${SPLUNK_GROUP} \
	&& useradd -r -m -g ${SPLUNK_GROUP} ${SPLUNK_USER}
}
splunk_install() {
# Download official Splunk release, verify checksum and unzip in /opt/splunk
# Also backup etc folder, so it will be later copied to the linked volume
	mkdir -p ${SPLUNK_HOME} \
	&& wget -qO /tmp/${SPLUNK_FILENAME} https://download.splunk.com/products/${SPLUNK_PRODUCT}/releases/${SPLUNK_VERSION}/linux/${SPLUNK_FILENAME} \
	&& tar xzf /tmp/${SPLUNK_FILENAME} --strip 1 -C ${SPLUNK_HOME} \
	&& rm /tmp/${SPLUNK_FILENAME} \
	&& mkdir -p /var/opt/splunk \
	&& cp -R ${SPLUNK_HOME}/etc ${SPLUNK_BACKUP_DEFAULT_ETC} \
	&& rm -fR ${SPLUNK_HOME}/etc \
	&& chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_HOME} \
	&& chown -R ${SPLUNK_USER}:${SPLUNK_GROUP} ${SPLUNK_BACKUP_DEFAULT_ETC}
}
download_entry() {
## download entrypoint
	FILETEMP=start.sh
		$download_save /$FILETEMP $DOWN_URL/${SOFT}_${FILETEMP} && \
		set_filefolder_mod 755 /$FILETEMP
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
    say_err "Not support your OS"
    exit 1
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		debian_cmd_interface
	# install depend
		# make the "en_US.UTF-8" locale so splunk will be utf-8 enabled by default
			echo "Install depend packages..."
		install_package apt-utils locales libgssapi-krb5-2 wget sudo
		localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
	# Install splunk
		splunk_adduser
		splunk_install
		download_entry
	# visible code
		check_value_true "${VISIBLECODE}" && install_gosu
	# clean
		#remove_download_tool
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