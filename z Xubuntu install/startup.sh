#!/bin/bash
# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi
if [ -f "/start.sh" ]; then /start.sh; fi
if [ -z "/root" ]; then cp -R /etc-start/root/* /root; fi
rm -rf /tmp/.X*
USER=root
HOME=/root
export USER HOME
    # set password root is root
    SSHPASS=${SSHPASS:-root}
    echo "root:$SSHPASS" | chpasswd
/vnckey.sh
vncserver :1
sleep infinity