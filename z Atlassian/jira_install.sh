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
		export OPENJDKV=${OPENJDKV:-8}
		export POSTGRESQLV=42.2.5
		export MYSQLV=5.1.47
		export MSSQLV=7.2.1.jre8
		export ORACLEV=8
		export JAVA_HOME=/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre
		export PATH=$PATH:/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre/bin:/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/bin
}
# set command install
installatlassian() {
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Atlassian"
	## Check version
		if [[ -z "${SOFT_VERSION}" ]] || [[ -z "${SOFT_HOME}" ]] || [[ -z "${SOFT_INSTALL}" ]]; then
			echo "Can not install without version. Please check and rebuild"
			exit
		fi
	# Install Atlassian JIRA and helper tools and setup initial home
	## directory structure.
		mkdir -p                "${SOFT_HOME}/caches/indexes"
		chmod -R 700            "${SOFT_HOME}"
		chown -R daemon:daemon  "${SOFT_HOME}"
		mkdir -p                "${SOFT_INSTALL}/conf/Catalina"
	## download and extract source software
		echo "downloading and install atlassian"
		curl -Ls "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-${SOFT_VERSION}.tar.gz" | tar -xz --directory "${SOFT_INSTALL}" --strip-components=1 --no-same-owner
	## update mysql connector
	FILETEMP="${SOFT_INSTALL}/lib/mysql-connector-java-*.jar"
	[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		echo "downloading and install mysql-connector-java"
		curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQLV}.tar.gz" | tar -xz --directory "${SOFT_INSTALL}/lib" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQLV}/mysql-connector-java-${MYSQLV}-bin.jar"
	## update postgresql connector
	FILETEMP="${SOFT_INSTALL}/lib/postgresql-*.jar"
	[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		echo "downloading and install postgresql-connector-java"
		curl -Ls "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQLV}.jar" -o "${SOFT_INSTALL}/lib/postgresql-${POSTGRESQLV}.jar"
	## update mssql-server connector
	FILETEMP="${SOFT_INSTALL}/lib/mssql-jdbc-*.jar"
	[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		echo "downloading and install mssql-jdbc"
		curl -Ls "${DOWN_URL}/connector/mssql-jdbc-${MSSQLV}.jar" -o "${SOFT_INSTALL}/lib/mssql-jdbc-${MSSQLV}.jar"
	## update oracle database connector
	FILETEMP="${SOFT_INSTALL}/lib/ojdbc*.jar"
	[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		echo "downloading and install oracle-ojdbc"
		curl -Ls "${DOWN_URL}/connector/ojdbc${ORACLEV}.jar" -o "${SOFT_INSTALL}/lib/ojdbc${ORACLEV}.jar"
	## set permission path
		chmod -R 700            "${SOFT_INSTALL}/conf"
		chmod -R 700            "${SOFT_INSTALL}/logs"
		chmod -R 700            "${SOFT_INSTALL}/temp"
		chmod -R 700            "${SOFT_INSTALL}/work"
		chown -R daemon:daemon  "${SOFT_INSTALL}/conf"
		chown -R daemon:daemon  "${SOFT_INSTALL}/logs"
		chown -R daemon:daemon  "${SOFT_INSTALL}/temp"
		chown -R daemon:daemon  "${SOFT_INSTALL}/work"
		sed --in-place          "s/java version/openjdk version/g" "${SOFT_INSTALL}/bin/check-java.sh"
		echo -e                 "\njira.home=$SOFT_HOME" >> "${SOFT_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties"
		touch -d "@0"           "${SOFT_INSTALL}/conf/server.xml"
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_start.sh
		chmod +x $FILETEMP
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
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then apk add --no-cache openjdk${OPENJDKV}; fi
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then 
			echo "Can not install openjdk, please check and rebuild"
			exit
		fi
		apk add --no-cache curl xmlstarlet ttf-dejavu libc6-compat tar sudo
	# Install Atlassian
		installatlassian
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# install depend
		apt-get update
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then apt-get install --quiet --yes openjdk8; fi
		if [ ! -d "/usr/lib/jvm/java-1.${OPENJDKV}-openjdk/jre" ]; then 
			echo "Can not install openjdk, please check and rebuild"
			exit
		fi
		apt-get install --quiet --yes --no-install-recommends curl ttf-dejavu libtcnative-1 xmlstarlet
	# Install Atlassian
		installatlassian
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    echo "Not support your OS"
    exit
# OS - other
else
    echo "Not support your OS"
    exit
fi