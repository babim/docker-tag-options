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
		FREEFILESYNC=9.3_Ubuntu_16.04_64-bit
		IPSCAN=3.5.3
		CROSSOVER=16.2.5-1
		WIMLIB=1.12.0
		ADMINAPP=${ADMINAPP:-true}
	if [[ "$ADMINAPP" == "true" ]];then
		ADMINAPPALL=${ADMINAPPALL:-true}
	fi
	# install depend
		apt-get clean && dpkg --add-architecture i386 && \
		apt-get update && apt-get install -y software-properties-common apt-transport-https gnupg
	# add repo
		add-apt-repository ppa:atareao/atareao -y
		add-apt-repository ppa:diesch/testing -y
		add-apt-repository ppa:docky-core/stable -y
		add-apt-repository ppa:libreoffice/ppa -y
		add-apt-repository ppa:nilarimogard/webupd8 -y
		add-apt-repository ppa:n-muench/programs-ppa -y
		wget -O - http://deb.opera.com/archive.key | apt-key add - && echo "deb http://deb.opera.com/opera-stable/ stable non-free" >> /etc/apt/sources.list.d/opera.list
		wget -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
		add-apt-repository ppa:pipelight/stable -y
		add-apt-repository ppa:remmina-ppa-team/remmina-next -y
		add-apt-repository ppa:synapse-core/testing -y
		add-apt-repository ppa:teejee2008/ppa -y
		add-apt-repository ppa:tualatrix/ppa -y
		add-apt-repository ppa:ubuntu-wine/ppa -y
		add-apt-repository ppa:webupd8team/java -y

	# install GUI
		apt-get install xubuntu-desktop --no-install-recommends -y --force-yes
	# install app
		apt-get install -y --force-yes nano mousepad xfce4-taskmanager gnome-icon-theme-full firefox flashplugin-installer tightvncserver
    
	# install admin app
	if [[ "$ADMINAPP" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		apt-get install -y --force-yes && \
		filezilla mtr-tiny nload bmon iotop htop putty baobab glogg file-roller synaptic\
		regexxer fwbuilder font-manager gnome-subtitles mediainfo-gui gedit qbittorrent inetutils-ping\
		gtkorphan screenruler zenmap nmap rsync mysql-client ristretto thunar-archive-plugin\
		tomboy p7zip-full mc pyrenamer telnet\
		
		apt-get purge sane* scan* transmission* abiword* gnumeric* parole* banshee* totem* -y --force-yes
		# opera-stable google-chrome-stable
	fi
	# Wimlib
		if [[ "$WIMLIB_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		apt-get install -y libxml2-dev ntfs-3g-dev ntfs-3g libfuse-dev libattr1-dev libssl-dev pkg-config build-essential automake && \
		cd /tmp && wget https://wimlib.net/downloads/wimlib-$WIMLIB.tar.gz && tar xzvpf wimlib* && cd wimlib* && ./configure && make && make install && ldconfig && cd .. && \
		rm -rf /tmp/winlib*
		fi
	# crossover
		if [[ "$CROSSOVER_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		apt-get install -y gcc-5-base:i386 gcc-6-base:i386 krb5-locales libavahi-client3:i386 \
		libavahi-common-data:i386 libavahi-common3:i386 libbsd0:i386 libc6:i386 \
		libcomerr2:i386 libcups2:i386 libdbus-1-3:i386 libdrm-amdgpu1:i386 \
		libdrm-intel1:i386 libdrm-nouveau2:i386 libdrm-radeon1:i386 libdrm2:i386 \
		libedit2:i386 libelf1:i386 libexpat1:i386 libffi6:i386 libfreetype6:i386 \
		libgcc1:i386 libgcrypt20:i386 libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 \
		libglapi-mesa:i386 libglu1-mesa:i386 libgmp10:i386 libgnutls30:i386 \
		libgpg-error0:i386 libgssapi-krb5-2:i386 libhogweed4:i386 libidn11:i386 \
		libk5crypto3:i386 libkeyutils1:i386 libkrb5-3:i386 libkrb5support0:i386 \
		liblcms2-2:i386 libllvm3.8:i386 liblzma5:i386 libnettle6:i386 \
		libp11-kit0:i386 libpciaccess0:i386 libpcre3:i386 libpng12-0:i386 \
		libselinux1:i386 libstdc++6:i386 libsystemd0:i386 libtasn1-6:i386 \
		libtinfo5:i386 libtxc-dxtn-s2tc0:i386 libudev1:i386 libx11-6:i386 \
		libx11-xcb1:i386 libxau6:i386 libxcb-dri2-0:i386 libxcb-dri3-0:i386 \
		libxcb-glx0:i386 libxcb-present0:i386 libxcb-sync1:i386 libxcb1:i386 \
		libxcursor1:i386 libxdamage1:i386 libxdmcp6:i386 libxext6:i386 \
		libxfixes3:i386 libxi6:i386 libxrandr2:i386 libxrender1:i386 \
		libxshmfence1:i386 libxxf86vm1:i386 zlib1g:i386 && \
		cd /tmp && wget http://media.matmagoc.com/crossover_$CROSSOVER.deb && dpkg -i crossover*.deb && \
		rm -rf /tmp/crossover*
		FILETEMP=/opt/cxoffice/lib/wine/winewrapper.exe.so
		[[ ! -f $FILETEMP ]] || rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/crossover/winewrapper.exe.so
		fi
	# freefile sync
		if [[ "$FREEFILESYNC_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		wget http://media.matmagoc.com/FreeFileSync_$FREEFILESYNC.tar.gz && \
		tar -xzvpf FreeFileSync_$FREEFILESYNC.tar.gz -C /opt && rm -f FreeFileSync_$FREEFILESYNC.tar.gz
		mkdir -p /root/Desktop
		wget -O /root/Desktop/FreeFileSync.desktop http://media.matmagoc.com/FreeFileSync.desktop && \
		chmod +x /root/Desktop/FreeFileSync.desktop
		fi
		    
	# navicat_premium
		if [[ "$NAVICAT_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		wget http://media.matmagoc.com/navicat_premium.tar.gz && \
		tar -xzvpf navicat_premium.tar.gz -C /opt && rm -f navicat_premium.tar.gz
		wget -O /root/Desktop/navicat.desktop http://media.matmagoc.com/navicat.desktop && \
		chmod +x /root/Desktop/navicat.desktop
		fi

	# razorsql
		if [[ "$RAZORSQL_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		wget http://media.matmagoc.com/razorsql_linux_x64.tar.gz && \
		tar -xzvpf razorsql_linux_x64.tar.gz -C /opt && rm -f razorsql_linux_x64.tar.gz && \
		wget http://media.matmagoc.com/razorsqlreg.tar.gz && \
		tar -xzvpf razorsqlreg.tar.gz -C /root && rm -f razorsqlreg.tar.gz
		wget -O /root/Desktop/razorsql.desktop http://media.matmagoc.com/razorsql.desktop && \
		chmod +x /root/Desktop/razorsql.desktop
		fi
		    
	# angry ip scanner
		if [[ "$IPSCAN_OPTION" == "true" ]] || [[ "$ADMINAPPALL" == "true" ]];then
		wget https://github.com/angryip/ipscan/releases/download/$IPSCAN/ipscan_$IPSCAN_amd64.deb && \
		apt-get install -y --force-yes \
		ca-certificates-java fonts-dejavu-extra java-common libbonobo2-0 \
		libbonobo2-common libgnome-2-0 libgnome2-common libgnomevfs2-0 \
		libgnomevfs2-common liborbit-2-0 openjdk-8-jre openjdk-8-jre-headless && \
		dpkg -i ipscan_$IPSCAN.deb && rm -f ipscan_$IPSCAN.deb
		fi

	# Define default command.
		FILETEMP=/startup.sh
		echo '#!/bin/bash' > $FILETEMP && \
		echo '# option with entrypoint' >> $FILETEMP && \
		echo 'if [ -f "/option.sh" ]; then /option.sh; fi' >> $FILETEMP && \
		echo "rm -rf /tmp/.X*" >> $FILETEMP && \
		echo "USER=root" >> $FILETEMP && \
		echo "HOME=/root" >> $FILETEMP && \
		echo "export USER HOME" >> $FILETEMP && \
		echo "vncserver :1" >> $FILETEMP && \
		chmod +x $FILETEMP

else
    echo "Not support your OS"
    exit
fi