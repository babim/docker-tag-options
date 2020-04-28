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
	PASSWORD=${PASSWORD:-123456}

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

	echo "check path and install"
	if [[ -z "/home" ]]; then
		curl -#OL https://file.matmagoc.com/acunetix_trial.sh
			( \
				echo ""; \
				echo "q"; \
				echo "yes"; \
				echo "localhost"; \
				echo "`${EMAIL}`"; \
				echo "`${PASSWORD}`"; \
				echo "`${PASSWORD}`"; \
			) | bash acunetix_trial.sh
	fi

# run
runuser -l acunetix -c /home/acunetix/.acunetix_trial/start.sh