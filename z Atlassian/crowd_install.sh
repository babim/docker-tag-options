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
		export SOFT=${SOFT:-crowd}
		#export SOFTSUB=${SOFTSUB:-core}	
		export OPENJDKV=${OPENJDKV:-8}
		export POSTGRESQLV=42.2.5
		export MYSQLV=5.1.47
		export MSSQLV=7.2.1.jre8
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
installatlassian() {
	## Check version
		if [[ -z "${SOFT_VERSION}" ]] || [[ -z "${SOFT_HOME}" ]] || [[ -z "${SOFT_INSTALL}" ]]; then
			echo "Can not install without version. Please check and rebuild"
			exit
		fi
	# Install Atlassian JIRA and helper tools and setup initial home
	## directory structure.
		[[ ! -d "${SOFT_HOME}" ]]		&& mkdir -p                "${SOFT_HOME}"
		[[ -d "${SOFT_HOME}" ]]			&& chmod -R 700            "${SOFT_HOME}"
		[[ -d "${SOFT_HOME}" ]]			&& chown -R daemon:daemon  "${SOFT_HOME}"
		[[ ! -d "${SOFT_INSTALL}" ]]		&& mkdir -p                "${SOFT_INSTALL}"
	## download and extract source software
		echo "downloading and install atlassian..."
		curl -Ls "https://www.atlassian.com/software/${SOFT}/downloads/binary/atlassian-${SOFT}-${SOFT_VERSION}.tar.gz" | tar -xz --directory "${SOFT_INSTALL}" --strip-components=1 --no-same-owner
		mkdir -p ${SOFT_HOME} && \
		mkdir -p ${SOFT_INSTALL}/crowd-webapp/WEB-INF/classes && \
		mkdir -p ${SOFT_INSTALL}/apache-tomcat/lib && \
		mkdir -p ${SOFT_INSTALL}/apache-tomcat/webapps/ROOT && \
		mkdir -p ${SOFT_INSTALL}/apache-tomcat/conf/Catalina/localhost && \
		echo "crowd.home=${SOFT_HOME}" > ${SOFT_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties
	## update mysql connector
	FILELIB="${SOFT_INSTALL}/apache-tomcat/lib"
	FILETEMP="${FILELIB}/mysql-connector-java-*.jar"
	[[ -f $FILETEMP ]] && rm -f $FILETEMP
		echo "downloading and update mysql-connector-java..."
		curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQLV}.tar.gz" | tar -xz --directory "${FILELIB}" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQLV}/mysql-connector-java-${MYSQLV}-bin.jar"
	## update postgresql connector
	FILETEMP="${FILELIB}/postgresql-*.jar"
	[[ -f $FILETEMP ]] && rm -f $FILETEMP
		echo "downloading and update postgresql-connector-java..."
		curl -Ls "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQLV}.jar" -o "${FILELIB}/postgresql-${POSTGRESQLV}.jar"
	## update mssql-server connector
	FILETEMP="${FILELIB}/mssql-jdbc-*.jar"
	[[ -f $FILETEMP ]] && rm -f $FILETEMP
		echo "downloading and update mssql-jdbc..."
		curl -Ls "${DOWN_URL}/connector/mssql-jdbc-${MSSQLV}.jar" -o "${FILELIB}/mssql-jdbc-${MSSQLV}.jar"
	## update oracle database connector
	FILETEMP="${FILELIB}/ojdbc*.jar"
	[[ -f $FILETEMP ]] && rm -f $FILETEMP
		echo "downloading and update oracle-ojdbc..."
		curl -Ls "${DOWN_URL}/connector/ojdbc${ORACLEV}.jar" -o "${FILELIB}/ojdbc${ORACLEV}.jar"
		# xmlstarlet
		[[ -f "${SOFT_INSTALL}/apache-tomcat/bin/setenv.sh" ]]	&& sed --in-place 's/^# umask 0027$/umask 0027/g' "${SOFT_INSTALL}/apache-tomcat/bin/setenv.sh"
	if [[ -f ${SOFT_INSTALL}/conf/server.xml ]]; then
		xmlstarlet		ed --inplace \
		  --delete		"Server/Service/Engine/Host/@xmlValidation" \
		  --delete		"Server/Service/Engine/Host/@xmlNamespaceAware" \
					"${SOFT_INSTALL}/conf/server.xml"
	fi
		# xmlstarlet end
		[[ -f "${SOFT_INSTALL}/conf/server.xml" ]]		&& touch -d "@0"	"${SOFT_INSTALL}/conf/server.xml"
	# fix path start file
		[[ -f "${SOFT_INSTALL}/bin/start_${SOFT}.sh" ]]		&& mv "${SOFT_INSTALL}/bin/start_${SOFT}.sh" "${SOFT_INSTALL}/bin/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/bin/start-${SOFT}.sh"
		[[ -f "${SOFT_INSTALL}/start_${SOFT}.sh" ]]		&& mv "${SOFT_INSTALL}/start_${SOFT}.sh" "${SOFT_INSTALL}/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/start-${SOFT}.sh"
	## set permission path
		[[ -d "${SOFT_INSTALL}/apache-tomcat/conf" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/conf"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/logs" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/logs"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/temp" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/temp"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/work" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/work"
		[[ -d "${SOFT_HOME}" ]]					&& chown -R daemon:daemon  "${SOFT_HOME}"
		[[ -d "${SOFT_INSTALL}" ]]				&& chown -R daemon:daemon  "${SOFT_INSTALL}"
dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		# visible code
		if [ "${VISIBLECODE}" = "true" ]; then
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_fixed.sh
		else
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_start.sh
		fi
		chmod +x $FILETEMP
}
cleanpackage() {
	# remove packages
		wget --no-check-certificate -O - $DOWN_URL/${SOFT}_clean.sh | bash
}
preparedata() {
	if [ "${VISIBLECODE}" = "true" ]; then
		mkdir -p /etc-start && mv ${SOFT_INSTALL} /etc-start/${SOFT}
	fi
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
		apk add --no-cache curl xmlstarlet ttf-dejavu libc6-compat
	# visible code
	if [ "${VISIBLECODE}" = "true" ]; then
		# install gosu
		installgosu
	fi
	# Install Atlassian
		installatlassian
		dockerentry
		preparedata
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
		apt-get install --quiet --yes --no-install-recommends curl ttf-dejavu libtcnative-1 xmlstarlet
	# visible code
	if [ "${VISIBLECODE}" = "true" ]; then
		# install gosu
		installgosu
	fi
	# Install Atlassian
		installatlassian
		dockerentry
		preparedata
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