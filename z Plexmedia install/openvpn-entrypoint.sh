#!/bin/bash -e
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

DEFAULT_CLIENT_CONFIG="/etc/openvpn/client.conf"

CLIENT_CONFIG_FILE=${CLIENT_CONFIG_FILE:-${DEFAULT_CLIENT_CONFIG}}

appSetup () {
  mkdir -p /dev/net
  if [ ! -c /dev/net/tun ]; then
      mknod /dev/net/tun c 10 200
  fi

  if [ "${DEFAULT_CLIENT_CONFIG}" -ne "${CLIENT_CONFIG_FILE}" ]; then
    cp "${CLIENT_CONFIG_FILE}" "${DEFAULT_CLIENT_CONFIG}"
  fi
}

appStart () {
  appSetup
  [ -f /plex-entrypoint.sh ] && "/usr/local/bin/dumb-init /plex-entrypoint.sh"
  /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
}

appHelp () {
	echo "Available options:"
  echo " app:setup          - Setup all required configurations for running OpenVPN as client and a running dropbear sshd"
	echo " app:start          - Starts all services needed for OpenVPN as client and a running dropbear sshd"
	echo " app:help           - Displays the help"
	echo " [command]          - Execute the specified linux command eg. /bin/bash."
}

case "$1" in
  app:setup)
		appSetup
		;;
	app:start)
		appStart
		;;
	app:help)
		appHelp
		;;
	*)
		if [ -x $1 ]; then
			$1
		else
			prog=$(which $1)
			if [ -n "${prog}" ] ; then
				shift 1
				$prog $@
			else
				appHelp
			fi
		fi
		;;
esac

exit 0
