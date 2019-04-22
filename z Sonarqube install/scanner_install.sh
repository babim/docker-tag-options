#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
set -u
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
		export SOFT=${SOFT:-server}
		export auser=${auser:-daemon}
		export aguser=${aguser:-daemon}
		export OPENJDKV=${OPENJDKV:-8}
		export ORACLEV=8
		export JAVA_HOME=/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre
		export PATH=$PATH:/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre/bin:/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/bin
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Sonarqube%20install"
}
# set command install
installsonarqube() {
	## Check version
		if has_empty "${SONAR_VERSION}" || has_empty "${SONARQUBE_HOME}"; then
			say "Can not install without version. Please check and rebuild"
			exit 1
		fi
	## download version software
		say "downloading and install sonarqube..."
		$download_save /tmp/${SOFT}.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}-linux.zip
	## and extract source software
		unzip_extract /tmp/${SOFT}.zip /tmp
		remove_filefolder ${SONARQUBE_HOME} /tmp/${SOFT}.zip
		mv /tmp/sonar-scanner-$SONAR_VERSION-linux ${SONARQUBE_HOME}
	# Install sonarqube and helper tools and setup initial home
	## directory structure.
#		set_filefolder_owner 700				"${SONARQUBE_HOME}"
		set_filefolder_owner ${auser}:${aguser}		"${SONARQUBE_HOME}"
	## clear properties config file
		FILETEMP=${SONARQUBE_HOME}/conf/sonar-scanner.properties
			remove_file $FILETEMP
}
dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
			remove_file $FILETEMP
			$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
			set_filefolder_mod +x $FILETEMP
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
		install_java_jre
			echo "Install depend packages..."
		install_package grep sed unzip bash nodejs nodejs-npm
	# install gosu
		install_gosu
	# Install sonarqube
		installsonarqube
	# ensure Sonar uses the provided Java for musl instead of a borked glibc one
		sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' ${SONARQUBE_HOME}/bin/sonar-scanner
	# download entrypoint
		dockerentry
	# clean
		remove_download_tool
		clean_os
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		debian_cmd_interface
	# install depend
		install_java_jre
			echo "Install depend packages..."
		install_package nodejs build-essential
	# install gosu
		install_gosu
	# Install sonarqube
		installsonarqube
	# download entrypoint
		dockerentry
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