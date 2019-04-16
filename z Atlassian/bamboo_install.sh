#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

#####################################
    ####### Set download tool #######
    ####### and load library ########
# check has package
function    machine_has() {
        hash "$1" > /dev/null 2>&1
        return $?; }
# Check and set download tool
echo "Check and set download tool..."
if machine_has "curl"; then
    source <(curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
elif machine_has "wget"; then
    source <(wget -qO- https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
else
    echo "without download tool"
    sleep 3
    exit 1
fi
download_option
#####################################

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
# set command install
installatlassian() {
	## Check version
		if has_empty "${SOFT_VERSION}" || has_empty "${SOFT_HOME}" || has_empty "${SOFT_INSTALL}"; then
			say "Can not install without version. Please check and rebuild"
			exit $FALSE
		fi
	# Install Atlassian JIRA and helper tools and setup initial home
	## directory structure.
		create_folder                			"${SOFT_HOME}"
		set_filefolder_mod	700            		"${SOFT_HOME}"
		set_filefolder_owner	${auser}:${aguser}	"${SOFT_HOME}"
		create_folder                			"${SOFT_INSTALL}"
	## download and extract source software
		say "downloading and install atlassian..."
		$download_tool "https://www.atlassian.com/software/${SOFT}/downloads/binary/atlassian-${SOFT}-${SOFT_VERSION}.tar.gz" | tar -xz --directory "${SOFT_INSTALL}" --strip-components=1 --no-same-owner
	## update mysql connector
	FILELIB="${SOFT_INSTALL}/lib"
	remove_file "${FILELIB}/mysql-connector-java-*.jar"
		say "downloading and update mysql-connector-java..."
		$download_tool "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQLV}.tar.gz" | tar -xz --directory "${FILELIB}" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQLV}/mysql-connector-java-${MYSQLV}-bin.jar"
	## update postgresql connector
	remove_file "${FILELIB}/postgresql-*.jar"
		say "downloading and update postgresql-connector-java..."
		$download_save "${FILELIB}/postgresql-${POSTGRESQLV}.jar" "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQLV}.jar"
	## update mssql-server connector
	remove_file "${FILELIB}/mssql-jdbc-*.jar"
		say "downloading and update mssql-jdbc..."
		$download_save "${FILELIB}/mssql-jdbc-${MSSQLV}.jar" "${DOWN_URL}/connector/mssql-jdbc-${MSSQLV}.jar"
	## update oracle database connector
	remove_file "${FILELIB}/ojdbc*.jar"
		say "downloading and update oracle-ojdbc..."
		$download_save "${FILELIB}/ojdbc${ORACLEV}.jar" "${DOWN_URL}/connector/ojdbc${ORACLEV}.jar"
	## set permission path
		set_filefolder_mod 	700            		"${SOFT_INSTALL}/conf"
		set_filefolder_mod 	700            		"${SOFT_INSTALL}/logs"
		set_filefolder_mod 	700            		"${SOFT_INSTALL}/temp"
		set_filefolder_mod 	700            		"${SOFT_INSTALL}/work"
		set_filefolder_mod 	${auser}:${aguser}	"${SOFT_INSTALL}/conf"
		set_filefolder_mod 	${auser}:${aguser}	"${SOFT_INSTALL}/logs"
		set_filefolder_mod 	${auser}:${aguser}	"${SOFT_INSTALL}/temp"
		set_filefolder_mod 	${auser}:${aguser}	"${SOFT_INSTALL}/work"
		check_file "${SOFT_INSTALL}/bin/setenv.sh"	&& sed --in-place 's/^# umask 0027$/umask 0027/g' "${SOFT_INSTALL}/bin/setenv.sh"
		# xmlstarlet
	if check_file "${SOFT_INSTALL}/conf/server.xml"; then
		xmlstarlet		ed --inplace \
		  --delete		"Server/Service/Engine/Host/@xmlValidation" \
		  --delete		"Server/Service/Engine/Host/@xmlNamespaceAware" \
					"${SOFT_INSTALL}/conf/server.xml"
	fi
		# xmlstarlet end
		check_file "${SOFT_INSTALL}/conf/server.xml"		&& touch -d "@0"	"${SOFT_INSTALL}/conf/server.xml"
	# fix path start file
		check_file "${SOFT_INSTALL}/bin/start_${SOFT}.sh"	&& mv "${SOFT_INSTALL}/bin/start_${SOFT}.sh" "${SOFT_INSTALL}/bin/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/bin/start-${SOFT}.sh"
		check_file "${SOFT_INSTALL}/start_${SOFT}.sh"		&& mv "${SOFT_INSTALL}/start_${SOFT}.sh" "${SOFT_INSTALL}/start-${SOFT}.sh" && chmod 755 "${SOFT_INSTALL}/start-${SOFT}.sh"
}
dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		remove_file $FILETEMP
		# visible code
		if [ "${VISIBLECODE}" = "true" ]; then
			$download_save $FILETEMP $DOWN_URL/${SOFT}_fixed.sh
		else
			$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
		fi
		chmod +x $FILETEMP
}
preparedata() {
	if [[ "${VISIBLECODE}" == "true" ]]; then
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
		install_java_jre
			echo "Install depend packages..."
		install_package xmlstarlet ttf-dejavu libc6-compat git openssh
	# visible code
	[[ "${VISIBLECODE}" == "true" ]] && echo 123

	# Install Atlassian
		installatlassian
		dockerentry
	# clean
		remove_package $DOWNLOAD_TOOL
		clean_os
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		debian_cmd_interface
	# install depend
		install_java_jre
			echo "Install depend packages..."
		install_package ttf-dejavu libtcnative-1 xmlstarlet git openssh-client
	# visible code
	if [[ "${VISIBLECODE}" == "true" ]]; then
		# install gosu
		install_gosu
	fi
	# Install Atlassian
		installatlassian
		dockerentry
	# clean
		remove_package $DOWNLOAD_TOOL
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    echo "Not support your OS"
    exit
# OS - other
else
    echo "Not support your OS"
    exit
fi