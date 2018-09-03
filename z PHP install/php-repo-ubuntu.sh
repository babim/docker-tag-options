#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

echo 'Check OS'
if [[ -f /etc/lsb-release ]]; then
add-apt-repository ppa:ondrej/php -y
else
    echo "Not support your OS"
    exit
fi