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
		export aguser=${aguser:-daemon}
		export SERVER=${SERVER:-sonarqube}
		export SQLSERVER=${SQLSERVER:-sonarqube}
		export SQLUSER=${SQLUSER:-sonar}
		export SQLTYPE=${SQLTYPE:-h2}
		export PROJECTKEY=${PROJECTKEY:-Test}
		export PROJECTNAME=${PROJECTNAME:-Test}
		export PROJECTVERSION=${PROJECTVERSION:-1}

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
#sonar.projectKey=MyProjectKey
#sonar.projectName=My Project Name
#sonar.projectVersion=1
#sonar.projectBaseDir=/root/src
#sonar.sources=./

# Connect to database and sonarqube server
sonar.jdbc.url=jdbc:${SQLTYPE}:tcp://${SQLSERVER}/${USER}
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
	if [[ -z "${auid}" ]]; then
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