#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# source from bash library
source <(curl -s https://example.com/script.sh)

# need root to run
	require_root

# set environment
setenvironment() {
		export SOFT=${SOFT:-bamboo}
		#export SOFTSUB=${SOFTSUB:-core}
		export auser=${auser:-daemon}
		export aguser=${aguser:-daemon}
		export POSTGRESQLV=42.2.5
		export MYSQLV=5.1.47
		export MSSQLV=7.2.1.jre8
		export ORACLEV=8
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Atlassian"
}
# install gosu
	install_gosu
# set command install
installatlassian() {
	## Check version
		if [[ -z "${SOFT_VERSION}" ]] || [[ -z "${SOFT_HOME}" ]] || [[ -z "${SOFT_INSTALL}" ]]; then
			echo "Can not install without version. Please check and rebuild"
			exit
		fi
	# Install Atlassian JIRA and helper tools and setup initial home
	## directory structure.
		create_folder                		"${SOFT_HOME}"
		set_filefolder_mod 700            	"${SOFT_HOME}"
		set_filefolder_owner ${auser}:${aguser}	"${SOFT_HOME}"
		create_folder                		"${SOFT_INSTALL}"
	## download and extract source software
		echo "downloading and install atlassian..."
		curl -Ls "https://www.atlassian.com/software/${SOFT}/downloads/binary/atlassian-${SOFT}-${SOFT_VERSION}.tar.gz" | tar -xz --directory "${SOFT_INSTALL}" --strip-components=1 --no-same-owner
	## update mysql connector
	FILELIB="${SOFT_INSTALL}/lib"
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
		[[ -d "${SOFT_INSTALL}/conf" ]] && chmod -R 700            	"${SOFT_INSTALL}/conf"
		[[ -d "${SOFT_INSTALL}/logs" ]] && chmod -R 700            	"${SOFT_INSTALL}/logs"
		[[ -d "${SOFT_INSTALL}/temp" ]] && chmod -R 700            	"${SOFT_INSTALL}/temp"
		[[ -d "${SOFT_INSTALL}/work" ]] && chmod -R 700            	"${SOFT_INSTALL}/work"
		[[ -d "${SOFT_INSTALL}/conf" ]] && chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/conf"
		[[ -d "${SOFT_INSTALL}/logs" ]] && chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/logs"
		[[ -d "${SOFT_INSTALL}/temp" ]] && chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/temp"
		[[ -d "${SOFT_INSTALL}/work" ]] && chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/work"
		[[ -f "${SOFT_INSTALL}/bin/setenv.sh" ]] && sed --in-place 's/^# umask 0027$/umask 0027/g' "${SOFT_INSTALL}/bin/setenv.sh"
		# xmlstarlet
	if [[ -f ${SOFT_INSTALL}/conf/server.xml ]]; then
		xmlstarlet		ed --inplace \
		  --delete		"Server/Service/Engine/Host/@xmlValidation" \
		  --delete		"Server/Service/Engine/Host/@xmlNamespaceAware" \
					"${SOFT_INSTALL}/conf/server.xml"
	fi
		# xmlstarlet end
		[[ -f "${SOFT_INSTALL}/conf/server.xml" ]] && touch -d "@0"	"${SOFT_INSTALL}/conf/server.xml"
	# fix path start file
		[[ -f "${SOFT_INSTALL}/bin/start_${SOFT}.sh" ]] && mv "${SOFT_INSTALL}/bin/start_${SOFT}.sh" "${SOFT_INSTALL}/bin/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/bin/start-${SOFT}.sh"
		[[ -f "${SOFT_INSTALL}/start_${SOFT}.sh" ]] && mv "${SOFT_INSTALL}/start_${SOFT}.sh" "${SOFT_INSTALL}/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/start-${SOFT}.sh"
}
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
		apk add --no-cache curl xmlstarlet ttf-dejavu libc6-compat git openssh
	# visible code
	if [ "${VISIBLECODE}" = "true" ]; then
		# install gosu
		installgosu
	fi
	# Install Atlassian
		installatlassian
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
		apt-get install --quiet --yes --no-install-recommends curl ttf-dejavu libtcnative-1 xmlstarlet git openssh-client
	# visible code
	if [ "${VISIBLECODE}" = "true" ]; then
		# install gosu
		installgosu
	fi
	# Install Atlassian
		installatlassian
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