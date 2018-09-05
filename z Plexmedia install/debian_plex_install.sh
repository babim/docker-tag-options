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
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
	DEBIAN_FRONTEND=noninteractive
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Plexmedia%20install"

	# Install basic required packages.
		set -x \
 		&& apt-get update \
 		&& apt-get install -y --no-install-recommends \
			ca-certificates curl xmlstarlet

	# Install Plex
		set -x \
	# Create plex user
		&& useradd --system --uid 797 -M --shell /usr/sbin/nologin plex \
	# Download and install Plex (non plexpass) after displaying downloaded URL in the log.
	# This gets the latest non-plexpass version
	# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
	# We won't use upstart anyway.
		&& curl -I 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' \
		&& curl -L 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' -o plexmediaserver.deb \
		&& touch /bin/start \
		&& chmod +x /bin/start \
		&& dpkg -i plexmediaserver.deb \
		&& rm -f plexmediaserver.deb \
		&& rm -f /bin/start \
	# Install dumb-init
	# https://github.com/Yelp/dumb-init
		&& DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")') \
		&& curl -Lo /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI" \
		&& chmod +x /usr/local/bin/dumb-init \
	# Create writable config directory in case the volume isn't mounted
		&& mkdir /config \
		&& chown plex:plex /config

	# Clean
		apt-get clean \
		&& rm -rf /var/lib/apt/lists/*

		prepareconfig() {
		FILETEMP=/Preferences.xml
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP
		FILETEMP=/plex-entrypoint.sh
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP
			chmod +x $FILETEMP
		FILETEMP=/usr/local/bin/retrieve-plex-token
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP
		}
			prepareconfig

else
    echo "Not support your OS"
    exit
fi