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
export DEBIAN_FRONTEND=noninteractive
# add repo apache
	add-apt-repository ppa:ondrej/apache2 -y

# install apache
	apt-get update && apt-get install apache2 -y 
# enable apache mod
    [[ ! -d /etc/apache2 ]] || a2enmod rewrite headers http2 ssl

# download entrypoint
	[[ ! -f /start.sh ]] || rm -f /start.sh
	cd / && \
	wget --no-check-certificate https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/start.sh && \
	chmod 755 start.sh
# prepare etc start
    curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/prepare_final.sh | bash

else
    echo "Not support your OS"
    exit
fi