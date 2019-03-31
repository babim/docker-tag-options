#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

export UNINSTALL="wget git"

 	if [[ -f /etc/redhat-release ]]; then
		[[ ! -z "${UNINSTALL}" ]] && yum remove -y $UNINSTALL || echo "not have apps need remove"
		yum groupremove 'Development Tools' -y
		yum clean all
 	elif [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
		[[ ! -z "${UNINSTALL}" ]] && apt-get purge -y $UNINSTALL build-essential || echo "not have apps need remove"
		apt-get autoremove -y
		apt-get autoclean
		apt-get clean
		rm -rf /build
		rm -rf /tmp/* /var/tmp/*
		rm -rf /var/lib/apt/lists/*
		rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
 	elif [[ -f /etc/alpine-release ]]; then
		[[ ! -z "${UNINSTALL}" ]] && apk del --purge $UNINSTALL alpine-sdk openssl-dev || echo "not have apps need remove"
		apk add --no-cache libssl1.0
 	else
 	    echo "not support"
 	fi
