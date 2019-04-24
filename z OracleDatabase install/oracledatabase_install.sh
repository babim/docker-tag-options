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

# install by OS
echo 'Check OS'
if [ -f /etc/redhat-release ]; then
	# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20OracleDatabase%20install"
	export HOST_DOWN="http://media.matmagoc.com/oracle"
	# set uninstall app
	export UNINSTALL="${DOWNLOAD_TOOL}"
	# set install file
	export INSTALL_FILE_1=${INSTALL_FILE_1:-"false"}
	export INSTALL_FILE_2=${INSTALL_FILE_2:-"false"}
	export INSTALL_FILE_3=${INSTALL_FILE_3:-"false"}
	export INSTALL_FILE_4=${INSTALL_FILE_4:-"false"}
	# set code
	if [[ "$VERSION" == "12.2.0.1" ]] || [[ "$VERSION" == "12cr2" ]]; then
		export PREINSTALLPACK=${PREINSTALLPACK:-"oracle-database-server-12cR2-preinstall"}
		export VERSION=12.2.0.1
	elif [[ "$VERSION" == "12.1.0.2" ]] || [[ "$VERSION" == "12cr1" ]]; then
		export PREINSTALLPACK=${PREINSTALLPACK:-"oracle-rdbms-server-12cR1-preinstall"}
		export VERSION=12.1.0.2
	elif [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" ]]; then
		export PREINSTALLPACK=${PREINSTALLPACK:-"oracle-database-preinstall-18c"}
		export VERSION=18c
	fi
	# set environment
	echo "set environment"
	export ORACLE_BASE=${ORACLE_BASE:-"/opt/oracle"}
	export ORACLE_HOME=${ORACLE_HOME:-$ORACLE_BASE/product/$VERSION/dbhome_1}
	export INSTALL_RSP=${INSTALL_RSP:-"db_inst.rsp"}
	export CONFIG_RSP=${CONFIG_RSP:-"dbca.rsp.tmpl"}
	export PWD_FILE=${PWD_FILE:-"setPassword.sh"}
	export RUN_FILE=${RUN_FILE:-"runOracle.sh"}
	export START_FILE=${START_FILE:-"startDB.sh"}
	export CREATE_DB_FILE=${CREATE_DB_FILE:-"createDB.sh"}
	export SETUP_LINUX_FILE=${SETUP_LINUX_FILE:-"setupLinuxEnv.sh"}
	export CHECK_SPACE_FILE=${CHECK_SPACE_FILE:-"checkSpace.sh"}
	export CHECK_DB_FILE=${CHECK_DB_FILE:-"checkDBStatus.sh"}
	export USER_SCRIPTS_FILE=${USER_SCRIPTS_FILE:-"runUserScripts.sh"}
	export INSTALL_DB_BINARIES_FILE=${INSTALL_DB_BINARIES_FILE:-"installDBBinaries.sh"}
	# Use second ENV so that variable get substituted
	export INSTALL_DIR=${INSTALL_DIR:-$ORACLE_BASE/install}
	export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH
	export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
	export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
	# Copy binaries
	# -------------
	say "Copy binaries"
	create_folder $INSTALL_DIR/
	create_folder $ORACLE_HOME/
#	cd $INSTALL_DIR/ && pwd
		$download_save $INSTALL_DIR/$INSTALL_RSP $DOWN_URL/template/$INSTALL_RSP-$VERSION
		$download_save $INSTALL_DIR/$SETUP_LINUX_FILE $DOWN_URL/config/$SETUP_LINUX_FILE
		$download_save $INSTALL_DIR/$CHECK_SPACE_FILE $DOWN_URL/config/$CHECK_SPACE_FILE
		$download_save $INSTALL_DIR/$INSTALL_DB_BINARIES_FILE $DOWN_URL/config/$INSTALL_DB_BINARIES_FILE
#	cd $ORACLE_BASE/ && pwd
		$download_save $ORACLE_BASE/$RUN_FILE $DOWN_URL/config/$RUN_FILE
		$download_save $ORACLE_BASE/$START_FILE $DOWN_URL/config/$START_FILE
		$download_save $ORACLE_BASE/$CREATE_DB_FILE $DOWN_URL/config/$CREATE_DB_FILE
		$download_save $ORACLE_BASE/$CHECK_DB_FILE $DOWN_URL/config/$CHECK_DB_FILE
		$download_save $ORACLE_BASE/$CONFIG_RSP $DOWN_URL/template/$CONFIG_RSP-$VERSION
		$download_save $ORACLE_BASE/$PWD_FILE $DOWN_URL/config/$PWD_FILE
		$download_save $ORACLE_BASE/$USER_SCRIPTS_FILE $DOWN_URL/config/$USER_SCRIPTS_FILE
	chmod ug+x $INSTALL_DIR/*.sh
	chmod ug+x $ORACLE_BASE/*.sh
	# Download setup files
	echo "Download setup files"
#	cd $INSTALL_DIR/ && pwd
	if ! check_value_false "${INSTALL_FILE_1}"; then
		check_file "$INSTALL_DIR/$INSTALL_FILE_1" && $download_save $INSTALL_DIR/$INSTALL_FILE_1 $HOST_DOWN/$INSTALL_FILE_1 || say "File exists."
	fi
	if ! check_value_false "${INSTALL_FILE_2}"; then
		check_file "$INSTALL_DIR/$INSTALL_FILE_2" && $download_save $INSTALL_DIR/$INSTALL_FILE_2 $HOST_DOWN/$INSTALL_FILE_2 || say "File exists."
	fi
	if ! check_value_false "${INSTALL_FILE_3}"; then
		check_file "$INSTALL_DIR/$INSTALL_FILE_3" && $download_save $INSTALL_DIR/$INSTALL_FILE_3 $HOST_DOWN/$INSTALL_FILE_3 || say "File exists."
	fi
	if ! check_value_false "${INSTALL_FILE_4}"; then
		check_file "$INSTALL_DIR/$INSTALL_FILE_4" && $download_save $INSTALL_DIR/$INSTALL_FILE_4 $HOST_DOWN/$INSTALL_FILE_4 || say "File exists."
	fi
	# Install prepare setup
	echo "Install prepare setup"
		sync
		$INSTALL_DIR/$CHECK_SPACE_FILE
#		wget -O - $DOWN_URL/config/$CHECK_SPACE_FILE | bash
		$INSTALL_DIR/$SETUP_LINUX_FILE
#		wget -O - $DOWN_URL/config/$SETUP_LINUX_FILE | bash

	# install gosu
		install_gosu
	# Install DB software binaries
	say "Install DB software binaries"
	# su -H -u oracle bash -c '$INSTALL_DIR/$INSTALL_DB_BINARIES_FILE $PRODUCT'
		gosu oracle $INSTALL_DIR/$INSTALL_DB_BINARIES_FILE $PRODUCT

	# Clean
	say "Clean"
		$ORACLE_BASE/oraInventory/orainstRoot.sh && \
		$ORACLE_HOME/root.sh && \
		remove_folder $INSTALL_DIR

	# clean os
		clean_package
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi