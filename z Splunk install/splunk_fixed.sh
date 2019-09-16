#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# option with entrypoint
[[ -f "/option.sh" ]] && /option.sh

# set environment
	export SOFT=${SOFT:-confluence}
#		export SOFTSUB=${SOFTSUB:-core}
# set ID docker run
if [[ -f /etc/alpine-release ]]; then
	export auid=${auid:-2}
	export agid=${agid:-2}
	export auser=${auser:-daemon}
	export aguser=${aguser:-daemon}
else
	export auid=${auid:-1}
	export agid=${agid:-1}
	export auser=${auser:-daemon}
	export aguser=${aguser:-daemon}
fi

	if [[ -z "${auid}" ]] || [[ "$auid" == "1" ]] || [[ "$auid" == "2" ]]; then
		echo "start"
	elif [[ "$auid" == "0" ]] || [[ "$aguid" == "0" ]]; then
		echo "run in user root"
		export auser=root
	elif id $auid >/dev/null 2>&1; then
	        echo "UID exists. Please change UID"
	else
		if id $auser >/dev/null 2>&1; then
		        echo "user exists"
			if [[ -f /etc/alpine-release ]]; then
			# usermod alpine
				deluser $auser && delgroup $aguser
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# usermod ubuntu/debian
				usermod -u $auid $auser
				groupmod -g $agid $aguser
			fi
		else
		        echo "create user"
			if [[ -f /etc/alpine-release ]]; then
			# create user alpine
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# create user ubuntu/debian
				groupadd -g $agid $aguser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $aguser $auser
			fi
		fi
	fi

# visible code
	echo "check path and install"
	[[ ! -d "${SOFT_INSTALL}" ]]	&& 	mkdir -p ${SOFT_INSTALL}
	[[ -z "`ls ${SOFT_INSTALL}`" ]]	&& 	cp -R /etc-start/${SOFT}/* ${SOFT_INSTALL}/
	[[ ! -d "${SOFT_HOME}" ]]	&& 	mkdir -p "${SOFT_HOME}"
## set permission path
	[[ -d "${SOFT_HOME}" ]]		&&	chmod -R 700			"${SOFT_HOME}"
	[[ -d "${SOFT_HOME}" ]] 	&&	chown -R ${auser}:${aguser}	"${SOFT_HOME}"
	[[ -d "${SOFT_INSTALL}" ]] 	&&	chmod -R 755			"${SOFT_INSTALL}"
	[[ -d "${SOFT_INSTALL}/conf" ]] &&	chmod -R 700			"${SOFT_INSTALL}/conf"
	[[ -d "${SOFT_INSTALL}/logs" ]] &&	chmod -R 700			"${SOFT_INSTALL}/logs"
	[[ -d "${SOFT_INSTALL}/temp" ]] &&	chmod -R 700			"${SOFT_INSTALL}/temp"
	[[ -d "${SOFT_INSTALL}/work" ]] &&	chmod -R 700			"${SOFT_INSTALL}/work"
	[[ -d "${SOFT_INSTALL}/conf" ]] &&	chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/conf"
	[[ -d "${SOFT_INSTALL}/logs" ]] &&	chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/logs"
	[[ -d "${SOFT_INSTALL}/temp" ]] &&	chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/temp"
	[[ -d "${SOFT_INSTALL}/work" ]] &&	chown -R ${auser}:${aguser}	"${SOFT_INSTALL}/work"

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
	echo "set environment"
export CONFIGFILE=conf/server.xml
	if [ "$(stat -c "%Y" "${SOFT_INSTALL}/${CONFIGFILE}")" -eq "0" ]; then
	 	if [ -n "${X_PROXY_NAME}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8090"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${SOFT_INSTALL}/${CONFIGFILE}"'
		fi
		if [ -n "${X_PROXY_PORT}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8090"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/${CONFIGFILE}"'
		fi
		if [ -n "${X_PROXY_SCHEME}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8090"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${SOFT_INSTALL}/${CONFIGFILE}"'
		fi
		if [ "${X_PROXY_SCHEME}" = "https" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8090"]' --type "attr" --name "secure" --value "true" "${SOFT_INSTALL}/${CONFIGFILE}"'
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --update '//Connector[@port="8090"]/@redirectPort' --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/${CONFIGFILE}"'
		fi
		if [ -n "${X_PATH}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${SOFT_INSTALL}/${CONFIGFILE}"'
		fi
	fi

	echo "run app..."

# Run
gosu ${auser} "${SOFT_INSTALL}/bin/start-${SOFT}.sh" -fg