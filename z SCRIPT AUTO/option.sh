#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _  \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

####################################################
# check os
echo 'Check OS'
if [ -f /etc/redhat-release ]; then
    export OSRUN=redhat
elif [ -f /etc/lsb-release ]; then
    export OSRUN=ubuntu
elif [ -f /etc/alpine-release ]; then
    export OSRUN=alpine
else
    quit_command
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
export PAGESPEEDOPTION=${PAGESPEED:-false}
export MODSECURITYOPTION=${MODSECURITY:-false}
# environment set true all
if [ "$FULLOPTION" = "true" ]; then
    export SSHOPTION=${SSH:-true}
    export CRONOPTION=${CRON:-true}
    export NFSOPTION=${NFS:-true}
    export SYNOLOGYOPTION=${SYNOLOGY:-true}
    export UPGRADEOPTION=${UPGRADE:-true}
    export PAGESPEEDOPTION=${PAGESPEED:-true}
    export MODSECURITYOPTION=${MODSECURITY:-true}
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
        ssh-run
    else
        ssh-run
    fi
}
ssh-del() {
        os-update
        ssh-remove
        os-clean
}

cron-create() {
    if [ ! -f "/CRON" ]; then
        os-update
        cron-start
        os-clean
        touch /CRON
        cron-run
    else
        cron-run
    fi
}
cron-del() {
        os-update
        cron-remove
        os-clean
}

nfs-create() {
    if [ ! -f "/NFS" ]; then
        os-update
        nfs-start
        os-clean
        touch /NFS
        nfs-run
    else
        nfs-run
    fi
}
nfs-del() {
        os-update
        nfs-remove
        os-clean
}

synology-create() {
    if [ ! -f "/SYNOLOGY" ]; then
        synology-start
        touch /SYNOLOGY
    else
        echo done
    fi
}
synology-del() {
        synology-remove
}

upgrade-create() {
    if [ ! -f "/UPGRADE" ]; then
        os-update
        os-upgrade
        os-clean
        touch /UPGRADE
    else
        echo done
    fi
}
upgrade-del() {
        os-upgrade-remove
        os-clean
}

pagespeed-create() {
    if [ ! -f "/PAGESPEED" ]; then
        os-update
        pagespeed-start
        os-clean
        touch /PAGESPEED
        quit_command
    else
        quit_command
    fi
}
pagespeed-del() {
        os-update
        pagespeed-remove
        os-clean
}

modsecurity-create() {
    if [ ! -f "/UPGRADE" ]; then
        os-update
        modsecurity-start
        os-clean
        touch /MODSECUROTY
        quit_command
    else
        quit_command
    fi
}
modsecurity-del() {
        os-update
        modsecurity-remove
        os-clean
}

####################################################
# remove static environment group command
ssh-remove() {
    if [ -f "/SSH" ]; then rm -f /SSH; fi
    if [ $OSRUN = redhat ]; then redhat-ssh-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-ssh-remove; fi
    if [ $OSRUN = alpine ]; then alpine-ssh-remove; fi
}
cron-remove() {
    if [ -f "/CRON" ]; then rm -f /CRON; fi
    if [ $OSRUN = redhat ]; then redhat-cron-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-cron-remove; fi
    if [ $OSRUN = alpine ]; then alpine-cron-remove; fi
}
nfs-remove() {
    if [ -f "/NFS" ]; then rm -f /NFS; fi
    if [ $OSRUN = redhat ]; then redhat-nfs-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-nfs-remove; fi
    if [ $OSRUN = alpine ]; then alpine-nfs-remove; fi
}
upgrade-remove() {
    if [ -f "/UPGRADE" ]; then rm -f /UPGRADE; fi
    if [ $OSRUN = redhat ]; then redhat-upgrade-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-upgrade-remove; fi
    if [ $OSRUN = alpine ]; then alpine-upgrade-remove; fi
}
synology-remove() {
    if [ -f "/SYNOLOGY" ]; then rm -f /SYNOLOGY; fi
    if [ $OSRUN = redhat ]; then redhat-synology-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-synology-remove; fi
    if [ $OSRUN = alpine ]; then alpine-synology-remove; fi
}
pagespeed-remove() {
    if [ -f "/SYNOLOGY" ]; then rm -f /PAGESPEED; fi
    if [ $OSRUN = redhat ]; then redhat-pagespeed-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-pagespeed-remove; fi
    if [ $OSRUN = alpine ]; then alpine-pagespeed-remove; fi
}
modsecurity-remove() {
    if [ -f "/SYNOLOGY" ]; then rm -f /MODSECURITY; fi
    if [ $OSRUN = redhat ]; then redhat-modsecurity-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-modsecurity-remove; fi
    if [ $OSRUN = alpine ]; then alpine-modsecurity-remove; fi
}
####################################################
# detect run group
os-clean() {
    if [ $OSRUN = redhat ]; then redhat-clean; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-clean; fi
    if [ $OSRUN = alpine ]; then alpine-clean; fi
}
ssh-start() {
    if [ $OSRUN = redhat ]; then redhat-ssh-start; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-ssh-start; fi
    if [ $OSRUN = alpine ]; then alpine-ssh-start; fi
}
ssh-run() {
    if [ $OSRUN = redhat ]; then redhat-ssh; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-ssh; fi
    if [ $OSRUN = alpine ]; then alpine-ssh; fi
}
nfs-start() {
    if [ $OSRUN = redhat ]; then redhat-nfs-start; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-nfs-start; fi
    if [ $OSRUN = alpine ]; then alpine-nfs-start; fi
}
nfs-run() {
    if [ $OSRUN = redhat ]; then nfs-mount; fi
    if [ $OSRUN = ubuntu ]; then nfs-mount; fi
    if [ $OSRUN = alpine ]; then nfs-mount; fi
}
cron-start() {
    if [ $OSRUN = redhat ]; then redhat-cron-start; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-cron-start; fi
    if [ $OSRUN = alpine ]; then alpine-cron-start; fi
}
cron-run() {
    if [ $OSRUN = redhat ]; then redhat-cron; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-cron; fi
    if [ $OSRUN = alpine ]; then alpine-cron; fi
}
synology-start() {
    if [ $OSRUN = redhat ]; then redhat-synology-start; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-synology-start; fi
    if [ $OSRUN = alpine ]; then alpine-synology-start; fi
}
os-upgrade() {
    if [ $OSRUN = redhat ]; then redhat-upgrade; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-upgrade; fi
    if [ $OSRUN = alpine ]; then alpine-upgrade; fi
}
os-upgrade-remove() {
    if [ -f "/UPGRADE" ]; then rm -f /UPGRADE; fi
}
os-update() {
    if [ $OSRUN = redhat ]; then redhat-update; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-update; fi
    if [ $OSRUN = alpine ]; then alpine-update; fi
}
pagespeed-start() {
    if [ $OSRUN = redhat ]; then redhat-pagespeed-start; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-pagespeed-start; fi
    if [ $OSRUN = alpine ]; then alpine-pagespeed-start; fi
}
modsecurity-start() {
    if [ $OSRUN = redhat ]; then redhat-modsecurity-start; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-modsecurity-start; fi
    if [ $OSRUN = alpine ]; then alpine-modsecurity-start; fi
}

####################################################
# clean group command
alpine-clean() {
    echo 'Clean OS'
    rm -rf /var/cache/apk/
}
ubuntu-clean() {
    echo 'Clean OS'
    apt-get clean && \
    apt-get autoclean && \
    apt-get autoremove -y && \
    rm -rf /build && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/dpkg/dpkg.cfg.d/02apt-speedup
}
redhat-clean() {
    echo 'Clean OS'
    yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/tmp/yum-*
}

####################################################
# update group command
alpine-update() {
    echo 'Update OS'
    echo 'no need update'
    #apk update
}
ubuntu-update() {
    echo 'Update OS'
    apt-get update
}
redhat-update() {
    echo 'Update OS'
    echo 'no need update'
}

####################################################
# upgrade group command
alpine-upgrade() {
    echo 'Upgrade OS'
    apk --no-cache upgrade
}
ubuntu-upgrade() {
    echo 'Upgrade OS'
    apt-get upgrade -y
}
redhat-upgrade() {
    echo 'Upgrade OS'
    yum update -y
}

####################################################
# group service command

# ALPINE

alpine-cron-start() {
    mkdir -p /etc-start/periodic /etc-start/periodic && \
    cp -R /etc/crontabs/* /etc-start/crontabs && cp -R /etc/periodic/* /etc-start/periodic
}
alpine-cron-remove() {
    echo "No need do anything"
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
alpine-nfs-remove() {
    apk del nfs-utils
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
alpine-ssh-remove() {
    # remove ssh
    apk del openssh
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
    echo "No need do anything"
}

alpine-pagespeed-start() {
    if [ ! -z "`ls /etc/apache2`" ]; then
        echo "not found on alpine linux"
    else
        echo "Not have Apache2 on this Server"
    fi
}
alpine-pagespeed-remove() {
    echo "not found on alpine linux"
}

alpine-modsecurity-start() {
    if [ ! -z "`ls /etc/apache2`" ]; then
        echo "not found on alpine linux"
    else
        echo "Not have Apache2 on this Server"
    fi
}
alpine-modsecurity-remove() {
    echo "not found on alpine linux"
}

# REDHAT

redhat-cron-start() {
    yum install -y cronie
}
redhat-cron-remove() {
    yum remove -y cronie
}

redhat-cron() {
    service crond start
}

redhat-nfs-start() {
    yum install -y nfs-utils
}
redhat-nfs-remove() {
    yum remove -y nfs-utils
}

redhat-ssh-start() {
    yum install -y openssh-server
}
redhat-ssh-remove() {
    yum remove -y openssh-server
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
    SSHPASS=${SSHPASS:-root}
    echo "root:$SSHPASS" | chpasswd
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
    echo "No need do anything"
}

redhat-pagespeed-start() {
    if [ ! -z "`ls /etc/apache2`" ]; then
        yum install -y wget
        wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_x86_64.rpm
        rpm -ivh mod-pagespeed-stable_current_x86_64.rpm
        rm -f mod-pagespeed-stable_current_x86_64.rpm
        yum remove -y wget
    else
        echo "Not have Apache2 on this Server"
    fi
}
redhat-pagespeed-remove() {
    yum remove -y *pagespeed*
}

redhat-modsecurity-start() {
    if [ ! -z "`ls /etc/apache2`" ]; then
        yum install -y mod_security
    else
        echo "Not have Apache2 on this Server"
    fi
}
redhat-modsecurity-remove() {
        yum remove -y mod_security
}

# UBUNTU

ubuntu-cron-start() {
    # install
    apt-get install -y cron
}
ubuntu-cron-remove() {
    # remove
    apt-get purge -y cron
}

ubuntu-cron() {
    service cron start
}

ubuntu-nfs-start() {
# install
    apt-get install -y nfs-common
}
ubuntu-nfs-remove() {
# remove
    apt-get purge -y nfs-common
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
ubuntu-ssh-remove() {
# remove
    apt-get purge -y openssh-server
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
    echo "No need do anything"
}

ubuntu-pagespeed-start() {
    if [ -z "`ls /etc/apache2`" ]; then
        apt-get install -y --force-yes wget
        wget https://dl-ssl.google.com/dl/linux/direct/mod-pagespeed-stable_current_amd64.deb
        dpkg -i mod-pagespeed-stable_current_amd64.deb
        rm -f mod-pagespeed-stable_current_amd64.deb
        apt-get purge -y wget
    else
        echo "Not have Apache2 on this Server"
    fi
}
ubuntu-pagespeed-remove() {
        apt-get purge -y *pagespeed*
}

ubuntu-modsecurity-start() {
    if [ -z "`ls /etc/apache2`" ]; then
        apt-get install -y --force-yes libapache2-mod-security2
        a2enmod security2
    else
        echo "Not have Apache2 on this Server"
    fi
}
ubuntu-modsecurity-remove() {
        apt-get purge -y libapache2-mod-security2
}

# NFS mount
nfs-mount() {
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

# QUIT
quit_command() {
    exec "$@"
}

####################################################
# START PROGRAMS
####################################################
# ssh
    # install
    if [ "$SSHOPTION" = "true" ]; then
        echo "install SSH"
        ssh-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /SSH ]; then ssh-del; fi
# nfs
    # install
    if [ "$NFSOPTION" = "true" ]; then
        echo "install NFS"
        nfs-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /NFS ]; then nfs-del; fi
# cron
    # install
    if [ "$CRONOPTION" = "true" ]; then
       echo "install CRON"
       cron-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /CRON ]; then cron-del; fi
# synology
    # install
    if [ "$SYNOLOGYOPTION" = "true" ]; then
       echo "setup SYNOLOGY environment"
       synology-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /SYNOLOGY ]; then synology-del; fi
# upgrade
    # install
    if [ "$UPGRADEOPTION" = "true" ]; then
       echo "Upgrade OS"
       upgrade-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /UPGRADE ]; then upgrade-del; fi
# pagespeed
    # install
    if [ "$PAGESPEEDOPTION" = "true" ]; then
       echo "install PAGESPEED"
       pagespeed-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /PAGESPEED ]; then pagespeed-del; fi
# modsecurity
    # install
    if [ "$MODSECURITYOPTION" = "true" ]; then
       echo "install apache MOD-SECURITY"
       modsecurity-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /MODSECURITY ]; then modsecurity-del; fi


####################################################
# QUIT
exec "$@"