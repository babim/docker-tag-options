#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# visible code
	if [ "${VISIBLECODE}" = "true" ]; then
		if [ -z "`ls ${SOFT_INSTALL}`" ] || [ ! -d ${SOFT_INSTALL} ]; then
			if [ ! -d ${SOFT_INSTALL} ]; then mkdir -p ${SOFT_INSTALL}; fi
				sudo -u root -H sh -c 'cp -R /etc-start/jira/* ${SOFT_INSTALL}'
				sudo -u root -H sh -c 'mkdir -p "${SOFT_HOME}/caches/indexes"'
		## set permission path
			sudo -u root -H sh -c 'chmod -R 700            "${SOFT_HOME}"'
			sudo -u root -H sh -c 'chown -R daemon:daemon  "${SOFT_HOME}"'
			sudo -u root -H sh -c 'chmod -R 700            "${SOFT_INSTALL}/conf"'
			sudo -u root -H sh -c 'chmod -R 700            "${SOFT_INSTALL}/logs"'
			sudo -u root -H sh -c 'chmod -R 700            "${SOFT_INSTALL}/temp"'
			sudo -u root -H sh -c 'chmod -R 700            "${SOFT_INSTALL}/work"'
			sudo -u root -H sh -c 'chown -R daemon:daemon  "${SOFT_INSTALL}/conf"'
			sudo -u root -H sh -c 'chown -R daemon:daemon  "${SOFT_INSTALL}/logs"'
			sudo -u root -H sh -c 'chown -R daemon:daemon  "${SOFT_INSTALL}/temp"'
			sudo -u root -H sh -c 'chown -R daemon:daemon  "${SOFT_INSTALL}/work"'
		fi
	fi

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat -c "%Y" "${SOFT_INSTALL}/conf/server.xml")" -eq "0" ]; then
 	if [ -n "${X_PROXY_NAME}" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${SOFT_INSTALL}/conf/server.xml"
	fi
	if [ -n "${X_PROXY_PORT}" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/conf/server.xml"
	fi
	if [ -n "${X_PROXY_SCHEME}" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${SOFT_INSTALL}/conf/server.xml"
	fi
	if [ "${X_PROXY_SCHEME}" = "https" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "secure" --value "true" "${SOFT_INSTALL}/conf/server.xml"
		xmlstarlet ed --inplace --pf --ps --update '//Connector[@port="8080"]/@redirectPort' --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/conf/server.xml"
	fi
	if [ -n "${X_PATH}" ]; then
		xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${SOFT_INSTALL}/conf/server.xml"
	fi
fi

# visible code
	if [ "${VISIBLECODE}" = "true" ]; then
		${SOFT_INSTALL}/bin/start-${SOFT}.sh -fg
	fi

exec "$@"