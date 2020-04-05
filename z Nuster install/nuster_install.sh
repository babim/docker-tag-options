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
	export NUSTER_DL_URL=https://github.com/jiangwenyuan/nuster/archive/v$NUSTER_VERSION.tar.gz
	export NUSTER_DL_FILE=${NUSTER_DL_FILE:-nuster.tar.gz}
	export NUSTER_SRC_DIR=${NUSTER_SRC_DIR:-/tmp/nuster}
	export NUSTER_CONFIG_DIR=${NUSTER_CONFIG_DIR:-/etc/nuster}

	# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Nuster%20install"
}

# set command install
	# download docker entry
downloadentry() {
	FILETEMP=/start.sh
		remove_file 		$FILETEMP
		$download_save 		$FILETEMP $DOWN_URL/start.sh
		set_filefolder_mod +x 	$FILETEMP
}
	# prepare etc start
preparedata() {
FOLDER="/etc-start/nuster"
	create_folder $FOLDER
	check_folder $NUSTER_CONFIG_DIR && dircopy $NUSTER_CONFIG_DIR $FOLDER	|| say_err "Cant copy files, etc dir not found"
}
	# download app
downloadapp() {
	create_folder $NUSTER_SRC_DIR
	$download_save /tmp/$NUSTER_DL_FILE $NUSTER_DL_URL
	tar -xvf /tmp/$NUSTER_DL_FILE -C $NUSTER_SRC_DIR --strip-components=1
}
	# make app
makeapp() {
if [[ -f /etc/alpine-release ]]; then
	makeOpts=" \
	        TARGET=linux2628 \
	        USE_LUA=1 \
	        LUA_INC=/usr/include/lua5.3 \
	        LUA_LIB=/usr/lib/lua5.3 \
	        USE_OPENSSL=1 \
	        USE_PCRE=1 \
	        PCREDIR= \
	        USE_ZLIB=1 \
	"
elif [[ -f /etc/debian_version ]]; then
	makeOpts=" \
                TARGET=linux2628 \
                USE_LUA=1 \
                LUA_INC=/usr/include/lua5.3 \
                USE_OPENSSL=1 \
                USE_PCRE=1 \
                PCREDIR= \
                USE_ZLIB=1 \
	"
elif [[ -f /etc/redhat-release ]]; then
	makeOpts=" \
                TARGET=linux2628 \
                USE_LUA=1 \
                LUA_INC=$LUA_SRC_DIR/include \
                LUA_LIB=$LUA_SRC_DIR/lib \
                USE_OPENSSL=1 \
                USE_PCRE=1 \
                PCREDIR= \
                USE_ZLIB=1 \
	"
fi
	make -C $NUSTER_SRC_DIR -j "$(getconf _NPROCESSORS_ONLN)" all $makeOpts
	make -C $NUSTER_SRC_DIR install-bin $makeOpts
}
	# finish app
finish() {
# copy etc
	create_folder $NUSTER_CONFIG_DIR
FOLDER="$NUSTER_SRC_DIR/examples/errorfiles"
	check_folder $FOLDER && cp -R $FOLDER /etc/nuster
# remove build folder
	remove_filefolder /tmp/nuster*
	remove_package $BUILDLIB
}
	# install lua
installlua() {
# set environment
	export LUA_VERSION=${LUA_VERSION:-5.3.4}
	export LUA_DL_URL=https://www.lua.org/ftp/lua-$LUA_VERSION.tar.gz
	export LUA_DL_FILE=${LUA_DL_FILE:-lua.tar.gz}
	export LUA_SRC_DIR=${LUA_SRC_DIR:-/tmp/lua}
# download app
	$download_save /tmp/$LUA_DL_FILE -L $LUA_DL_URL
        tar -xzf /tmp/$LUA_DL_FILE -C $LUA_SRC_DIR --strip-components=1
# make
        make -C $LUA_SRC_DIR -j "$(getconf _NPROCESSORS_ONLN)" linux
        make -C $LUA_SRC_DIR install INSTALL_TOP=$LUA_SRC_DIR
# clean
	remove_filefolder /tmp/lua*
}

# install by OS
echo 'Check OS'
# debian, ubuntu
if [[ -f /etc/debian_version ]]; then
	# Set frontend debian
		debian_cmd_interface
	# set environment
		setenvironment
	# install required
        	install_package ca-certificates libpcre3 libssl1.1 liblua5.3-0
	# install build libs
	BUILDLIB="gcc libc6-dev libpcre3-dev liblua5.3-dev libssl-dev zlib1g-dev make"
		install_package $BUILDLIB
	# download app
		downloadapp
	# make app
		makeapp
	# finish app
		finish
	# preparedata
		preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# alpine linux
elif [[ -f /etc/alpine-release ]]; then
	set -x
	# set environment
		setenvironment
	# install required
        	install_package ca-certificates openssl pcre ca-certificates lua5.3-libs
	# install build libs
	BUILDLIB="gcc libc-dev linux-headers lua5.3-dev make openssl-dev pcre-dev readline-dev tar zlib-dev"
		install_package $BUILDLIB
	# download app
		downloadapp
	# make app
		makeapp
	# finish app
		finish
	# preparedata
		preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# redhat, centos
elif [[ -f /etc/redhat-release ]]; then
	# set environment
		setenvironment
	# install required
        	install_package ca-certificates
	# install build libs
	BUILDLIB="gcc make readline-devel pcre-devel openssl-devel"
		install_package $BUILDLIB
	# download app
		downloadapp
	# make app
		makeapp
	# finish app
		finish
	# preparedata
		preparedata
		downloadentry
	# clean
		clean_package
		clean_os
# other os
else
    say_err "Not support your OS"
    exit 1
fi