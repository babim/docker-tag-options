#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# check permission root
echo 'Check root'
if [ "x$(id -u)" != 'x0' ]; then
    echo 'Error: this script can only be executed by root'
    exit 1
fi

# set environment
setenvironment() {
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Netdata"
}
# install symlink
symlinkcreate() {
	ln -sf /dev/stdout /var/log/netdata/access.log
	ln -sf /dev/stdout /var/log/netdata/debug.log
	ln -sf /dev/stderr /var/log/netdata/error.log
}
# install netdata
installnetdata() {
	# fetch netdata
	git clone https://github.com/firehol/netdata.git /netdata.git --depth=1
	cd /netdata.git
	TAG=$(</git-tag)
	if [ ! -z "$TAG" ]; then
		echo "Checking out tag: $TAG"
		git checkout tags/$TAG
	else
		echo "No tag, using master"
	fi
	# use the provided installer
	./netdata-installer.sh --dont-wait --dont-start-it
	# remove git
	cd /
	rm -rf /netdata.git
	# prepare data
	if [[ -d /etc/netdata ]];then
		mkdir -p /etc-start
		cp -R /etc/netdata /etc-start/
	fi
}
# download docker entrypoint
downloadentry() {
	# download docker entry
	FILETEMP=/docker-entrypoint.sh
	[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP --no-check-certificate $DOWN_URL/netdata_start.sh
		chmod +x $FILETEMP
}
# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# set environment
		setenvironment
	# install depend
	apk add --no-cache alpine-sdk bash curl zlib-dev util-linux-dev libmnl-dev gcc make git autoconf automake pkgconfig python logrotate
	apk add --no-cache nodejs ssmtp
	# install netdata
		installnetdata
	# download docker entrypoint
		downloadentry
	# del dev tool
		wget --no-check-certificate -O - $DOWN_URL/netdata_clean.sh | bash
	# symlink access log and error log to stdout/stderr
		symlinkcreate
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# some mirrors have issues, i skipped httpredir in favor of an eu mirror
	echo "deb http://ftp.nl.debian.org/debian/ stretch main" > /etc/apt/sources.list
	echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list
	# install dependencies for build
	apt-get -qq update
	apt-get -y install zlib1g-dev uuid-dev libmnl-dev gcc make curl git autoconf autogen automake pkg-config netcat-openbsd jq
	apt-get -y install autoconf-archive lm-sensors nodejs python python-mysqldb python-yaml
	apt-get -y install msmtp msmtp-mta apcupsd fping
	# install netdata
		installnetdata
	# download docker entrypoint
		downloadentry
	# del dev tool
		wget --no-check-certificate -O - $DOWN_URL/netdata_clean.sh | bash
	# symlink access log and error log to stdout/stderr
		symlinkcreate
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# set environment
		setenvironment
	# install dependencies for build, need EPEL repo
	yum install -y autoconf automake curl gcc git libmnl-devel libuuid-devel lm_sensors make \
			MySQL-python nc pkgconfig python python-psycopg2 PyYAML zlib-devel
	# install netdata
		installnetdata
	# download docker entrypoint
		downloadentry
	# del dev tool
		wget --no-check-certificate -O - $DOWN_URL/netdata_clean.sh | bash
	# symlink access log and error log to stdout/stderr
		symlinkcreate
# OS - other
else
    echo "Not support your OS"
    exit
fi