#!/bin/sh
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _  \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

####################################################
# check os
if [ -f /etc/redhat-release ]; then
  OSRUN=redhat
elif [ -f /etc/lsb-release ]; then
  OSRUN=ubuntu
elif [ -f /etc/alpine-release ]; then
  OSRUN=alpine
fi

####################################################
# environment value
export SSHOPTION=${SSH:-false}
export CRONOPTION=${CRON:-false}
export NFSOPTION=${NFS:-false}
export SYNOLOGYOPTION=${SYNOLOGY:-false}
export UPGRADEOPTION=${UPGRADE:-false}
export WWWUSEROPTION=${WWWUSER:-www-data}
export MYSQLUSEROPTION=${MYSQLUSER:-mysql}
export USER1=${USER1:-$WWWUSER}
export USER2=${USER2:-$MYSQLUSER}
# environment set true all
if [ FULLOPTION=true ]; then
export SSHOPTION=${SSH:-true}
export CRONOPTION=${CRON:-true}
export NFSOPTION=${NFS:-true}
export SYNOLOGYOPTION=${SYNOLOGY:-true}
export UPGRADEOPTION=${UPGRADE:-true}
fi

####################################################
# COMMAND SNIP
####################################################

####################################################
# create static environment group command
ssh-create() {
    if [ ! -f "/SSH" ]; then 
    os-update
    ssh-start
    os-clean
    touch /SSH
    fi
}
cron-create() {
    if [ ! -f "/CRON" ]; then
    os-update
    cron-start
    os-clean
    touch /CRON
    fi
}
nfs-create() {
    if [ ! -f "/NFS" ]; then
    os-update
    ssh-start
    os-clean
    touch /NFS
    fi
}
synology-create() {
    if [ ! -f "/SYNOLOGY" ]; then
    synology-start
    touch /SYNOLOGY
    fi
}
upgrade-create() {
    if [ ! -f "/UPGRADE" ]; then
    os-update
    os-upgrade
    os-clean
    touch /UPGRADE
    fi
}

####################################################
# remove static environment group command
ssh-remove() {
    if [ -f "/SSH" ]; then rm -f /SSH; fi
}
cron-remove() {
    if [ -f "/CRON" ]; then rm -f /CRON; fi
}
nfs-remove() {
    if [ -f "/NFS" ]; then rm -f /NFS; fi
}
upgrade-remove() {
    if [ -f "/UPGRADE" ]; then rm -f /UPGRADE; fi
}

####################################################
# detect run group
synology-remove() {
    if [ -f "/SYNOLOGY" ]; then rm -f /SYNOLOGY; fi
    if [ OSRUN=redhat ]; then redhat-synology-remove; fi
    if [ OSRUN=ubuntu ]; then ubuntu-synology-remove; fi
    if [ OSRUN=alpine ]; then alpine-synology-remove; fi
}
os-clean() {
    if [ OSRUN=redhat ]; then redhat-clean; fi
    if [ OSRUN=ubuntu ]; then ubuntu-clean; fi
    if [ OSRUN=alpine ]; then alpine-clean; fi
}
ssh-start() {
    if [ OSRUN=redhat ]; then redhat-ssh-start; fi
    if [ OSRUN=ubuntu ]; then ubuntu-ssh-start; fi
    if [ OSRUN=alpine ]; then alpine-ssh-start; fi
}
ssh-run() {
    if [ OSRUN=redhat ]; then redhat-ssh; fi
    if [ OSRUN=ubuntu ]; then ubuntu-ssh; fi
    if [ OSRUN=alpine ]; then alpine-ssh; fi
}
nfs-start() {
    if [ OSRUN=redhat ]; then redhat-nfs-start; fi
    if [ OSRUN=ubuntu ]; then ubuntu-nfs-start; fi
    if [ OSRUN=alpine ]; then alpine-nfs-start; fi
}
nfs-run() {
    if [ OSRUN=redhat ]; then redhat-nfs; fi
    if [ OSRUN=ubuntu ]; then ubuntu-nfs; fi
    if [ OSRUN=alpine ]; then alpine-nfs; fi
}
cron-start() {
    if [ OSRUN=redhat ]; then redhat-cron-start; fi
    if [ OSRUN=ubuntu ]; then ubuntu-cron-start; fi
    if [ OSRUN=alpine ]; then alpine-cron-start; fi
}
cron-run() {
    if [ OSRUN=redhat ]; then redhat-cron; fi
    if [ OSRUN=ubuntu ]; then ubuntu-cron; fi
    if [ OSRUN=alpine ]; then alpine-cron; fi
}
synology-start() {
    if [ OSRUN=redhat ]; then redhat-synology-start; fi
    if [ OSRUN=ubuntu ]; then ubuntu-synology-start; fi
    if [ OSRUN=alpine ]; then alpine-synology-start; fi
}
os-upgrade() {
    if [ OSRUN=redhat ]; then redhat-upgrade; fi
    if [ OSRUN=ubuntu ]; then ubuntu-upgrade; fi
    if [ OSRUN=alpine ]; then alpine-upgrade; fi
}
os-update() {
    if [ OSRUN=redhat ]; then redhat-update; fi
    if [ OSRUN=ubuntu ]; then ubuntu-update; fi
    if [ OSRUN=alpine ]; then alpine-update; fi
}

####################################################
# clean group command
alpine-clean() {
    rm -rf /var/cache/apk/
}
ubuntu-clean() {
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /build && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
}
redhat-clean() {
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/tmp/yum-*
}

####################################################
# update group command
alpine-update() {
    echo 'no need update'
    #apk update
}
ubuntu-update() {
    apt-get update
}
redhat-update() {
    echo 'no need update'
}

####################################################
# upgrade group command
alpine-upgrade() {
    apk upgrade
}
ubuntu-upgrade() {
    apt-get upgrade -y
}
redhat-upgrade() {
    yum update -y
}

####################################################
# group service command
alpine-cron-start() {
    mkdir -p /etc-start/periodic /etc-start/periodic && \
    cp -R /etc/crontabs/* /etc-start/crontabs && cp -R /etc/periodic/* /etc-start/periodic
}

alpine-cron() {
# Prepare
    if [ -z "`ls /etc/crontabs`" ]; then cp -R /etc-start/crontabs/* /etc/crontabs; fi
    if [ -z "`ls /etc/periodic`" ]; then cp -R /etc-start/periodic/* /etc/periodic; fi
# start cron
    /usr/sbin/crond -b -L 8
}

alpine-nfs-start() {
    export FSTYPE=${FSTYPE:-nfs4}
    export MOUNT_OPTIONS=${MOUNT_OPTIONS:-nfsvers=4}
    export MOUNTPOINT=${MOUNTPOINT:-/mnt/nfs-1}
    apk add --no-cache nfs-utils
}

nfs() {
    # mount nfs
    FSTYPE2=${FSTYPE2:-$FSTYPE}
    MOUNT_OPTIONS2=${MOUNT_OPTIONS2:-$MOUNT_OPTIONS}
    FSTYPE3=${FSTYPE3:-$FSTYPE}
    MOUNT_OPTIONS3=${MOUNT_OPTIONS3:-$MOUNT_OPTIONS}
    FSTYPE4=${FSTYPE4:-$FSTYPE}
    MOUNT_OPTIONS4=${MOUNT_OPTIONS4:-$MOUNT_OPTIONS}
    FSTYPE5=${FSTYPE5:-$FSTYPE}
    MOUNT_OPTIONS5=${MOUNT_OPTIONS5:-$MOUNT_OPTIONS}
    # run
    mkdir -p "$MOUNTPOINT"
    rpcbind -f &
    mount -t "$FSTYPE" -o "$MOUNT_OPTIONS" "$SERVER:$SHARE" "$MOUNTPOINT"
    mount | grep nfs
    # run other
    if [[ ! -z "${SERVER2}" ]]; then
    mkdir -p "$MOUNTPOINT2"
    mount -t "$FSTYPE2" -o "$MOUNT_OPTIONS2" "$SERVER2:$SHARE2" "$MOUNTPOINT2"
    mount | grep nfs
    fi
    if [[ ! -z "${SERVER3}" ]]; then
    mkdir -p "$MOUNTPOINT3"
    mount -t "$FSTYPE3" -o "$MOUNT_OPTIONS3" "$SERVER3:$SHARE3" "$MOUNTPOINT3"
    mount | grep nfs
    fi
    if [[ ! -z "${SERVER4}" ]]; then
    mkdir -p "$MOUNTPOINT4"
    mount -t "$FSTYPE4" -o "$MOUNT_OPTIONS4" "$SERVER4:$SHARE4" "$MOUNTPOINT4"
    mount | grep nfs
    fi
    if [[ ! -z "${SERVER5}" ]]; then
    mkdir -p "$MOUNTPOINT5"
    mount -t "$FSTYPE5" -o "$MOUNT_OPTIONS5" "$SERVER5:$SHARE5" "$MOUNTPOINT5"
    mount | grep nfs
    fi
}

alpine-ssh-start() {
    # add ssh
    apk add --no-cache openssh
    #make sure we get fresh keys
    rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key
    mkdir /var/run/sshd
    # allow root ssh
    sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
}

alpine-ssh() {
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
    /usr/sbin/sshd
}

alpine-synology-start() {
# Checking user account
    if [ ! -z "$(grep ^${USER1}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${USER1} && \
        addgroup -g 1023 ${USER1} && adduser -D -H -G ${USER1}data -s /bin/false -u 1024 ${USER1}
    fi
    if [ ! -z "$(grep ^${USER2}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${USER2} && \
        addgroup -g 66 ${USER2} && adduser -D -H -G ${USER2} -s /bin/false -u 66 ${USER2}
        usermod -u 66 ${USER2} && groupmod -g 66 ${USER2}
    fi
}
alpine-synology-remove() {
# Checking user account
    if [ ! -z "$(grep ^${USER1}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${USER1} && \
        addgroup -g 1023 ${USER1} && adduser -D -H -G ${USER1} -s /bin/false -u 1024 ${USER1}
    fi
    if [ ! -z "$(grep ^${USER2}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${USER2} && \
        addgroup -g 66 ${USER2} && adduser -D -H -G ${USER2} -s /bin/false -u 66 ${USER2}
        usermod -u 66 ${USER2} && groupmod -g 66 ${USER2}
    fi
}

redhat-cron-start() {
    yum install -y cronie
}

redhat-cron() {
    service crond start
}

redhat-nfs-start() {
    yum install -y nfs-utils
}

redhat-ssh-start() {
    yum install -y openssh-server
}

redhat-ssh() {
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
    SSHPASS1=${SSHPASS:-root}
    echo "root:$SSHPASS1" | chpasswd
    # run sshd
    service sshd start
}

redhat-synology-start() {
    # Checking user account
    if [ ! -z "$(grep ^${USER1}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 1024 ${USER1}  && groupmod -g 1023 ${USER1}
    fi
    if [ ! -z "$(grep ^${USER2}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 66 ${USER2} && groupmod -g 66 ${USER2}
    fi
}
redhat-synology-remove() {
    # Checking user account
    if [ ! -z "$(grep ^${USER1}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 1024 ${USER1}  && groupmod -g 1023 ${USER1}
    fi
    if [ ! -z "$(grep ^${USER2}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 66 ${USER2} && groupmod -g 66 ${USER2}
    fi
}

ubuntu-cron-start() {
    # install
    apt-get install -y cron
}

ubuntu-cron() {
    service cron start
}

ubuntu-nfs-start() {
# install
    apt-get install -y nfs-common
}

ubuntu-ssh-start() {
# install
    apt-get install -y openssh-server
    mkdir /var/run/sshd
    # set password root is root
    echo 'root:root' | chpasswd
    # allow root ssh
    sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
    # SSH login fix. Otherwise user is kicked off after login
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    export NOTVISIBLE="in users profile"
    echo "export VISIBLE=now" >> /etc/profile
}

ubuntu-ssh() {
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
    # run ssh
    service ssh start
}

ubuntu-synology-start() {
    # Checking user account
    if [ ! -z "$(grep ^${USER1}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 1024 ${USER1}  && groupmod -g 1023 ${USER1}
    fi
    if [ ! -z "$(grep ^${USER2}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 66 ${USER2} && groupmod -g 66 ${USER2}
    fi
}
ubuntu-synology-remove() {
    # Checking user account
    if [ ! -z "$(grep ^${USER1}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 1024 ${USER1}  && groupmod -g 1023 ${USER1}
    fi
    if [ ! -z "$(grep ^${USER2}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u 66 ${USER2} && groupmod -g 66 ${USER2}
    fi
}

####################################################
# START PROGRAMS
####################################################
# ssh
    if [ SSHOPTION=true ]; then
        ssh-create
        ssh-run
    fi
# nfs
    if [ NFSOPTION=true ]; then
        nfs-create
        nfs-run
    fi
# cron
    if [ CRONOPTION=true ]; then
       cron-create
       cron-run
    fi
# synology
    if [ SYNOLOGYOPTION=true ]; then
       synology-create
    fi
# upgrade
    if [ UPGRADEOPTION=true ]; then
       upgrade-create
    fi


####################################################
# QUIT
exec "$@"