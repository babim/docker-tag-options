#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Prepare Kerio bin
if [ -z "`ls /opt/icewarp --hide='lost+found'`" ]
then
	cp -R /opt-start/icewarp/* /opt/icewarp
fi
if [ ! -d "/opt/icewarp/logs" ] && [ ! -d "/opt/icewarp/archive" ] && [ ! -f "/opt/icewarp/icewarpd" ]
then
	cp -Rn /opt-start/icewarp/* /opt/icewarp/
fi

# Prepare DNS
if [ -f "/opt/icewarp/icewarpd" ]; then
export HOSTNAME=$(hostname -s)
export DOMAIN=$(hostname -d)
export CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
export DNSSERVER=${DNSSERVER:-8.8.8.8}
# Set DNS Server to localhost
echo "nameserver $DNSSERVER" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Start
function terminate {
	/opt/icewarp/icewarpd.sh --stop
	exit 0
}
trap terminate TERM INT
/opt/icewarp/icewarpd.sh --stop
while :; do
	sleep 1;
done
else

echo "Install Wrong! Please Check Image or Path Config!"
echo "contact: babim@matmagoc.com"
sleep 60
fi
