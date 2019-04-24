#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

export CROSSOVER=${CROSSOVER:-18.5.0-1}
	install_package gcc-5-base:i386 gcc-6-base:i386 krb5-locales libavahi-client3:i386 \
	libavahi-common-data:i386 libavahi-common3:i386 libbsd0:i386 libc6:i386 \
	libcomerr2:i386 libcups2:i386 libdbus-1-3:i386 libdrm-amdgpu1:i386 \
	libdrm-intel1:i386 libdrm-nouveau2:i386 libdrm-radeon1:i386 libdrm2:i386 \
	libedit2:i386 libelf1:i386 libexpat1:i386 libffi6:i386 libfreetype6:i386 \
	libgcc1:i386 libgcrypt20:i386 libgl1-mesa-dri:i386 libgl1-mesa-glx:i386 \
	libglapi-mesa:i386 libglu1-mesa:i386 libgmp10:i386 libgnutls30:i386 \
	libgpg-error0:i386 libgssapi-krb5-2:i386 libhogweed4:i386 libidn11:i386 \
	libk5crypto3:i386 libkeyutils1:i386 libkrb5-3:i386 libkrb5support0:i386 \
	liblcms2-2:i386 liblzma5:i386 libnettle6:i386 \
	libp11-kit0:i386 libpciaccess0:i386 libpcre3:i386 \
	libselinux1:i386 libstdc++6:i386 libsystemd0:i386 libtasn1-6:i386 \
	libtinfo5:i386 libtxc-dxtn-s2tc0:i386 libudev1:i386 libx11-6:i386 \
	libx11-xcb1:i386 libxau6:i386 libxcb-dri2-0:i386 libxcb-dri3-0:i386 \
	libxcb-glx0:i386 libxcb-present0:i386 libxcb-sync1:i386 libxcb1:i386 \
	libxcursor1:i386 libxdamage1:i386 libxdmcp6:i386 libxext6:i386 \
	libxfixes3:i386 libxi6:i386 libxrandr2:i386 libxrender1:i386 \
	libxshmfence1:i386 libxxf86vm1:i386 zlib1g:i386
	cd /tmp
	FILETEMP=crossover_${CROSSOVER}.deb
		$download_save http://media.matmagoc.com/$FILETEMP && install_package $FILETEMP
		remove_filefolder /tmp/crossover*
	FILETEMP=/opt/cxoffice/lib/wine/winewrapper.exe.so
		remove_file $FILETEMP
		$download_save $FILETEMP $DOWN_URL/crossover/winewrapper.exe.so