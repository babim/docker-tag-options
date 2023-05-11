#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
## set -u
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
	export DEBIAN_FRONTEND=noninteractive
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Xubuntu%20install"
	ADMINAPP=${ADMINAPP:-true}
	check_value_true "$ADMINAPP" 	&& ADMINAPPALL=${ADMINAPPALL:-true}	|| say "Will not install admin apps"
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
	# set environment
		setenvironment
		debian_cmd_interface	
	# install depend
		apt-get clean && dpkg --add-architecture i386 && \
		install_package software-properties-common apt-transport-https gnupg
	# add repo
		debian_add_repo atareao/atareao
		debian_add_repo diesch/testing
		debian_add_repo libreoffice/ppa
		debian_add_repo nilarimogard/webupd8
		debian_add_repo_key http://deb.opera.com/archive.key && echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list
		debian_add_repo_key https://dl-ssl.google.com/linux/linux_signing_key.pub && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
		debian_add_repo teejee2008/ppa
		#debian_add_repo webupd8team/java
		debian_add_repo_key https://packages.microsoft.com/keys/microsoft.asc && echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" >> /etc/apt/sources.list.d/edge.list
	# install GUI
		install_package xubuntu-desktop
	# install app 
		install_package nano mousepad xfce4-taskmanager firefox xul-ext-ubufox microsoft-edge-stable ristretto catfish thunar
    
	# install admin app
	if check_value_true "$ADMINAPP" || check_value_true "$ADMINAPPALL";then
		install_package \
		filezilla mtr-tiny nload bmon iotop htop putty baobab glogg synaptic \
		regexxer font-manager mediainfo-gui gedit qbittorrent inetutils-ping \
		screenruler rsync mysql-client thunar-archive-plugin \
		p7zip-full mc telnet nmap
		# zenmap tomboy
		
		remove_package sane* scan* transmission* abiword* gnumeric* parole* banshee* totem*
		# opera-stable google-chrome-stable
	fi
	# Wimlib
		if check_value_true "$WIMLIB_OPTION" 		|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/wimlib_install.sh
		fi
	# crossover
		if check_value_true "$CROSSOVER_OPTION" 	|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/crossover_install.sh
		fi
	# freefile sync
		if check_value_true "$FREEFILESYNC_OPTION" 	|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/freefilesync_install.sh
		fi

	# navicat_premium
		if check_value_true "$NAVICAT_OPTION" 		|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/navicat_install.sh
		fi

	# razorsql
		if check_value_true "$RAZORSQL_OPTION" 		|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/razorsql_install.sh
		fi

	# angry ip scanner
		if check_value_true "$IPSCAN_OPTION" 		|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/angryip_install.sh
		fi
	# REALVNC Server
		if check_value_true "$REALVNC_OPTION" 		|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/realvnc_install.sh
		fi

	# google drive ocamfuse
		if check_value_true "$GDRIVE_OPTION" 		|| check_value_true "$ADMINAPPALL";then
			run_url $DOWN_URL/crossover_install.sh
		fi

# Web server
	# APACHE
		if check_value_true "$APACHE_OPTION";then
			run_url https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/apache_install.sh
		fi
	# NGINX
		if check_value_true "$NGINX_OPTION";then
			run_url https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/nginx_install.sh
		fi

# prepare etc start
		run_url $DOWN_URL/prepare_final.sh

# Define default command.
		FILETEMP=/startup.sh
			remove_file 			$FILETEMP
			$download_save 			$FILETEMP 	$DOWN_URL/$FILETEMP
			set_filefolder_mod 		755 		$FILETEMP
	# clean
		clean_os

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
