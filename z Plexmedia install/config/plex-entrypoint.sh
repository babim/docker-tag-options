#!/bin/bash -e
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# copy config supervisor
if [ -d "/etc/supervisor" ] && [ -d "/etc-start/supervisor" ];then
	if [ ! -f "/etc/supervisor/supervisord.conf" ]; then cp -R -f /etc-start/supervisor/* /etc/supervisor; fi
	if [ "$SYNOLOGYOPTION" = "true" ] || [ "$SYNOLOGYOPTION" = "on" ] || [ "$SYNOLOGY" = "true" ] || [ "$SYNOLOGY" = "on" ]; then
		echo "setup SYNOLOGY environment"
		chmod -R 777 /etc/supervisor
	fi
fi

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

# set ID docker run
export auid=${auid:-797}
export agid=${agid:-$auid}
export auser=${auser:-plex}
export aguser=${aguser:-$auser}

# fix su
plex_fix_su() {
	chown -R $auid:$agid /home/$auser #no need
	# fix su command user
	sed -i '$ d' /etc/passwd
	echo "$auser:x:$auid:$agid:Linux User:/home/$auser:/bin/sh" >> /etc/passwd
}
# create and check user
	if [[ -z "${auid}" ]] || [[ "$auid" == "797" ]]; then
		echo "start"
		plex_fix_su
		su - $auser
	elif [[ "$auid" == "0" ]] || [[ "$aguid" == "0" ]]; then
		echo "run in user root"
		export auser=root
	elif id $auid >/dev/null 2>&1; then
	        echo "UID exists. Please change UID"
	else
		if id $auser >/dev/null 2>&1; then
		        echo "user exists"
			if [[ -f /etc/alpine-release ]]; then
			# usermod alpine
				deluser $auser && delgroup $aguser
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# usermod ubuntu/debian
				usermod -u $auid $auser
				groupmod -g $agid $aguser
			fi
		else
			if [[ -f /etc/alpine-release ]]; then
			# create user alpine
				addgroup -g $agid $aguser && adduser -D -H -G $aguser -s /bin/false -u $auid $auser
			else
			# create user ubuntu/debian
				groupadd -g $agid $aguser && useradd --system --uid $auid --shell /usr/sbin/nologin -g $aguser $auser
			fi
		plex_fix_su
		su - $auser
		fi
	fi
  
  fi
  
fi

# This codec folder seems to be populated dynamically - so we need to check for any more binaries to patch on every boot :(
if [ -d /config/Plex\ Media\ Server/Codecs ]; then
    echo "Patching codecs..."
    find /config/Plex\ Media\ Server/Codecs -type f -perm /0111 -exec sh -c "file --brief \"{}\" | grep -q "ELF" && patchelf --set-interpreter \"$GLIBC_LD_LINUX_SO\" \"{}\" " \;
    echo "Done!"
fi

# Legacy environment variables support.
if [ -n "$PLEX_USERNAME" ]; then
    echo "WARNING: 'PLEX_USERNAME' has been deprecated and is now called 'PLEX_LOGIN'."
    PLEX_LOGIN="$PLEX_USERNAME"
    unset PLEX_USERNAME
fi

if [ -n "$PLEXPASS_LOGIN" ]; then
    echo "WARNING: 'PLEXPASS_LOGIN' has been deprecated and is now called 'PLEX_LOGIN'."
    PLEX_LOGIN="$PLEXPASS_LOGIN"
    unset PLEXPASS_LOGIN
fi

if [ -n "$PLEXPASS_PASSWORD" ]; then
    echo "WARNING: 'PLEXPASS_PASSWORD' has been deprecated and is now called 'PLEX_PASSWORD'."
    PLEX_PASSWORD="$PLEXPASS_PASSWORD"
    unset PLEXPASS_PASSWORD
fi

if [ -n "$PLEX_EXTERNALPORT" ]; then
    echo "WARNING: 'PLEXEXTERNALPORT' has been deprecated and is now called 'PLEX_EXTERNAL_PORT'."
    PLEX_EXTERNAL_PORT="$PLEXPASS_EXTERNALPORT"
    unset PLEXPASS_EXTERNALPORT
fi

# Delete PID file (we don't use that)
if [ -f /config/Plex\ Media\ Server/plexmediaserver.pid ]; then
    rm -f /config/Plex\ Media\ Server/plexmediaserver.pid
fi

# Get plex token if Plex username and password are defined.
if [ -n "$PLEX_LOGIN" ] && [ -n "$PLEX_PASSWORD" ]; then
    export X_PLEX_TOKEN=$(retrieve-plex-token "$PLEX_LOGIN" "$PLEX_PASSPWORD")
fi
unset PLEX_LOGIN
unset PLEX_PASSWORD

PLEX_PREFERENCES="/config/Plex Media Server/Preferences.xml"

# Default Preferences.
if [ ! -f /config/Plex\ Media\ Server/Preferences.xml ]; then
    mkdir -p /config/Plex\ Media\ Server
    cp /Preferences.xml "$PLEX_PREFERENCES"
fi

update_preferences_attribute() {
    attr="$1"
    value="$2"
    if [ $(xmlstarlet select -T -t -m "/Preferences" -v "@$attr" -n "$PLEX_PREFERENCES") ]; then
        xmlstarlet edit --inplace --update "/Preferences/@$attr" -v "$value" "$PLEX_PREFERENCES"
    else
        xmlstarlet edit --inplace --insert "Preferences" --type attr -n "$attr" -v "$value" "$PLEX_PREFERENCES"
    fi
}

# Sets PlexOnlineToken in Preferences.xml if provided.
if [ -n "$X_PLEX_TOKEN" ]; then
    update_preferences_attribute PlexOnlineToken "$X_PLEX_TOKEN"
fi

# Sets ManualPortMappingPort in Preferences.xml if provided.
if [ -n "$PLEX_EXTERNAL_PORT" ]; then
    update_preferences_attribute ManualPortMappingMode 1
    update_preferences_attribute ManualPortMappingPort $PLEX_EXTERNAL_PORT
fi

# Unset any environment variable we used (just for safety as we don't need them anymore).
unset PLEX_EXTERNAL_PORT
unset X_PLEX_TOKEN

# Output logs to stdout.
if [ ! -f '/config/Plex Media Server/Logs/Plex Media Server.log' ]; then
    mkdir -p '/config/Plex Media Server/Logs'
    touch '/config/Plex Media Server/Logs/Plex Media Server.log'
fi
tail -Fn 0 '/config/Plex Media Server/Logs/Plex Media Server.log' &

# Set the stack size
ulimit -s $PLEX_MAX_STACK_SIZE

export DNSSERVER=${DNSSERVER:-8.8.8.8}
# Set DNS Server to localhost
echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# option with acdcli
if [ -f "/acdcli-entrypoint.sh" ]; then /acdcli-entrypoint.sh; fi

# option with gdrive
if [ -f "/gdrive-entrypoint.sh" ]; then /gdrive-entrypoint.sh; fi

# wait /media mount
if [ -n "$WAIT_OPTION" ]; then
	while [ -z "`ls /media`" ]
	do
	  echo "wait mount /media"
	  sleep 10
	done
	echo "mount completed! Plex starting..."
fi

exec "$@"
