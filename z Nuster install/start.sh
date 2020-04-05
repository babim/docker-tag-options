#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# copy etc
if [ -z "`ls /etc/nuster`" ];then
  cp -R /etc_start/nuster/* /etc/nuster/
fi

# start app
if [ "${1#-}" != "$1" ]; then
  set -- "nuster" "$@"
fi

if [ "$1" = 'nuster' ]; then
  shift
  set -- nuster -W -db "$@"
fi

exec "$@"