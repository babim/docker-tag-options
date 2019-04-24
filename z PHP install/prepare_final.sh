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

# prepare etc start
    remove_filefolder 	/etc-start
# nginx
    dircopy 		/etc/nginx/* 		/etc-start/nginx
# php
    dircopy 		/etc/php/* 		/etc-start/php
# apache
    dircopy 		/etc/apache2/* 		/etc-start/apache2
# www data
    dircopy 		/var/www/* 		/etc-start/www
# supervisor
    dircopy 		/etc/supervisor/* 	/etc-start/supervisor
# litespeed
    dircopy 		/usr/local/lsws/* 	/etc-start/lsws
# end