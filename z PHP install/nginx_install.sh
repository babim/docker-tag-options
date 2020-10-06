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
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install"
	export nginx=stable
	# set ID nginx run
	export auid=${auid:-33}
	export agid=${agid:-$auid}
	export auser=${auser:-www-data}
	export aguser=${aguser:-$auser}
}

	# install font
	if has_value "${FONT}" && ! check_value_false "${FONT}"; then
		FILETEMP=truetype.zip
			$download_save $FILETEMP http://file.matmagoc.com/$FILETEMP
		rm -rf /usr/share/fonts/truetype/*
			install_package_run unzip
			unzip_extract $FILETEMP /usr/share/fonts/truetype
	fi

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
	# add repo and install nginx
	    echo "deb http://ppa.launchpad.net/nginx/$nginx/ubuntu xenial main" > /etc/apt/sources.list.d/nginx-$nginx.list && \
	    debian_add_repo_key C300EE8C && \
	    install_package nginx && \
	    set_filefolder_owner $auser:$aguser /var/lib/nginx && \
	    remove_package apache*

	# create folder
		create_folder 	/var/cache/nginx
		create_folder 	/var/log/nginx

	# forward request and error logs to docker log collector
		create_symlink 	/dev/stdout /var/log/nginx/access.log
		create_symlink 	/dev/stderr /var/log/nginx/error.log

	# include
		run_url $DOWN_URL/nginx_include.sh

	# install php
	if has_value "${PHP_VERSION}" && ! check_value_false "${PHP_VERSION}"; then
		run_url https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/php_install.sh
	fi

	# Supervisor
		run_url $DOWN_URL/supervisor.sh
	# download entrypoint
		FILETEMP=/start.sh
			$download_save $FILETEMP $DOWN_URL/start.sh
			set_filefolder_mod 755 $FILETEMP
	# prepare etc start
	   	run_url $DOWN_URL/prepare_final.sh

	# clean os
		clean_os

	# forward request and error logs to docker log collector
	create_symlink /dev/stdout /var/log/nginx/access.log \
	&& create_symlink /dev/stderr /var/log/nginx/error.log

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
