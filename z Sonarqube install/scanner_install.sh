#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# check permission root
echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

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
# install gosu
installgosu() {
	echo "Install gosu package..."
	wget --no-check-certificate -O - $DOWN_URL/gosu_install.sh | bash
}
# set command install
installsonarqube() {
	## Check version
		if [[ -z "${SONAR_VERSION}" ]] || [[ -z "${SONARQUBE_HOME}" ]]; then
			echo "Can not install without version. Please check and rebuild"
			exit
		fi
	## download version software
		echo "downloading and install sonarqube..."
		wget -O /tmp/${SOFT}.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}-linux.zip
	## and extract source software
		unzip /tmp/${SOFT}.zip -d /tmp
		rm -rf ${SONARQUBE_HOME} && rm -rf /tmp/${SOFT}.zip
		mv /tmp/sonar-scanner-$SONAR_VERSION-linux ${SONARQUBE_HOME}
	# Install sonarqube and helper tools and setup initial home
	## directory structure.
#		[[ -d "${SONARQUBE_HOME}" ]]		&& chmod -R 700				"${SONARQUBE_HOME}"
		[[ -d "${SONARQUBE_HOME}" ]]		&& chown -R ${auser}:${aguser}		"${SONARQUBE_HOME}"
	## clear properties config file
		FILETEMP=${SONARQUBE_HOME}/conf/sonar-scanner.properties
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
}
dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_start.sh
		chmod +x $FILETEMP
}
cleanpackage() {
	# remove packages
		wget --no-check-certificate -O - $DOWN_URL/${SOFT}_clean.sh | bash
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then 
			echo "installing openjdk..."
			apk add --no-cache openjdk${OPENJDKV}-jre
		fi
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then 
			echo "Can not install openjdk, please check and rebuild"
			exit
		fi
			echo "Install depend packages..."
		apk add --no-cache grep sed unzip bash nodejs nodejs-npm
	# install gosu
		installgosu
	# Install sonarqube
		installsonarqube
	# ensure Sonar uses the provided Java for musl instead of a borked glibc one
		sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' ${SONARQUBE_HOME}/bin/sonar-scanner
	# download entrypoint
		dockerentry
	# clean
		cleanpackage
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# install depend
		apt-get update
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then apt-get install --quiet --yes openjdk-${OPENJDKV}-jre; fi
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then 
			echo "Can not install openjdk${OPENJDKV}, please check and rebuild"
			exit
		fi
			echo "Install depend packages..."
		apt-get install --quiet --yes --no-install-recommends nodejs build-essential
	# install gosu
		installgosu
	# Install sonarqube
		installsonarqube
	# download entrypoint
		dockerentry
	# clean
		cleanpackage
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    echo "Not support your OS"
    exit
# OS - other
else
    echo "Not support your OS"
    exit
fi