#!/bin/bash
# SSH
if [ "${AUTHORIZED_KEYS}" != "**None**" ]; then
    echo "=> Found authorized keys"
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh
    touch /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    IFS=$'\n'
    arr=$(echo ${AUTHORIZED_KEYS} | tr "," "\n")
    for x in $arr
    do
        x=$(echo $x |sed -e 's/^ *//' -e 's/ *$//')
        cat /root/.ssh/authorized_keys | grep "$x" >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo "=> Adding public key to /root/.ssh/authorized_keys: $x"
            echo "$x" >> /root/.ssh/authorized_keys
        fi
    done
fi

# set password root is root
SSHPASS=${SSHPASS:-root}
echo "root:$SSHPASS" | chpasswd

# check other script and run ssh
if [ -f "/boot.sh" ] && [ -f "/first.sh" ] && [ -f "/firstrun.sh" ] && [ ! -f "/start.sh" ] && [ -f "/starting.sh" ] && [ -f "/startup.sh" ] && [ -f "/run.sh" ] && [ -f "/entry.sh" ] && [ -f "/entrypoint.sh" ] && [ -f "/entry-point.sh" ] && [ -f "/docker-entrypoint.sh" ]; then
    service ssh start
fi

exec "$@"
