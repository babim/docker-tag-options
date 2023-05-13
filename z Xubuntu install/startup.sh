#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi
if [ -f "/start.sh" ]; then /start.sh; fi
if [ -z "/root" ]; then cp -R /etc-start/root/* /root; fi
rm -rf /tmp/.X*
USER=root
HOME=/root
export USER HOME
    # set password root is root
    SSHPASS=${SSHPASS:-$USER}
    echo "$USER:$SSHPASS" | chpasswd
/vnckey.sh
vncserver :1
sleep infinity