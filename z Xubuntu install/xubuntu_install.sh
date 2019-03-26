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
if [[ -f /etc/lsb-release ]]; then
	# set environment
	export DEBIAN_FRONTEND=noninteractive
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Xubuntu%20install"
		export ADMINAPP=${ADMINAPP:-true}
	if [[ "$ADMINAPP" == "true" ]];then
		ADMINAPPALL=${ADMINAPPALL:-true}
	fi
	# install depend
		apt-get clean && dpkg --add-architecture i386 && \
		apt-get update && apt-get install -y software-properties-common apt-transport-https gnupg
	# add repo
		add-apt-repository ppa:atareao/atareao -y
		add-apt-repository ppa:diesch/testing -y
		add-apt-repository ppa:libreoffice/ppa -y
		add-apt-repository ppa:nilarimogard/webupd8 -y
		wget --no-check-certificate -O - http://deb.opera.com/archive.key | apt-key add - && echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list
		wget --no-check-certificate -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
		add-apt-repository ppa:teejee2008/ppa -y
		add-apt-repository ppa:webupd8team/java -y
	apt-get update
	# install GUI
		apt-get install xubuntu-desktop --no-install-recommends -y --force-yes
	# install app
		apt-get install -y --force-yes nano mousepad xfce4-taskmanager firefox flashplugin-installer enrampa ristretto catfish thunar
    
# install admin app
	if [[ "$ADMINAPP" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		apt-get install -y --force-yes \
		filezilla mtr-tiny nload bmon iotop htop putty baobab glogg synaptic \
		regexxer fwbuilder font-manager mediainfo-gui gedit qbittorrent inetutils-ping \
		gtkorphan screenruler zenmap nmap rsync mysql-client thunar-archive-plugin \
		tomboy p7zip-full mc telnet fdupes duperemove
		
		apt-get purge sane* scan* transmission* abiword* gnumeric* parole* banshee* totem* -y --force-yes
		# opera-stable google-chrome-stable
	fi
	# Wimlib
		if [[ "$WIMLIB_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
			wget --no-check-certificate -O - $DOWN_URL/wimlib_install.sh | bash
		fi
	# crossover
		if [[ "$CROSSOVER_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
			wget --no-check-certificate -O - $DOWN_URL/crossover_install.sh | bash
		fi
	# freefile sync
		if [[ "$FREEFILESYNC_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
			wget --no-check-certificate -O - $DOWN_URL/freefilesync_install.sh | bash
		fi

	# navicat_premium
		if [[ "$NAVICAT_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
			wget --no-check-certificate -O - $DOWN_URL/navicat_install.sh | bash
		fi

	# razorsql
		if [[ "$RAZORSQL_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
			wget --no-check-certificate -O - $DOWN_URL/razorsql_install.sh | bash
		fi

	# angry ip scanner
		if [[ "$IPSCAN_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then

				wget --no-check-certificate -O - $DOWN_URL/angryip_install.sh | bash
		fi
	# REALVNC Server
		if [[ "$REALVNC_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then

				wget --no-check-certificate -O - $DOWN_URL/realvnc_install.sh | bash
		fi

	# google drive ocamfuse
		if [[ "$GDRIVE_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
			wget --no-check-certificate -O - $DOWN_URL/crossover_install.sh | bash
		fi

# Web server
	# APACHE
		if [[ "$APACHE_OPTION" == "true" ]];then
			wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/apache_install.sh | bash
		fi
	# NGINX
		if [[ "$NGINX_OPTION" == "true" ]];then
			wget --no-check-certificate -O - https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/nginx_install.sh | bash
		fi

# prepare etc start
			wget --no-check-certificate -O - $DOWN_URL/prepare_final.sh | bash

# Define default command.
		FILETEMP=/startup.sh
			[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/$FILETEMP
			chmod 755 $FILETEMP

else
    echo "Not support your OS"
    exit
fi