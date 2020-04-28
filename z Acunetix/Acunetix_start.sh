#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# check permission root
echo 'Check root'
if [[ "x$(id -u)" != 'x0' ]]; then
	echo 'Error: this script can only be executed by root'
	exit 1
fi
# set MACHINE_TYPE
MACHINE_TYPE=${MACHINE_TYPE:-`uname -m`}
[[ ${MACHINE_TYPE} == 'x86_64' ]] && echo "Your server is x86_64 system" || echo "Your server is x86 system"

# environment
	EMAIL=${EMAIL:-example@matmagoc.com}
	PASSWORD=${PASSWORD:-Hello123!}

# option with entrypoint
	if [ -f "/option.sh" ]; then /option.sh; fi

# check path and install
	echo "check path and install"
	if [[ ! -d "/home/acunetix" ]]; then
		echo "Instal Acunetix..."
		groupadd -g 1000 acunetix
		useradd --system --uid 999 -g acunetix acunetix
		curl -#OL https://file.matmagoc.com/acunetix_trial.sh
			( \
				echo ""; \
				echo "q"; \
				echo "yes"; \
				echo "localhost"; \
				echo "${EMAIL}"; \
				echo "${PASSWORD}"; \
				echo "${PASSWORD}"; \
			) | bash acunetix_trial.sh
		echo "Installed with:"
		echo "Email: ${EMAIL}"
		echo "Password: ${PASSWORD}"
	fi
# check user
	if id acunetix >/dev/null 2>&1; then
		echo "user exists"
	else
		groupadd -g 1000 acunetix
		useradd --system --uid 999 -g acunetix acunetix
	fi

# run
echo "Run Acunetix..."
runuser -l acunetix -c /home/acunetix/.acunetix/start.sh