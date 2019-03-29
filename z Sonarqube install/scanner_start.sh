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