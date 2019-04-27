#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

say " Prepare data before build complete"

# prepare etc start
    [[ ! -d /etc-start ]] || rm -rf /etc-start
    [[ ! -d /root ]] || mkdir -p /etc-start/root
    [[ ! -d /root ]] || cp -R /root/* /etc-start/root
