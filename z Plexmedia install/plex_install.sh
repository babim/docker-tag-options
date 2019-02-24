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

# set loop
prepareconfig() {
		FILETEMP=/Preferences.xml
			[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP
		FILETEMP=/plex-entrypoint.sh
			[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP
			chmod +x $FILETEMP
		FILETEMP=/usr/local/bin/retrieve-plex-token
			[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP
		}

# set environment
DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Plexmedia%20install"
DEBIAN_FRONTEND=noninteractive

echo 'Check OS'
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# Install basic required packages.
		set -x \
 		&& apt-get update \
 		&& apt-get install -y --no-install-recommends \
			ca-certificates curl xmlstarlet

	# Install Plex
		set -x \
	# Create plex user
		useradd --system --uid 797 -M --shell /usr/sbin/nologin plex
	# Download and install Plex (non plexpass) after displaying downloaded URL in the log.
	# This gets the latest non-plexpass version
	# Note: We created a dummy /bin/start to avoid install to fail due to upstart not being installed.
	# We won't use upstart anyway.
		curl -I 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' \
		&& curl -L 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' -o plexmediaserver.deb \
		&& touch /bin/start \
		&& chmod +x /bin/start \
		&& dpkg -i plexmediaserver.deb \
		&& rm -f plexmediaserver.deb \
		&& rm -f /bin/start
	# Install dumb-init
	# https://github.com/Yelp/dumb-init
		DUMP_INIT_URI=$(curl -L https://github.com/Yelp/dumb-init/releases/latest | grep -Po '(?<=href=")[^"]+_amd64(?=")') \
		&& curl -Lo /usr/local/bin/dumb-init "https://github.com/$DUMP_INIT_URI" \
		&& chmod +x /usr/local/bin/dumb-init
	# Create writable config directory in case the volume isn't mounted
		mkdir /config \
		&& chown plex:plex /config

	# Clean
		apt-get clean \
		&& rm -rf /var/lib/apt/lists/*
	# preconfig
		prepareconfig

elif [[ -f /etc/alpine-release ]]; then
	# Here we install GNU libc (aka glibc) and set C.UTF-8 locale as default.
	DESTDIR="/glibc"
	GLIBC_LIBRARY_PATH="$DESTDIR/lib" DEBS="libc6 libgcc1 libstdc++6"
	GLIBC_LD_LINUX_SO="$GLIBC_LIBRARY_PATH/ld-linux-x86-64.so.2"

	cd /tmp

	apk add --no-cache xz binutils patchelf \
	 && wget http://ftp.debian.org/debian/pool/main/g/glibc/libc6_2.27-6_amd64.deb \
	 && wget http://ftp.debian.org/debian/pool/main/g/gcc-4.9/libgcc1_4.9.2-10+deb8u1_amd64.deb \
	 && wget http://ftp.debian.org/debian/pool/main/g/gcc-4.9/libstdc++6_4.9.2-10+deb8u1_amd64.deb \
	 && for pkg in $DEBS; do \
	        mkdir $pkg; \
	        cd $pkg; \
	        ar x ../$pkg*.deb; \
	        tar -xf data.tar.*; \
	        cd ..; \
	    done \
	 && mkdir -p $GLIBC_LIBRARY_PATH \
	 && mv libc6/lib/x86_64-linux-gnu/* $GLIBC_LIBRARY_PATH \
	 && mv libgcc1/lib/x86_64-linux-gnu/* $GLIBC_LIBRARY_PATH \
	 && mv libstdc++6/usr/lib/x86_64-linux-gnu/* $GLIBC_LIBRARY_PATH \
	 && apk del --no-cache xz \
	 && rm -rf /tmp/*

	# install Plex
	PUID=797
	PUNAME=plex
	PGID=797
	PGNAME=plex
		FILETEMP=/start_pms.patch
			[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP

	addgroup -g $PGID $PGNAME \
	 && adduser -SH -u $PUID -G $PGNAME -s /usr/sbin/nologin $PUNAME \
	 && apk add --no-cache xz binutils patchelf openssl file xmlstarlet \
	 && wget -O plexmediaserver.deb 'https://plex.tv/downloads/latest/1?channel=8&build=linux-ubuntu-x86_64&distro=ubuntu' \
	 && ar x plexmediaserver.deb \
	 && tar -xf data.tar.* \
	 && find usr/lib/plexmediaserver -type f -perm /0111 -exec sh -c "file --brief \"{}\" | grep -q "ELF" && patchelf --set-interpreter \"$GLIBC_LD_LINUX_SO\" \"{}\" " \; \
	 && mv /tmp/start_pms.patch usr/sbin/ \
	 && cd usr/sbin/ \
	 && patch < start_pms.patch \
	 && cd /tmp \
	 && sed -i "s|<destdir>|$DESTDIR|" usr/sbin/start_pms \
	 && chmod 777 /tmp \
	 && mv usr/sbin/start_pms $DESTDIR/ \
	 && mv usr/lib/plexmediaserver $DESTDIR/plex-media-server

	# Clean
	 apk del --no-cache xz binutils \
	 && rm -rf /tmp/*
	# preconfig
		prepareconfig

else
    echo "Not support your OS"
    exit
fi