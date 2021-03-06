#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2018 Oracle and/or its affiliates. All rights reserved.
#
# Since: December, 2016
# Author: gerald.venzl@oracle.com
# Description: Sets up the unix environment for DB installation.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# Convert $1 into upper case via "^^" (bash version 4 onwards)
EDITION=${1^^}

# Check whether edition has been passed on
if [ "$EDITION" == "" ]; then
   echo "ERROR: No edition has been passed on!"
   echo "Please specify the correct edition!"
   exit 1;
fi;

# Check whether correct edition has been passed on
if [ "$EDITION" != "EE" -a "$EDITION" != "SE2" ]; then
   echo "ERROR: Wrong edition has been passed on!"
   echo "Edition $EDITION is no a valid edition!"
   exit 1;
fi;

# Check whether ORACLE_BASE is set
if [ "$ORACLE_BASE" == "" ]; then
   echo "ERROR: ORACLE_BASE has not been set!"
   echo "You have to have the ORACLE_BASE environment variable set to a valid value!"
   exit 1;
fi;

# Check whether ORACLE_HOME is set
if [ "$ORACLE_HOME" == "" ]; then
   echo "ERROR: ORACLE_HOME has not been set!"
   echo "You have to have the ORACLE_HOME environment variable set to a valid value!"
   exit 1;
fi;


# Replace place holders
# ---------------------
sed -i -e "s|###ORACLE_EDITION###|$EDITION|g" $INSTALL_DIR/$INSTALL_RSP && \
sed -i -e "s|###ORACLE_BASE###|$ORACLE_BASE|g" $INSTALL_DIR/$INSTALL_RSP && \
sed -i -e "s|###ORACLE_HOME###|$ORACLE_HOME|g" $INSTALL_DIR/$INSTALL_RSP

# Install Oracle binaries
if [[ ! -z "${INSTALL_FILE_1}" ]]; then
	if [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" || "$VERSION" == "19.3.0" ]] || [[ "$VERSION" == "19c" ]]; then
		mv $INSTALL_DIR/$INSTALL_FILE_1 $ORACLE_HOME/
		cd $ORACLE_HOME/
		unzip $INSTALL_FILE_1 && ls && \
		rm $INSTALL_FILE_1
	else
		cd $INSTALL_DIR
		unzip $INSTALL_FILE_1 && ls && \
		rm $INSTALL_FILE_1
	fi
fi
if [[ ! -z "${INSTALL_FILE_2}" ]]; then
	if [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" || "$VERSION" == "19.3.0" ]] || [[ "$VERSION" == "19c" ]]; then
		mv $INSTALL_DIR/$INSTALL_FILE_2 $ORACLE_HOME/
		cd $ORACLE_HOME/
		unzip $INSTALL_FILE_2 && ls && \
		rm $INSTALL_FILE_2
	else
		cd $INSTALL_DIR
		unzip $INSTALL_FILE_2 && ls && \
		rm $INSTALL_FILE_2
	fi
fi
if [[ ! -z "${INSTALL_FILE_3}" ]]; then
	if [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" || "$VERSION" == "19.3.0" ]] || [[ "$VERSION" == "19c" ]]; then
		mv $INSTALL_DIR/$INSTALL_FILE_3 $ORACLE_HOME/
		cd $ORACLE_HOME/
		unzip $INSTALL_FILE_3 && ls && \
		rm $INSTALL_FILE_3
	else
		cd $INSTALL_DIR
		unzip $INSTALL_FILE_3 && ls && \
		rm $INSTALL_FILE_3
	fi
fi
if [[ ! -z "${INSTALL_FILE_4}" ]]; then
	if [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" || "$VERSION" == "19.3.0" ]] || [[ "$VERSION" == "19c" ]]; then
		mv $INSTALL_DIR/$INSTALL_FILE_4 $ORACLE_HOME/
		cd $ORACLE_HOME/
		unzip $INSTALL_FILE_4 && ls && \
		rm $INSTALL_FILE_4
	else
		cd $INSTALL_DIR
		unzip $INSTALL_FILE_4 && ls && \
		rm $INSTALL_FILE_4
	fi
fi

if [[ "$VERSION" == "18.3.0" ]] || [[ "$VERSION" == "18c" || "$VERSION" == "19.3.0" ]] || [[ "$VERSION" == "19c" ]]; then
	$ORACLE_HOME/runInstaller -silent -force -waitforcompletion -responsefile $INSTALL_DIR/$INSTALL_RSP -ignorePrereqFailure && \
	cd $HOME
else
	$INSTALL_DIR/database/runInstaller -silent -force -waitforcompletion -responsefile $INSTALL_DIR/$INSTALL_RSP -ignoresysprereqs -ignoreprereq && \
	cd $HOME
fi
# Remove not needed components
# APEX
	rm -rf $ORACLE_HOME/apex && \
# ORDS
	rm -rf $ORACLE_HOME/ords && \
# SQL Developer
	rm -rf $ORACLE_HOME/sqldeveloper && \
# UCP connection pool
	rm -rf $ORACLE_HOME/ucp && \
# All installer files
	rm -rf $ORACLE_HOME/lib/*.zip && \
# OUI backup
	rm -rf $ORACLE_HOME/inventory/backup/* && \
# Network tools help
	rm -rf $ORACLE_HOME/network/tools/help && \
# Database upgrade assistant
	rm -rf $ORACLE_HOME/assistants/dbua && \
# Database migration assistant
	rm -rf $ORACLE_HOME/dmu && \
# Remove pilot workflow installer
	rm -rf $ORACLE_HOME/install/pilot && \
# Support tools
	rm -rf $ORACLE_HOME/suptools && \
# Temp location
	rm -rf /tmp/* && \
# Database files directory
	rm -rf $INSTALL_DIR/database

# Link password reset file to home directory
	ln -s $ORACLE_BASE/$PWD_FILE $HOME/

# Check whether Perl is working
	if [[ "$VERSION" == "12.1.0.2" ]] || [[ "$VERSION" == "12cr1" ]]; then
		chmod ug+x $INSTALL_DIR/installPerl.sh && \
		$ORACLE_HOME/perl/bin/perl -v || \
		$INSTALL_DIR/installPerl.sh
	else
		echo "This Oracle Database version no need install Perl"
	fi
