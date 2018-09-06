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
if [[ -f /etc/alpine-release ]]; then
	# set environment
	DOWN_URL="--no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Plexmedia%20install"

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
	UID=797
	UNAME=plex
	GID=797
	GNAME=plex
		FILETEMP=/start_pms.patch
			[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
			wget -O $FILETEMP $DOWN_URL/config/$FILETEMP

	addgroup -g $GID $GNAME \
	 && adduser -SH -u $UID -G $GNAME -s /usr/sbin/nologin $UNAME \
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
	 && mv usr/lib/plexmediaserver $DESTDIR/plex-media-server \
	 && apk del --no-cache xz binutils \
	 && rm -rf /tmp/*

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