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
		export SOFT=${SOFT:-wrk}
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20benchmark%20install"

installsoft() {
		cd / && git clone https://github.com/wg/${SOFT}.git ${SOFT} && \
		cd ${SOFT} && make && cp ${SOFT} /usr/local/bin && \
		cd / && rm -rf /${SOFT}
}
dockerentry() {
	# download docker entry
		FILETEMP=/docker-entrypoint.sh
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
			wget -O $FILETEMP --no-check-certificate $DOWN_URL/${SOFT}_start.sh
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
	# install depend
		#apk add --no-cache alpine-sdk libgcc openssl-dev git linux-headers
		apk add --no-cache ${SOFT}
	# install
	#	installsoft		
	# done
		dockerentry
		cleanpackage
# OS - ubuntu debian
elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# Set frontend debian
		export DEBIAN_FRONTEND=noninteractive
	# install depend
		apt-get update
		apt-get install --quiet --yes --no-install-recommends build-essential libssl-dev git
	# install
		installsoft
	# done
		dockerentry
		cleanpackage
# OS - redhat
elif [[ -f /etc/redhat-release ]]; then
	# install depend
		yum groupinstall 'Development Tools' -y
		yum install -y openssl-devel git 
	# install
		installsoft
	# done
		dockerentry
		cleanpackage
# OS - other
else
    echo "Not support your OS"
    exit
fi