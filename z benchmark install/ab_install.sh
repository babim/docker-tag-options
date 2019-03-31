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
		export SOFT=${SOFT:-ab}
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20benchmark%20install"

dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_fixed.sh
		chmod +x $FILETEMP
}
cleanpackage() {
	# remove packages
		wget --no-check-certificate -O - $DOWN_URL/${SOFT}_clean.sh | bash
}

# install by OS
echo 'Check OS'
# OS - alpine linux
if [[ -f /etc/alpine-release ]]; then
	# install
		apk add --no-cache apache2-utils	
	# done
		dockerentry
		cleanpackage
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# install
		apt-get update
		apt-get install --quiet --yes --no-install-recommends apache2-utils
	# done
		dockerentry
		cleanpackage
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# install
		yum install -y httpd-tools
	# done
		dockerentry
		cleanpackage
# OS - other
else
    echo "Not support your OS"
    exit
fi