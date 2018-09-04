#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# create folder
[[ -d /etc/nginx/include ]] || mkdir -p /etc/nginx/include
cd /etc/nginx/include

# downloads
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/owncloud.conf
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/phpparam.conf
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/restrict.conf
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/rootwordpressclean.conf
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/wordpress.conf
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/wordpressmulti.conf
wget https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20PHP%20install/include/wpsupercache.conf