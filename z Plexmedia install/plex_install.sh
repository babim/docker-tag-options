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

# set loop
prepareconfig() {
		FILETEMP=/Preferences.xml
			$download_save $FILETEMP $DOWN_URL/config/$FILETEMP
		FILETEMP=/plex-entrypoint.sh
			$download_save $FILETEMP $DOWN_URL/config/$FILETEMP
			set_filefolder_mod +x $FILETEMP
		FILETEMP=/usr/local/bin/retrieve-plex-token
			$download_save $FILETEMP $DOWN_URL/config/$FILETEMP
}

# set environment
setenvironment() {
# set host download
	export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Plexmedia%20install"
# uninstall app after install
	export UNINSTALL=""
# set software
	export SOFT=plex
# set ID docker run
	export auid=${auid:-797}
	export agid=${agid:-$auid}
	export auser=${auser:-plex}
	export aguser=${aguser:-$auser}
}

#install acdcli
installacdcli() {
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# install python 3, fuse, and git
		install_package python3 python3-appdirs python3-dateutil python3-requests python3-sqlalchemy python3-pip git
elif [[ -f /etc/alpine-release ]]; then
	# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
	# create dirs for the config, local mount point, and cloud destination
		#mkdir /config /cache /data /cloud
		create_folders /cache /data /cloud
	# set the cache, settings, and libfuse path accordingly
		export ACD_CLI_CACHE_PATH=/cache
		export ACD_CLI_SETTINGS_PATH=/cache
		export LIBFUSE_PATH=/usr/lib/libfuse.so.2
	# install python 3, fuse, and git
		install_package python3 fuse git && pip3 install --upgrade pip
else
	say_err "Not support your OS"
	exit 1
fi
# install acdcli
	pip3 install --upgrade git+https://github.com/yadayada/acd_cli.git
## download entrypoint
	FILETEMP=acdcli-entrypoint.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
}
#install gdrive
installgdrive() {
export DRIVE_PATH=${DRIVE_PATH:-/media}
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# install depend
		install_package gnupg
	# install google-drive-ocamlfuse
		echo "deb http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list
		echo "deb-src http://ppa.launchpad.net/alessandro-strada/ppa/ubuntu bionic main" >> /etc/apt/sources.list
		apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F639B041
		apt-get update
		apt-get install -yy google-drive-ocamlfuse fuse
		echo "user_allow_other" >> /etc/fuse.conf
else
	say_err "Not support your OS"
	exit 1
fi
## download entrypoint
	FILETEMP=gdrive-entrypoint.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
}
#install openvpn
installopenvpn() {
## Supervisor
	install_supervisor
	### Supervisor config
		create_folder /var/log/supervisor/
		create_folder /etc/supervisor/conf.d/
	### download sypervisord config
	FILETEMP=supervisor/supervisord.conf
	 	$download_save /etc/$FILETEMP ${DOWN_URL}/${FILETEMP}
	FILETEMP=/etc/supervisord.conf
		create_symlink $FILETEMP /etc/supervisor/supervisord.conf
	#openvpn
	FILETEMP=supervisor/conf.d/openvpn.conf
	 	$download_save /etc/$FILETEMP ${DOWN_URL}/${FILETEMP}
	#plex
	FILETEMP=supervisor/conf.d/plex.conf
	 	$download_save /etc/$FILETEMP ${DOWN_URL}/${FILETEMP}
	#syslog
	FILETEMP=supervisor/conf.d/syslog.conf
	 	$download_save /etc/$FILETEMP ${DOWN_URL}/${FILETEMP}
	# prepare etc start
		check_folder 	/etc-start	&& remove_folder /etc-start				|| say "/etc-start not exist"
	# supervisor
		create_folder 	/etc-start/supervisor
		check_folder	/etc/supervisor	&& dircopy /etc/supervisor /etc-start/supervisor	|| say "no need copy supervisor config"

# openvpn
if [[ -f /etc/alpine-release ]]; then
	echo "http://dl-4.alpinelinux.org/alpine/edge/community/" >> /etc/apk/repositories
	echo "http://dl-4.alpinelinux.org/alpine/edge/testing/" >> /etc/apk/repositories
	install_package rsyslog openvpn
# OS - other
else
	say_err "Not support your OS"
	exit 1
fi
## download entrypoint
	FILETEMP=openvpn-entrypoint.sh
		$download_save /$FILETEMP $DOWN_URL/$FILETEMP && \
		set_filefolder_mod 755 /$FILETEMP
}

# finish_install
finish_install() {
	# acdcli
		check_value_true "${ACDCLI_OPTION}" && installacdcli
	# gdrive
		check_value_true "${GDRIVE_OPTION}" && installgdrive
	# openvpn
		check_value_true "${OPENVPN_OPTION}" && installopenvpn

	# preconfig
		prepareconfig
	# clean
		remove_download_tool
		clean_os
}

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
	# Install basic required packages.
		install_package ca-certificates curl xmlstarlet

	# Install Plex
	# Create plex user
		useradd --system --uid $auid -M --shell /usr/sbin/nologin $auser
	# Download and install Plex (non plexpass) after displaying downloaded URL in the log.
	# This gets the latest non-plexpass version
	# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
	# We won't use upstart anyway.
		#curl -I 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu'
		$download_save plexmediaserver.deb 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu'
		create_file /bin/start
		set_filefolder_mod +x /bin/start
		install_package plexmediaserver.deb
		remove_file plexmediaserver.deb
		remove_file /bin/start
	# Install dumb-init
	# https://github.com/Yelp/dumb-init
		DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")')
		$download_save /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI"
		set_filefolder_mod +x /usr/local/bin/dumb-init
	# Create writable config directory in case the volume isn't mounted
		create_folder /config
		set_filefolder_owner $auser:$aguser /config

	# finish
		finish_install

elif [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
	DESTDIR="/glibc"
	GLIBC_LIBRARY_PATH="$DESTDIR/lib" DEBS="libc6 libgcc1 libstdc++6"
	GLIBC_LD_LINUX_SO="$GLIBC_LIBRARY_PATH/ld-linux-x86-64.so.2"

	cd /tmp

	install_package xz binutils patchelf
	FILETEMP=libc6_2.29-9_amd64.deb
	$download_save $FILETEMP http://ftp.debian.org/debian/pool/main/g/glibc/$FILETEMP
	FILETEMP=libgcc1_4.9.2-10+deb8u1_amd64.deb
	$download_save $FILETEMP http://ftp.debian.org/debian/pool/main/g/gcc-4.9/$FILETEMP
	FILETEMP=libstdc++6_4.9.2-10+deb8u1_amd64.deb
	$download_save $FILETEMP http://ftp.debian.org/debian/pool/main/g/gcc-4.9/$FILETEMP
	for pkg in $DEBS; do
		mkdir $pkg
	        cd $pkg
	        ar x ../$pkg*.deb
	        tar -xf data.tar.*
	        cd ..
	done
	create_folder $GLIBC_LIBRARY_PATH
	mv libc6/lib/x86_64-linux-gnu/* $GLIBC_LIBRARY_PATH
	mv libgcc1/lib/x86_64-linux-gnu/* $GLIBC_LIBRARY_PATH
	mv libstdc++6/usr/lib/x86_64-linux-gnu/* $GLIBC_LIBRARY_PATH
	remove_package xz \
	remove_filefolder /tmp/*

		FILETEMP=/start_pms.patch
			$download_save $FILETEMP $DOWN_URL/config/$FILETEMP

	addgroup -g $agid $aguser \
	 && adduser -SH -u $agid -G $aguser -s /usr/sbin/nologin $auser \
	 && install_package xz binutils patchelf openssl file xmlstarlet \
	 && $download_save plexmediaserver.deb 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' \
	 && ar x plexmediaserver.deb \
	 && tar -xf data.tar.* \
	 && find usr/lib/plexmediaserver -type f -perm /0111 -exec sh -c "file --brief \"{}\" | grep -q "ELF" && patchelf --set-interpreter \"$GLIBC_LD_LINUX_SO\" \"{}\" " \; \
	 && mv /tmp/start_pms.patch usr/sbin/ \
	 && cd usr/sbin/ \
	 && patch < start_pms.patch \
	 && cd /tmp \
	 && sed -i "s|<destdir>|$DESTDIR|" usr/sbin/start_pms \
	 && set_filefolder_mod 777 /tmp \
	 && mv usr/sbin/start_pms $DESTDIR/ \
	 && mv usr/lib/plexmediaserver $DESTDIR/plex-media-server

	# finish
		finish_install

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi