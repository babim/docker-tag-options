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
		export SOFT=${SOFT:-confluence}
#		export SOFTSUB=${SOFTSUB:-core}
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
	## update mysql connector
	FILELIB="${SOFT_INSTALL}/${SOFT}/WEB-INF/lib"
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
	## set permission path
		[[ -d "${SOFT_INSTALL}/conf" ]] && chmod -R 700            "${SOFT_INSTALL}/conf"
		[[ -d "${SOFT_INSTALL}/logs" ]] && chmod -R 700            "${SOFT_INSTALL}/logs"
		[[ -d "${SOFT_INSTALL}/temp" ]] && chmod -R 700            "${SOFT_INSTALL}/temp"
		[[ -d "${SOFT_INSTALL}/work" ]] && chmod -R 700            "${SOFT_INSTALL}/work"
		[[ -d "${SOFT_INSTALL}/conf" ]] && chown -R daemon:daemon  "${SOFT_INSTALL}/conf"
		[[ -d "${SOFT_INSTALL}/logs" ]] && chown -R daemon:daemon  "${SOFT_INSTALL}/logs"
		[[ -d "${SOFT_INSTALL}/temp" ]] && chown -R daemon:daemon  "${SOFT_INSTALL}/temp"
		[[ -d "${SOFT_INSTALL}/work" ]] && chown -R daemon:daemon  "${SOFT_INSTALL}/work"
		echo -e                 "\n${SOFT}.home=${SOFT_HOME}" >> "${SOFT_INSTALL}/${SOFT}/WEB-INF/classes/${SOFT}-init.properties"
		# xmlstarlet
	if [[ -f ${SOFT_INSTALL}/conf/server.xml ]]; then
    		xmlstarlet		ed --inplace \
        	  --delete		"Server/@debug" \
		  --delete		"Server/Service/Connector/@debug" \
		  --delete		"Server/Service/Connector/@useURIValidationHack" \
		  --delete		"Server/Service/Connector/@minProcessors" \
		  --delete		"Server/Service/Connector/@maxProcessors" \
		  --delete		"Server/Service/Engine/@debug" \
		  --delete		"Server/Service/Engine/Host/@debug" \
		  --delete		"Server/Service/Engine/Host/Context/@debug" \
					"${SOFT_INSTALL}/conf/server.xml"
	fi
		# xmlstarlet end
		[[ -f "${SOFT_INSTALL}/conf/server.xml" ]] && touch -d "@0"           "${SOFT_INSTALL}/conf/server.xml"
		chown daemon:daemon	"${JAVA_CACERTS}"
	# fix path start file
		[[ -f "${SOFT_INSTALL}/bin/start_${SOFT}.sh" ]] && mv "${SOFT_INSTALL}/bin/start_${SOFT}.sh" "${SOFT_INSTALL}/bin/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/bin/start-${SOFT}.sh"
		[[ -f "${SOFT_INSTALL}/start_${SOFT}.sh" ]] && mv "${SOFT_INSTALL}/start_${SOFT}.sh" "${SOFT_INSTALL}/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/start-${SOFT}.sh"
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
			echo "Can not install openjdk${OPENJDKV}, please check and rebuild"
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
			echo "Can not install openjdk, please check and rebuild"
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
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    echo "Not support your OS"
    exit
# OS - other
else
    echo "Not support your OS"
    exit
fi