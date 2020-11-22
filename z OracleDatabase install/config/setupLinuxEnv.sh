#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# Since: December, 2016
# Author: gerald.venzl@oracle.com
# Description: Sets up the unix environment for DB installation.
# 
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
# 

# Setup filesystem and oracle user
# Adjust file permissions, go to /opt/oracle as user 'oracle' to proceed with Oracle installation
# ------------------------------------------------------------
echo "create folder prepare" && \
mkdir -p $ORACLE_BASE/scripts/setup && \
mkdir $ORACLE_BASE/scripts/startup && \
ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
mkdir $ORACLE_BASE/oradata && \
chmod ug+x $ORACLE_BASE/*.sh && \
echo "install package preinstall $PREINSTALLPACK" && \
yum -y install $PREINSTALLPACK unzip tar openssl && \
echo "clean cache" && \
rm -rf /var/cache/yum && \
echo "create user oracle" && \
echo oracle:oracle | chpasswd && \
echo "set owner for user oracle" && \
chown -R oracle:dba $ORACLE_BASE
