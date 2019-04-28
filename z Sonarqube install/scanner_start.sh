#!/usr/bin/env bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# environment
	export auser=${auser:-daemon}
	export aguser=${aguser:-daemon}
	export agid=${agid:-$auid}
	export SERVER=${SERVER:-sonarqube}
	export SQLSERVER=${SQLSERVER:-sonarqube}
	export SQLTYPE=${SQLTYPE:-"h2"}
	export PROJECTKEY=${PROJECTKEY:-Test}
	export PROJECTNAME=${PROJECTNAME:-Test}
	export PROJECTVERSION=${PROJECTVERSION:-1}
		if [ "${SQLSERVER}" = "mysql" ]; then
			if [[ -z "${SQLOPTION1}" ]]; then export SQLOPTION1="//";fi
			if [[ -z "${SQLOPTION2}" ]]; then export SQLOPTION2="?useUnicode=true&amp;characterEncoding=utf8";fi
			if [[ -z "${SQLPORT}" ]]; then export SQLPORT=":3006";fi
			if [[ -z "${SQLUSER}" ]]; then export SQLUSER="sonar";fi
		elif [ "${SQLSERVER}" = "oracle" ]; then
			if [[ -z "${SQLOPTION1}" ]]; then export SQLOPTION1="thin:@";fi
			if [[ -z "${SQLOPTION2}" ]]; then export SQLOPTION2="/XE";fi
		elif [ "${SQLSERVER}" = "sqlserver" ]; then
			if [[ -z "${SQLOPTION1}" ]]; then export SQLOPTION1="//";fi
			if [[ -z "${SQLOPTION2}" ]]; then export SQLOPTION2=";SelectMethod=Cursor";fi
			if [[ -z "${SQLUSER}" ]]; then export SQLUSER="sonar";fi
		elif [ "${SQLSERVER}" = "postgresql" ]; then
			if [[ -z "${SQLOPTION1}" ]]; then export SQLOPTION1="//";fi
			if [[ -z "${SQLUSER}" ]]; then export SQLUSER="sonar";fi
		elif [ "${SQLSERVER}" = "h2" ]; then
			if [[ -z "${SQLOPTION1}" ]]; then export SQLOPTION1="tcp://";fi
			if [[ -z "${SQLUSER}" ]]; then export SQLUSER="sonar";fi
		fi

# cat config file
if [ ! -f "${SONARQUBE_HOME}/conf/sonar-scanner.properties" ]; then 
	cat <<EOF>> ${SONARQUBE_HOME}/conf/sonar-scanner.properties
#Configure here general information about the environment, such as SonarQube DB details for example
#No information about specific project should appear here

#----- Default SonarQube server
sonar.host.url=http://${SERVER}:${PORT}

#----- Default source code encoding
#sonar.sourceEncoding=UTF-8

#----- Global database settings (not used for SonarQube 5.2+)
#sonar.jdbc.username=sonar
#sonar.jdbc.password=sonar

#----- PostgreSQL
#sonar.jdbc.url=jdbc:postgresql://localhost/sonar

#----- MySQL
#sonar.jdbc.url=jdbc:mysql://localhost:3306/sonar?useUnicode=true&amp;characterEncoding=utf8

#----- Oracle
#sonar.jdbc.url=jdbc:oracle:thin:@localhost/XE

#----- Microsoft SQLServer
#sonar.jdbc.url=jdbc:jtds:sqlserver://localhost/sonar;SelectMethod=Cursor

# H2 database from Docker Sonar container
#sonar.jdbc.url=jdbc:h2:tcp://sonarqube/sonar

# Connect to database and sonarqube server
sonar.jdbc.url=jdbc:${SQLTYPE}:${SQLOPTION1}${SQLSERVER}${SQLPORT}/${SQLUSER}${SQLOPTION2}
sonar.projectKey=${PROJECTKEY}
sonar.projectName=${PROJECTNAME}
sonar.projectVersion=${PROJECTVERSION}
sonar.projectBaseDir=/source
sonar.sources=./

# Exclude node_modules for JS/TS-based scanning
sonar.exclusions=**/node_modules/**/*
EOF
fi

# command group
runscannerroot() {
	[[ -d "${SONARQUBE_HOME}" ]] && chown -R ${auser}:${aguser} "${SONARQUBE_HOME}"
	sonar-scanner -Dsonar.projectBaseDir=/source
}
runscanner() {
	[[ -d "${SONARQUBE_HOME}" ]] && chown -R ${auser}:${aguser} "${SONARQUBE_HOME}"
	gosu $auser sonar-scanner -Dsonar.projectBaseDir=/source
}

# check and run
	if [[ -z "${auid}" ]] || [[ "$auid" == "1" ]]; then
		echo "start"
		# run
		runscanner
	elif [[ "$auid" == "0" ]] || [[ "$aguid" == "0" ]]; then
		echo "run in user root"
		export auser=root
		# run
		runscannerroot
	elif id $auid >/dev/null 2>&1; then
	        echo "UID exists. Please change UID"
		sleep 30
		exit
	else
		if id $auser >/dev/null 2>&1; then
		        echo "user exists"
			if [[ -f /etc/alpine-release ]]; then
			# usermod alpine
				deluser $auser && delgroup $auser
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# usermod ubuntu/debian
				usermod -u $auid $auser
				groupmod -g $agid $aguser
			fi
			# run
			sleep 3
			runscanner
		else
			if [[ -f /etc/alpine-release ]]; then
			# create user alpine
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# create user ubuntu/debian
				groupadd -g $agid $aguser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $aguser $auser
			fi
			# run
			sleep 3
			runscanner
		fi
	fi