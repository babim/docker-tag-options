#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi
echo 'Check OS'
if [ -f /etc/redhat-release ]; then
	DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20OracleDatabase%20install"
	HOST_DOWN="http://media.matmagoc.com/oracle"
	# set code
	if [[ "$VERSION" == "12.2.0.1" ]] || [[ "$VERSION" == "12cr2" ]]; then
		export CODE=${CODE:-"server-12cR2-preinstall"}
	elif [[ "$VERSION" == "12.1.0.2" ]] || [[ "$VERSION" == "12cr1" ]]; then
		export CODE=${CODE:-"server-12cR1-preinstall"}
	elif [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" ]]; then
		export CODE=${CODE:-"preinstall-18c"}
	fi
	# set environment
	echo "set environment"
	export ORACLE_BASE=${ORACLE_BASE:-"/opt/oracle"}
	export ORACLE_HOME=${ORACLE_HOME:-"$ORACLE_BASE/product/$VERSION/dbhome_1"}
	export INSTALL_RSP="db_inst.rsp"
	export CONFIG_RSP="dbca.rsp.tmpl"
	export PWD_FILE="setPassword.sh"
	export RUN_FILE="runOracle.sh"
	export START_FILE="startDB.sh"
	export CREATE_DB_FILE="createDB.sh"
	export SETUP_LINUX_FILE="setupLinuxEnv.sh"
	export CHECK_SPACE_FILE="checkSpace.sh"
	export CHECK_DB_FILE="checkDBStatus.sh"
	export USER_SCRIPTS_FILE="runUserScripts.sh"
	export INSTALL_DB_BINARIES_FILE="installDBBinaries.sh"
	# Use second ENV so that variable get substituted
	export INSTALL_DIR=${INSTALL_DIR:-"$ORACLE_BASE/install"}
	export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH
	export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib
	export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
	# Copy binaries
	# -------------
	echo "Copy binaries"
	mkdir -p $INSTALL_DIR/
	cd $INSTALL_DIR/ && pwd
		wget -O $INSTALL_RSP --no-check-certificate $DOWN_URL/template/$INSTALL_RSP-$VERSION
		wget --no-check-certificate $DOWN_URL/config/$SETUP_LINUX_FILE
		wget --no-check-certificate $DOWN_URL/config/$CHECK_SPACE_FILE
		wget --no-check-certificate $DOWN_URL/config/$INSTALL_DB_BINARIES_FILE
	cd $ORACLE_BASE/ && pwd
		wget --no-check-certificate $DOWN_URL/config/$RUN_FILE
		wget --no-check-certificate $DOWN_URL/config/$START_FILE
		wget --no-check-certificate $DOWN_URL/config/$CREATE_DB_FILE
		wget -O $CONFIG_RSP --no-check-certificate $DOWN_URL/template/$CONFIG_RSP-$VERSION
		wget --no-check-certificate $DOWN_URL/config/$PWD_FILE
		wget --no-check-certificate $DOWN_URL/config/$USER_SCRIPTS_FILE
	chmod ug+x $INSTALL_DIR/*.sh
	chmod ug+x $ORACLE_BASE/*.sh
	# Download setup files
	echo "Download setup files"
	cd $INSTALL_DIR/ && pwd
	if [[ ! -z "${INSTALL_FILE_1}" ]]; then
		if [ ! -f "$INSTALL_FILE_1" ]; then wget --no-check-certificate --progress=bar:force $HOST_DOWN/$INSTALL_FILE_1; fi
	fi
	if [[ ! -z "${INSTALL_FILE_2}" ]]; then
		if [ ! -f "$INSTALL_FILE_1" ]; then wget --no-check-certificate --progress=bar:force $HOST_DOWN/$INSTALL_FILE_2; fi
	fi
	if [[ ! -z "${INSTALL_FILE_3}" ]]; then
		if [ ! -f "$INSTALL_FILE_1" ]; then wget --no-check-certificate --progress=bar:force $HOST_DOWN/$INSTALL_FILE_3; fi
	fi
	if [[ ! -z "${INSTALL_FILE_4}" ]]; then
		if [ ! -f "$INSTALL_FILE_1" ]; then wget --no-check-certificate --progress=bar:force $HOST_DOWN/$INSTALL_FILE_4; fi
	fi
	# Install prepare setup
	echo "Install prepare setup"
		sync
		$INSTALL_DIR/$CHECK_SPACE_FILE
#		curl -s $DOWN_URL/config/$CHECK_SPACE_FILE | bash
#		$INSTALL_DIR/$SETUP_LINUX_FILE
#		curl -s $DOWN_URL/config/$SETUP_LINUX_FILE | bash
mkdir -p $ORACLE_BASE/scripts/setup && \
mkdir $ORACLE_BASE/scripts/startup && \
ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
mkdir $ORACLE_BASE/oradata && \
chmod ug+x $ORACLE_BASE/*.sh && \
echo "install oracle prepare" && yum -y install oracle-database-$CODE unzip tar openssl && \
rm -rf /var/cache/yum && \
echo oracle:oracle | chpasswd && \
chown -R oracle:dba $ORACLE_BASE

	# install gosu
	echo "install gosu"
		curl -s $DOWN_URL/gosu_install.sh | bash
	# Install DB software binaries
	echo "Install DB software binaries"
	# su -H -u oracle bash -c '$INSTALL_DIR/$INSTALL_DB_BINARIES_FILE $PRODUCT'
		gosu oracle $INSTALL_DIR/$INSTALL_DB_BINARIES_FILE $PRODUCT

	# Clean
	echo "Clean"
		$ORACLE_BASE/oraInventory/orainstRoot.sh && \
		$ORACLE_HOME/root.sh && \
		rm -rf $INSTALL_DIR
else
    echo "Not support your OS"
    exit
fi