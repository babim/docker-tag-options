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
	MODSECURITY=${MODSECURITY:-false}
	PAGESPEED=${PAGESPEED:-false}
	PHP_VERSION=${PHP_VERSION:-false}
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
	# set environment
		setenvironment
		debian_cmd_interface

	# add repo apache
		debian_add_repo ppa:ondrej/apache2
	# install apache
		install_package apache2
	# enable apache mod
	  	check_folder /etc/apache2 && a2enmod rewrite headers http2 ssl || say "Not have apache on this server"

	# default config with mod rewrite
	CONFIGMODREWRITE=${CONFIGMODREWRITE:-true}
	if check_value_true "$CONFIGMODREWRITE"; then
		# config default site
		FILETEMP=/etc/apache2/sites-available
			create_folder $FILETEMP
		FILETEMP=/etc/apache2/sites-available/000-default.conf
			$download_save $FILETEMP $DOWN_URL/apache_config/000-default.conf
		FILETEMP=/etc/apache2/sites-available/default-ssl.conf
			$download_save $FILETEMP $DOWN_URL/apache_config/default-ssl.conf
		# config ssl default
		FILETEMP=/etc/apache2/certs
			create_folder $FILETEMP
		FILETEMP=/etc/apache2/certs/example-cert.pem
			$download_save $FILETEMP $DOWN_URL/ssl/example-cert.pem
		FILETEMP=/etc/apache2/certs/example-key.pem
			$download_save $FILETEMP $DOWN_URL/ssl/example-key.pem
		FILETEMP=/etc/apache2/certs/ca-cert.pem
			$download_save $FILETEMP $DOWN_URL/ssl/ca-cert.pem
	fi

	# install modsecurity
	if check_value_true "$MODSECURITY"; then
		if check_folder_empty /etc/apache2; then
			install_package libapache2-mod-security2
			a2enmod security2
		else
			say "Not have Apache2 on this Server"
		fi
		create_file /MODSECUROTY.check
	fi
	# install pagespeed
	if check_value_true "$PAGESPEED"; then
		if check_folder_empty /etc/apache2; then
		FILETEMP=mod-pagespeed-stable_current_amd64.deb
			$download_save $FILETEMP https://dl-ssl.google.com/dl/linux/direct/$FILETEMP
			install_package $FILETEMP
			remove_file $FILETEMP
		else
			say "Not have Apache2 on this Server"
		fi
	   	create_file /PAGESPEED.check
	fi

	# install php
	if has_value "${PHP_VERSION}" && ! check_value_false "${PHP_VERSION}"; then
		run_url $DOWN_URL/php_install.sh
	fi

	# Supervisor
		run_url $DOWN_URL/supervisor.sh

	# download entrypoint
		FILETEMP=/start.sh
			$download_save $FILETEMP $DOWN_URL/start.sh
			set_filefolder_mod 755 $FILETEMP
	# prepare etc start
		run_url $DOWN_URL/prepare_final.sh

	# clean
		remove_download_tool
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi