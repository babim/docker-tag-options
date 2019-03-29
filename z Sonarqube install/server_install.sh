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
		export OPENJDKV=${OPENJDKV:-8}
		export ORACLEV=8
		export JAVA_HOME=/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre
		export PATH=$PATH:/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre/bin:/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/bin
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Atlassian"
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
	if [ "${COMMERCIAL}" = "true" ]; then
		wget -O /tmp/${SOFT}.zip https://binaries.sonarsource.com/CommercialDistribution/sonarqube-${EDITTION}/sonarqube-${EDITTION}-${SONAR_VERSION}.zip
	else
		wget -O /tmp/${SOFT}.zip https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip
	fi
	## and extract source software
		unzip /tmp/${SOFT}.zip -d /tmp
		rm -rf ${SONARQUBE_HOME} && rm -rf /tmp/${SOFT}.zip
		mv /tmp/sonarqube-$SONAR_VERSION ${SONARQUBE_HOME}
	# Install sonarqube and helper tools and setup initial home
	## directory structure.
#		[[ -d "${SONARQUBE_HOME}" ]]		&& chmod -R 700            "${SONARQUBE_HOME}"
		[[ -d "${SONARQUBE_HOME}" ]]		&& chown -R daemon:daemon  "${SONARQUBE_HOME}"
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
#		apk add --no-cache curl
	# install gosu
		installgosu
	# Install sonarqube
		installsonarqube
		dockerentry
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
#		apt-get install --quiet --yes --no-install-recommends curl
	# install gosu
		installgosu
	# Install sonarqube
		installsonarqube
		dockerentry
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