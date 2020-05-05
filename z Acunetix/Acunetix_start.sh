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
		curl -#OL https://file.matmagoc.com/acunetix_trial.sh
		#curl -#OL https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Acunetix/install.expect
cat <<EOFF>> install.expect
#!/usr/bin/expect -f
 
set timeout -1
set send_human {.1 .3 1 .05 2}
 
spawn bash ./acunetix_trial.sh
 
# expect "press ENTER to continue\r"
expect ">>>"
 
send -h "\r\n"
send -h "\x03"

expect "Accept the license terms?"
send -h "yes\r"
 
expect "Insert new hostname, or leave blank to use"
send -h "\r"
 
expect "Email:"
send -h "${EMAIL}"
expect "Password:"
send -h "${PASSWORD}\r"
expect "Password again:"
send -h "${PASSWORD}\r"
 
expect eof
EOFF
		chmod +x install.expect && ./install.expect
		#	( \
		#		echo ""; \
		#		echo "q"; \
		#		echo "yes"; \
		#		echo "localhost"; \
		#		echo "${EMAIL}"; \
		#		echo "${PASSWORD}"; \
		#		echo "${PASSWORD}"; \
		#	) | bash acunetix_trial.sh
		# print password infomation
		echo "Installed with:"
		echo "Email: ${EMAIL}"
		echo "Password: ${PASSWORD}"
		# remove file
		rm -f install.expect acunetix_trial.sh
	fi
# check user
	if id acunetix >/dev/null 2>&1; then
		echo "user exists"
	else
		groupadd -g 1000 acunetix
		useradd --system --uid 999 -g acunetix -d /home/acunetix acunetix
	fi
# set password openvas
	if [[ ! -d "/var/lib/openvas" ]]; then
		openvasmd --user=admin --new-password="${PASSWORD}"
	fi
# run
echo "Run Acunetix..."
greenbone-scapdata-sync
runuser -l acunetix -c /home/acunetix/.acunetix/start.sh

exec "$@"