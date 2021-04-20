#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
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
	export SOFT=${SOFT:-crowd}
	#export SOFTSUB=${SOFTSUB:-core}
	export auser=${auser:-daemon}
	export aguser=${aguser:-daemon}
	export OPENJDKV=${OPENJDKV:-8}
	export POSTGRESQLV=42.2.19
	export MYSQLV=8.0.24
	export MSSQLV=9.2.1.jre8
	export ORACLEV=8
	export VISIBLECODE=${VISIBLECODE:-false}
	env_openjdk_jre
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
	say " - Begin install - "

## directory structure.
	create_folders		"${SOFT_HOME}" "${SOFT_INSTALL}"
	set_filefolder_mod	700            		"${SOFT_HOME}"
	set_filefolder_owner	${auser}:${aguser}	"${SOFT_HOME}"

## download and extract source software
	say "downloading and install atlassian..."
	check_folder_empty "${SOFT_INSTALL}" && curl -Ls "https://www.atlassian.com/software/${SOFT}/downloads/binary/atlassian-${SOFT}-${SOFT_VERSION}.tar.gz" | tar -xz --directory "${SOFT_INSTALL}" --strip-components=1 --no-same-owner
	
	echo "crowd.home=${SOFT_HOME}" > ${SOFT_INSTALL}/crowd-webapp/WEB-INF/classes/crowd-init.properties

## update database connector
	FILELIB="${SOFT_INSTALL}/apache-tomcat/lib"

### update mysql connector
	remove_filefolder ${FILELIB}/mysql-connector-java-*.jar
		say "downloading and update mysql-connector-java..."
	FILETEMP="${FILELIB}/mysql-connector-java-${MYSQLV}/mysql-connector-java-${MYSQLV}-bin.jar"
		check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| curl -Ls "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQLV}.tar.gz" | tar -xz --directory "${FILELIB}" --strip-components=1 --no-same-owner "mysql-connector-java-${MYSQLV}/mysql-connector-java-${MYSQLV}-bin.jar"

### update postgresql connector
	remove_filefolder ${FILELIB}/postgresql-*.jar
		say "downloading and update postgresql-connector-java..."
	FILETEMP="${FILELIB}/postgresql-${POSTGRESQLV}.jar"
		check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save "${FILETEMP}" "https://jdbc.postgresql.org/download/postgresql-${POSTGRESQLV}.jar"

### update mssql-server connector
	remove_filefolder ${FILELIB}/mssql-jdbc-*.jar
		say "downloading and update mssql-jdbc..."
	FILETEMP="${FILELIB}/mssql-jdbc-${MSSQLV}.jar"
		check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save "${FILETEMP}" "${DOWN_URL}/connector/mssql-jdbc-${MSSQLV}.jar"

### update oracle database connector
	remove_filefolder ${FILELIB}/ojdbc*.jar
		say "downloading and update oracle-ojdbc..."
	FILETEMP="${FILELIB}/ojdbc${ORACLEV}.jar"
		check_file "${FILETEMP}" && say_warning "${FILETEMP} exist"	|| $download_save "${FILETEMP}" "${DOWN_URL}/connector/ojdbc${ORACLEV}.jar"

## set permission path
	set_filefolder_mod 	700            		"${SOFT_INSTALL}/apache-tomcat/conf"	&& say "set done" || say_warning "file/folder not exist"
	set_filefolder_mod 	700            		"${SOFT_INSTALL}/apache-tomcat/logs"	&& say "set done" || say_warning "file/folder not exist"
	set_filefolder_mod 	700            		"${SOFT_INSTALL}/apache-tomcat/temp"	&& say "set done" || say_warning "file/folder not exist"
	set_filefolder_mod 	700            		"${SOFT_INSTALL}/apache-tomcat/work"	&& say "set done" || say_warning "file/folder not exist"
	set_filefolder_owner 	${auser}:${aguser}	"${SOFT_HOME}"				&& say "set done" || say_warning "file/folder not exist"
	set_filefolder_owner 	${auser}:${aguser}	"${SOFT_INSTALL}"			&& say "set done" || say_warning "file/folder not exist"

	FILETEMP="${SOFT_INSTALL}/apache-tomcat/bin/setenv.sh"
		say "sed ${FILETEMP}..."	
		check_file "${FILETEMP}"	&& sed --in-place 's/^# umask 0027$/umask 0027/g' "${FILETEMP}" || say_warning "${FILETEMP} does not exist"

# xmlstarlet
	FILETEMP="${SOFT_INSTALL}/apache-tomcat/conf/server.xml"
		say "xmlstarlet ${FILETEMP}..."
		check_file "${FILETEMP}"	&& xmlstarlet ed --inplace \
		  				--delete "Server/Service/Engine/Host/@xmlValidation" \
		 				--delete "Server/Service/Engine/Host/@xmlNamespaceAware" \
						"${FILETEMP}" || say_warning "${FILETEMP} does not exist"

# xmlstarlet end
		check_file "${FILETEMP}"	&& touch -d "@0" "${FILETEMP}" || say_warning "${FILETEMP} does not exist"

# fix path start file
	FILETEMP="${SOFT_INSTALL}/bin/start_${SOFT}.sh"
		say "checking ${FILETEMP}..."
		check_file "${FILETEMP}"	&& mv "${FILETEMP}" "${SOFT_INSTALL}/bin/start-${SOFT}.sh"	|| say_warning "file/folder not exist"
		set_filefolder_mod 		755 "${SOFT_INSTALL}/bin/start-${SOFT}.sh"			&& say "set done" || say_warning "file/folder not exist"
	FILETEMP="${SOFT_INSTALL}/start_${SOFT}.sh"
		say "checking ${FILETEMP}..."
		check_file "${FILETEMP}"	&& mv "${FILETEMP}" "${SOFT_INSTALL}/start-${SOFT}.sh"		|| say_warning "file/folder not exist"
		set_filefolder_mod 		755 "${SOFT_INSTALL}/start-${SOFT}.sh"				&& say "set done" || say_warning "file/folder not exist"

	e_success " - Install done - "
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
		installfonts
	# install depend
		install_java_jre
			echo "Install depend packages..."
		install_package curl xmlstarlet ttf-dejavu tzdata unzip
	# disable because use adoptopenjdk: libc6-compat
	# Install Atlassian
		installatlassian
		run_url $DOWN_URL/prepare_final.sh
	# visible code
		check_value_true "${VISIBLECODE}" && install_gosu
	# clean
		remove_download_tool
		clean_os
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		installfonts
	# Set frontend debian
		debian_cmd_interface
	# install depend
		#install_java_jre
			echo "Install depend packages..."
		install_package curl ttf-dejavu libtcnative-1 xmlstarlet gnupg gnupg1 gnupg2
	# Install Atlassian
		installatlassian
		run_url $DOWN_URL/prepare_final.sh
	# visible code
		check_value_true "${VISIBLECODE}" && install_gosu
	# clean
		remove_download_tool
		clean_os
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
    say_err "Not support your OS"
    exit 1
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
