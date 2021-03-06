#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _  \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

####################################################
# check os
echo 'Check OS'
if [[ -f /etc/redhat-release ]]; then
    export OSRUN=redhat
elif [[ -f /etc/lsb-release ]]; then
    export OSRUN=ubuntu
elif [[ -f /etc/debian_version ]]; then
    export OSRUN=ubuntu
elif [[ -f /etc/alpine-release ]]; then
    export OSRUN=alpine
else
    exit
fi

####################################################
export DEBIAN_FRONTEND=noninteractive
# environment value
export DELAYED_START=${DELAYED_START:-0}
export START_SECOND=${START_SECOND:-false}
export FULLOPTION=${FULLOPTION:-false}
export SSHOPTION=${SSH:-false}
export CRONOPTION=${CRON:-false}
export NFSOPTION=${NFS:-false}
export SYNOLOGYOPTION=${SYNOLOGY:-false}
export UPGRADEOPTION=${UPGRADE:-false}
export TZ=${TZ:-Asia/Ho_Chi_Minh}
export WWWUSER=${WWWUSER:-www-data}
export WWWUSERID=${WWWUSERID:-1023}
export MYSQLUSER=${MYSQLUSER:-mysql}
export MYSQLUSERID=${MYSQLUSERID:-66}
export POSTGRESUSER=${POSTGRESUSER:-postgres}
export POSTGRESUSERID=${POSTGRESUSERID:-55}
export DNSOPTION=${DNS:-false}
export CLOUDFLARE=1.1.1.1
export GOOGLE=8.8.8.8

	for f in SSHOPTION CRONOPTION NFSOPTION SYNOLOGYOPTION DNSOPTION FULLOPTION; do
		case "${f}" in
			[yY] | yes | YES | Yes | true | True | ON | on | TRUE ) export ${f}=true      ;;
			[nN] | no  | NO  | No | false | False | OFF | off | FALSE  ) export $f=false       ;;
			* ) echo "Options run value are empty"	;;
		esac
	done

DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20SCRIPT%20AUTO"
# environment set true all
if [ "${FULLOPTION}" = "true" ] || [ "${FULLOPTION}" = "on" ]; then
    export SSHOPTION=${SSH:-true}
    export CRONOPTION=${CRON:-true}
    export NFSOPTION=${NFS:-true}
    export SYNOLOGYOPTION=${SYNOLOGY:-true}
    export UPGRADEOPTION=${UPGRADE:-true}
    export DNSOPTION=${DNS:-true}
    export TZ=${TZ:-Asia/Ho_Chi_Minh}
fi

####################################################
# COMMAND SNIP
####################################################

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
    touch /UPGRADE.check
}
ubuntu-upgrade() {
    echo 'Upgrade OS'
    apt-get upgrade -y
    touch /UPGRADE.check
}
redhat-upgrade() {
    echo 'Upgrade OS'
    yum update -y
    touch /UPGRADE.check
}

####################################################
# group service command

# ALPINE

alpine-cron-start() {
    mkdir -p /etc-start/periodic /etc-start/periodic && \
    cp -R /etc/crontabs/* /etc-start/crontabs && cp -R /etc/periodic/* /etc-start/periodic
    touch /CRON.check
	# supervisor
	if [ -f "/etc/supervisor/supervisord.conf" ]; then
	apk add --no-cache wget
	FILETEMP=/etc/supervisor/conf.d/cron.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/cron.conf
	apk del --purge wget
	fi
}
alpine-cron-remove() {
    echo "No need do anything"
    if [ -f "/etc/supervisor/supervisord.conf" ]; then rm -f /etc/supervisor/conf.d/cron.conf; fi
}

alpine-cron() {
# Prepare
    if [ -z "`ls /etc/crontabs`" ]; then cp -R /etc-start/crontabs/* /etc/crontabs; fi
    if [ -z "`ls /etc/periodic`" ]; then cp -R /etc-start/periodic/* /etc/periodic; fi
# start cron
    if [ ! -f "/etc/supervisor/supervisord.conf" ]; then /usr/sbin/crond -b -L 8; fi
}

alpine-nfs-start() {
    export FSTYPE=${FSTYPE:-nfs4}
    export MOUNT_OPTIONS=${MOUNT_OPTIONS:-nfsvers=4}
    export MOUNTPOINT=${MOUNTPOINT:-/mnt/nfs-1}
    apk add --no-cache nfs-utils
    touch /NFS.check
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
    sed -i 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
    sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    touch /SSH.check
	# supervisor
	if [ -f "/etc/supervisor/supervisord.conf" ]; then
	apk add --no-cache wget
	FILETEMP=/etc/supervisor/conf.d/ssh.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/ssh.conf
	apk del --purge wget
	fi
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
    if [ ! -z "$(grep ^${WWWUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${WWWUSER} && \
        addgroup -g ${WWWUSERID} ${WWWUSER} && adduser -D -H -G ${WWWUSER} -s /bin/false -u ${WWWUSERID} ${WWWUSER}
#        usermod -u ${WWWUSERID} ${WWWUSER} && groupmod -g ${WWWUSERID} ${WWWUSER}
    fi
    if [ ! -z "$(grep ^${MYSQLUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${MYSQLUSER} && \
        addgroup -g ${MYSQLUSERID} ${MYSQLUSER} && adduser -D -H -G ${MYSQLUSER} -s /bin/false -u ${MYSQLUSERID} ${MYSQLUSER}
#        usermod -u ${MYSQLUSERID} ${MYSQLUSER} && groupmod -g ${MYSQLUSERID} ${MYSQLUSER}
    fi
    if [ ! -z "$(grep ^${POSTGRESUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        deluser xfs && delgroup ${POSTGRESUSER} && \
        addgroup -g ${POSTGRESID} ${POSTGRESUSER} && adduser -D -H -G ${POSTGRESUSER} -s /bin/false -u ${MYSQLUSERID} ${POSTGRESUSER}
#        usermod -u ${POSTGRESID} ${POSTGRESUSER} && groupmod -g ${POSTGRESID} ${POSTGRESUSER}
    fi
    touch /SYNOLOGY.check
}
alpine-synology-remove() {
# Checking user account
    echo "No need do anything"
}

# REDHAT

redhat-cron-start() {
    yum install -y cronie
    touch /CRON.check
	# supervisor
	if [ -f "/etc/supervisor/supervisord.conf" ]; then
	yum install -y wget
	FILETEMP=/etc/supervisor/conf.d/cron.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/cron.conf
	yum remove -y wget
	fi
}
redhat-cron-remove() {
    yum remove -y cronie
    if [ -f "/etc/supervisor/conf.d/cron.conf" ]; then rm -f /etc/supervisor/conf.d/cron.conf; fi
}
redhat-cron() {
    if [ ! -f "/etc/supervisor/supervisord.conf" ]; then service crond start; fi
}

redhat-nfs-start() {
    yum install -y nfs-utils
    touch /NFS.check
}
redhat-nfs-remove() {
    yum remove -y nfs-utils
}

redhat-ssh-start() {
    yum install -y openssh-server
    touch /SSH.check
	# supervisor
	if [ -f "/etc/supervisor/supervisord.conf" ]; then
	yum install -y wget
	FILETEMP=/etc/supervisor/conf.d/ssh.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/ssh.conf
	yum remove -y wget
	fi
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
    if [ ! -z "$(grep ^${WWWUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u ${WWWUSERID} ${WWWUSER}  && groupmod -g ${WWWUSERID} ${WWWUSER}
    fi
    if [ ! -z "$(grep ^${MYSQLUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u ${MYSQLUSERID} ${MYSQLUSER} && groupmod -g ${MYSQLUSERID} ${MYSQLUSER}
    fi
    if [ ! -z "$(grep ^${POSTGRESUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u ${POSTGRESUSERID} ${POSTGRESUSER} && groupmod -g ${POSTGRESUSERID} ${POSTGRESUSER}
    fi
    touch /SYNOLOGY.check
}
redhat-synology-remove() {
    echo "No need do anything"
}

# UBUNTU

ubuntu-cron-start() {
    # install
    apt-get install -y cron
    touch /CRON.check
	# supervisor
	if [ -f "/etc/supervisor/supervisord.conf" ]; then
	apt-get install wget -y
	FILETEMP=/etc/supervisor/conf.d/cron.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/cron.conf
	apt-get purge -y wget
	fi
}
ubuntu-cron-remove() {
    # remove
    apt-get purge -y cron
    if [ -f "/etc/supervisor/supervisord.conf" ]; then rm -f /etc/supervisor/conf.d/cron.conf; fi
}
ubuntu-cron() {
    if [ ! -f "/etc/supervisor/supervisord.conf" ]; then service cron start; fi
}

ubuntu-nfs-start() {
# install
    apt-get install -y nfs-common
    touch /NFS.check
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
    sed -i 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config
    sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    # SSH login fix. Otherwise user is kicked off after login
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
    export NOTVISIBLE="in users profile"
    echo "export VISIBLE=now" >> /etc/profile
    touch /SSH.check
	# supervisor
	if [ -f "/etc/supervisor/supervisord.conf" ]; then
	apt-get install -y wget
	FILETEMP=/etc/supervisor/conf.d/ssh.conf
		[[ -f $FILETEMP ]] && rm -f $FILETEMP
		wget -O $FILETEMP $DOWN_URL/supervisor/conf.d/ssh.conf
	apt-get purge -y wget
	fi
}
ubuntu-ssh-remove() {
# remove
    apt-get purge -y openssh-server
    if [ -f "/etc/supervisor/supervisord.conf" ]; then rm -f /etc/supervisor/conf.d/ssh.conf; fi
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
    if [ ! -f "/etc/supervisor/supervisord.conf" ]; then service ssh start; fi
}

ubuntu-synology-start() {
    echo Checking user account
    if [ ! -z "$(grep ^${WWWUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u ${WWWUSERID} ${WWWUSER}  && groupmod -g ${WWWUSERID} ${WWWUSER}
    fi
    if [ ! -z "$(grep ^${MYSQLUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u ${MYSQLUSERID} ${MYSQLUSER} && groupmod -g ${MYSQLUSERID} ${MYSQLUSER}
    fi
    if [ ! -z "$(grep ^${POSTGRESUSER}: /etc/passwd /etc/group)" ] && [ -z "$force" ]; then
        usermod -u ${POSTGRESUSERID} ${POSTGRESUSER} && groupmod -g ${POSTGRESUSERID} ${POSTGRESUSER}
    fi
    touch /SYNOLOGY.check
}
ubuntu-synology-remove() {
    echo "No need do anything"
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
os-update() {
    if [ $OSRUN = redhat ]; then redhat-update; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-update; fi
    if [ $OSRUN = alpine ]; then alpine-update; fi
}

####################################################
# remove static environment group command
ssh-remove() {
    if [ -f "/SSH.check" ]; then rm -f /SSH.check; fi
    if [ $OSRUN = redhat ]; then redhat-ssh-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-ssh-remove; fi
    if [ $OSRUN = alpine ]; then alpine-ssh-remove; fi
}
cron-remove() {
    if [ -f "/CRON.check" ]; then rm -f /CRON.check; fi
    if [ $OSRUN = redhat ]; then redhat-cron-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-cron-remove; fi
    if [ $OSRUN = alpine ]; then alpine-cron-remove; fi
}
nfs-remove() {
    if [ -f "/NFS.check" ]; then rm -f /NFS.check; fi
    if [ $OSRUN = redhat ]; then redhat-nfs-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-nfs-remove; fi
    if [ $OSRUN = alpine ]; then alpine-nfs-remove; fi
}
upgrade-remove() {
    if [ -f "/UPGRADE.check" ]; then rm -f /UPGRADE.check; fi
    if [ $OSRUN = redhat ]; then redhat-upgrade-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-upgrade-remove; fi
    if [ $OSRUN = alpine ]; then alpine-upgrade-remove; fi
}
synology-remove() {
    if [ -f "/SYNOLOGY.check" ]; then rm -f /SYNOLOGY.check; fi
    if [ $OSRUN = redhat ]; then redhat-synology-remove; fi
    if [ $OSRUN = ubuntu ]; then ubuntu-synology-remove; fi
    if [ $OSRUN = alpine ]; then alpine-synology-remove; fi
}
os-upgrade-remove() {
    if [ -f "/UPGRADE.check" ]; then rm -f /UPGRADE.check; fi
}

####################################################
# create static environment group command
ssh-create() {
    if [ ! -f "/SSH.check" ]; then
        os-update
        ssh-start
        os-clean
        ssh-run
    elif [ -f "/SSH.check" ]; then
        ssh-run
    fi
}
ssh-del() {
        os-update
        ssh-remove
        os-clean
}

cron-create() {
    if [ ! -f "/CRON.check" ]; then
        os-update
        cron-start
        os-clean
        cron-run
    elif [ -f "/CRON.check" ]; then
        cron-run
    fi
}
cron-del() {
        os-update
        cron-remove
        os-clean
}

nfs-create() {
    if [ ! -f "/NFS.check" ]; then
        os-update
        nfs-start
        os-clean
        nfs-run
    elif [ -f "/NFS.check" ]; then
        nfs-run
    fi
}
nfs-del() {
        os-update
        nfs-remove
        os-clean
}

synology-create() {
    if [ ! -f "/SYNOLOGY.check" ]; then
        synology-start
    elif [ -f "/SYNOLOGY.check" ]; then
        echo done
    fi
}
synology-del() {
        synology-remove
}

upgrade-create() {
    if [ ! -f "/UPGRADE.check" ]; then
        os-update
        os-upgrade
        os-clean
    elif [ -f "/UPGRADE.check" ]; then
        echo done
    elif [ -f "/UPGRADE.check" ] && [ "$UPGRADEOPTION" = "always" ]; then
	os-upgrade
    fi
}
upgrade-del() {
        os-upgrade-remove
        os-clean
}

####################################################
# START PROGRAMS
####################################################
# ssh
    # install
    if [ "$SSHOPTION" = "true" ] || [ "$SSHOPTION" = "on" ]; then
        echo "install SSH"
        ssh-create
    fi
    #remove
    if [ "$SSHOPTION" = "false" ] && [ -f /SSH.check ]; then ssh-del; fi
# nfs
    # install
    if [ "$NFSOPTION" = "true" ] || [ "$NFSOPTION" = "on" ]; then
        echo "install NFS"
        nfs-create
    fi
    #remove
    if [ "$NFSOPTION" = "false" ] && [ -f /NFS.check ]; then nfs-del; fi
# cron
    # install
    if [ "$CRONOPTION" = "true" ] || [ "$CRONOPTION" = "on" ]; then
       echo "install CRON"
       cron-create
    fi
    #remove
    if [ "$CRONOPTION" = "false" ] && [ -f /CRON.check ]; then cron-del; fi
# synology
    # install
    if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ]; then
       echo "setup SYNOLOGY environment"
       synology-create
    fi
    #remove
    if [ "$SYNOLOGYOPTION" = "false" ] && [ -f /SYNOLOGY.check ]; then synology-del; fi
# upgrade
    # install
    if [ "$UPGRADEOPTION" = "true" ] || [ "$UPGRADEOPTION" = "on" ] || [ "$UPGRADEOPTION" = "always" ]; then
       echo "Upgrade OS"
       upgrade-create
    fi
    #remove
    if [ "$UPGRADEOPTION" = "false" ] && [ -f /UPGRADE.check ]; then upgrade-del; fi
# DNS
    # install
    if [ "$DNSOPTION" = "google" ]; then
       echo "nameserver $GOOGLE" >> /etc/resolv.conf
    elif [ "$DNSOPTION" = "cloudflare" ]; then
        echo "nameserver $CLOUDFLARE" >> /etc/resolv.conf
    elif [ "$DNSOPTION" = "true" ] || [ "$DNSOPTION" = "on" ] || [ "$DNSOPTION" = "both" ]; then
        echo "nameserver $GOOGLE" >> /etc/resolv.conf
        echo "nameserver $CLOUDFLARE" >> /etc/resolv.conf
    fi
# set timezone
	if [ ! -z "$TZ" ]; then
		if [[ -f /etc/alpine-release ]]; then
			[[ -d "/usr/share/zoneinfo" ]] || apk add --no-cache tzdata
		fi
			TZ=${TZ:-Asia/Ho_Chi_Minh}
			ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
	fi

####################################################
# QUIT
	if [ -n "${DELAYED_START}" ]; then
		sleep ${DELAYED_START}
	fi
	if [ "${START_SECOND}" = "true" ]; then
		if [ ! -f "/start_second" ]; then /start_second.sh; fi
	fi

exec "$@"
