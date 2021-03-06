#!/bin/bash -e
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# set env for ACDCLI
export CONFIGPATH=${CONFIGPATH:-/cache}
export CACHEPATH=${CACHEPATH:-/cache}
export CLOUDPATH=${CLOUDPATH:-/cloud}
export ACD_CLI_CACHE_PATH=$CACHEPATH
export ACD_CLI_SETTINGS_PATH=$CONFIGPATH
export HTTPS_PROXY="$PROXY"
export HTTP_PROXY="$PROXY"

# create startup run
if [ ! -f "$CONFIGPATH/startup.sh" ]; then
	# create
cat <<EOF>> $CONFIGPATH/startup.sh
#!/bin/sh
# your startup command
EOF
	chmod +x $CONFIGPATH/startup.sh
else
	# run
	$CONFIGPATH/startup.sh
fi

create_directory() {
# create directory
	if [ ! -d "$CONFIGPATH" ]; then mkdir -p $CONFIGPATH; fi
	if [ ! -d "$CACHEPATH" ]; then mkdir -p $CACHEPATH; fi
	if [ ! -d "$CLOUDPATH" ]; then mkdir -p $CLOUDPATH; fi
	if [ ! -d "/home/$auser/.cache/acd_cli" ]; then mkdir -p /home/$auser/.cache/acd_cli
	ln -sf $CACHEPATH /home/$auser/.cache/acd_cli #no need
	chown -R $auid:$agid /home/$auser #no need
	chown -R $auid:$agid $CONFIGPATH $CACHEPATH $CLOUDPATH
}

# overwrite /etc/fuse.conf to allow other users to access the mounted filesystem from outside the container
cat <<EOF> /etc/fuse.conf
# Allow non-root users to specify the 'allow_other' or 'allow_root'
# mount options.
user_allow_other
EOF

if [[ "$auid" = "0" ]] || [[ "$agid" == "0" ]]; then
	echo "Run in ROOT user"
	export auser=root
	create_directory
else
	echo "Run in $auser"
	if [ ! -d "/home/$auser" ]; then
		if [[ -f /etc/alpine-release ]]; then
		# usermod alpine
			addgroup -g ${agid} $auser
			adduser -D -u ${auid} -G $auser $auser
		else
		# usermod ubuntu/debian
			usermod -u $auid $auser
			groupmod -g $agid $aguser
		fi
	create_directory
	# fix su command user
	sed -i '$ d' /etc/passwd
	echo "$auser:x:$auid:$agid:Linux User:/home/$auser:/bin/sh" >> /etc/passwd
	fi
	su - $auser
fi

# help
echo "use acdcli command"
echo "---"
acdcli -h