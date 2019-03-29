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
		export SOFT=${SOFT:-crowd}
		#export SOFTSUB=${SOFTSUB:-core}
		export auser=${auser:-daemon}
		export aguser=${aguser:-daemon}
	echo "check version"
	## Check version
		if [[ -z "${SOFT_VERSION}" ]] || [[ -z "${SOFT_HOME}" ]] || [[ -z "${SOFT_INSTALL}" ]]; then
			echo "Can not run. Please check and rebuild"
			exit
		fi

# visible code
	echo "check path and install"
	if [ ! -d ${SOFT_INSTALL} ]; then mkdir -p ${SOFT_INSTALL}; fi
	if [ -z "`ls ${SOFT_INSTALL}`" ]; then
			cp -R /etc-start/${SOFT}/* ${SOFT_INSTALL}
		[[ ! -d "${SOFT_HOME}" ]] && mkdir -p "${SOFT_HOME}"
	## set permission path
		[[ -d "${SOFT_HOME}" ]]					&& chmod -R 700            "${SOFT_HOME}"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/conf" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/conf"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/logs" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/logs"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/temp" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/temp"
		[[ -d "${SOFT_INSTALL}/apache-tomcat/work" ]]		&& chmod -R 700            "${SOFT_INSTALL}/apache-tomcat/work"
		[[ -d "${SOFT_HOME}" ]]					&& chown -R ${auser}:${aguser}  "${SOFT_HOME}"
		[[ -d "${SOFT_INSTALL}" ]]				&& chown -R ${auser}:${aguser}  "${SOFT_INSTALL}"
	fi

# check if the `server.xml` file has been changed since the creation of this
# Docker image. If the file has been changed the entrypoint script will not
# perform modifications to the configuration file.
	echo "set environment"
export CONFIGFILE=conf/server.xml
	if [ "$(stat -c "%Y" "${SOFT_INSTALL}/${CONFIGFILE}")" -eq "0" ]; then
	 	if [ -n "${X_PROXY_NAME}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8095"]' --type "attr" --name "proxyName" --value "${X_PROXY_NAME}" "${SOFT_INSTALL}/apache-tomcat/${CONFIGFILE}"'
		fi
		if [ -n "${X_PROXY_PORT}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8095"]' --type "attr" --name "proxyPort" --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/apache-tomcat/${CONFIGFILE}"'
		fi
		if [ -n "${X_PROXY_SCHEME}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8095"]' --type "attr" --name "scheme" --value "${X_PROXY_SCHEME}" "${SOFT_INSTALL}/apache-tomcat/${CONFIGFILE}"'
		fi
		if [ "${X_PROXY_SCHEME}" = "https" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --insert '//Connector[@port="8095"]' --type "attr" --name "secure" --value "true" "${SOFT_INSTALL}/apache-tomcat/${CONFIGFILE}"'
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --update '//Connector[@port="8095"]/@redirectPort' --value "${X_PROXY_PORT}" "${SOFT_INSTALL}/apache-tomcat/${CONFIGFILE}"'
		fi
		if [ -n "${X_PATH}" ]; then
			gosu ${auser} 'xmlstarlet ed --inplace --pf --ps --update '//Context/@path' --value "${X_PATH}" "${SOFT_INSTALL}/apache-tomcat/${CONFIGFILE}"'
		fi
	fi

	echo "run app..."

# Run
gosu ${auser} "${SOFT_INSTALL}/start-${SOFT}.sh" -fg