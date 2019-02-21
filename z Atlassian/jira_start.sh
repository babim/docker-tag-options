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
	if [ "$VISIBLECODE" = "true" ]; then
		if [ -z "`ls ${SOFTINSTALL}`" ]; then
			cp -R /etc-start/jira/* ${SOFTINSTALL}
		## set permission path
			chmod -R 700            "${SOFTINSTALL}/conf"
			chmod -R 700            "${SOFTINSTALL}/logs"
			chmod -R 700            "${SOFTINSTALL}/temp"
			chmod -R 700            "${SOFTINSTALL}/work"
			chown -R daemon:daemon  "${SOFTINSTALL}/conf"
			chown -R daemon:daemon  "${SOFTINSTALL}/logs"
			chown -R daemon:daemon  "${SOFTINSTALL}/temp"
			chown -R daemon:daemon  "${SOFTINSTALL}/work"
		fi
	fi

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
if [ "$(stat -c "%Y" "${SOFTINSTALL}/conf/server.xml")" -eq "0" ]; then
 	if [ -n "${X_PROXY_NAME}" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${SOFTINSTALL}/conf/server.xml"
	fi
	if [ -n "${X_PROXY_PORT}" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${SOFTINSTALL}/conf/server.xml"
	fi
	if [ -n "${X_PROXY_SCHEME}" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${SOFTINSTALL}/conf/server.xml"
	fi
	if [ "${X_PROXY_SCHEME}" = "https" ]; then
		xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8080"]' --type "attr" --name "secure" --value "true" "${SOFTINSTALL}/conf/server.xml"
		xmlstarlet ed --inplace --pf --ps --update '//Connector[@port="8080"]/@redirectPort' --value "${X_PROXY_PORT}" "${SOFTINSTALL}/conf/server.xml"
	fi
	if [ -n "${X_PATH}" ]; then
		xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${SOFTINSTALL}/conf/server.xml"
	fi
fi

# visible code
	if [ "$VISIBLECODE" = "true" ]; then
		${SOFTINSTALL}/bin/start-${SOFT}.sh -fg
	fi

exec "$@"