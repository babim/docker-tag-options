#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# set environment
		export SOFT=${SOFT:-bitbucket}
		#export SOFTSUB=${SOFTSUB:-core}	
	## Check version
		if [[ -z "${SOFT_VERSION}" ]] || [[ -z "${SOFT_HOME}" ]] || [[ -z "${SOFT_INSTALL}" ]]; then
			echo "Can not run. Please check and rebuild"
			exit
		fi

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
	if [ "$(stat -c "%Y" "${SOFT_INSTALL}/conf/server.xml")" -eq "0" ]; then
	 	if [ -n "${X_PROXY_NAME}" ]; then
			xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="7990"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${SOFT_INSTALL}/conf/server.xml"
		fi
		if [ -n "${X_PROXY_PORT}" ]; then
			xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="7990"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/conf/server.xml"
		fi
		if [ -n "${X_PROXY_SCHEME}" ]; then
			xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="7990"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${SOFT_INSTALL}/conf/server.xml"
		fi
		if [ "${X_PROXY_SCHEME}" = "https" ]; then
			xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="7990"]' --type "attr" --name "secure" --value "true" "${SOFT_INSTALL}/conf/server.xml"
			xmlstarlet ed --inplace --pf --ps --update '//Connector[@port="7990"]/@redirectPort' --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/conf/server.xml"
		fi
		if [ -n "${X_PATH}" ]; then
			xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${SOFT_INSTALL}/conf/server.xml"
		fi
	fi

exec "$@"