#!/bin/sh

if [ ! -f "/etc/ssh/ssh_host_rsa_key" ]; then
	# generate fresh rsa key
	ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
fi
if [ ! -f "/etc/ssh/ssh_host_dsa_key" ]; then
	# generate fresh dsa key
	ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa
fi

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

#prepare run dir
if [ ! -d "/var/run/sshd" ]; then
  mkdir -p /var/run/sshd
fi

# check other script and run ssh
if [ -f "/boot.sh" ] && [ -f "/first.sh" ] && [ -f "/firstrun.sh" ] && [ ! -f "/start.sh" ] && [ -f "/starting.sh" ] && [ -f "/startup.sh" ] && [ -f "/run.sh" ] && [ -f "/entry.sh" ] && [ -f "/entrypoint.sh" ] && [ -f "/entry-point.sh" ] && [ -f "/docker-entrypoint.sh" ]; then
    /usr/sbin/sshd
fi

exec "$@"
