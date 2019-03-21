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
MACHINE_TYPE=`uname -m`
if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
	echo x64
else
	echo x86
fi

# set environment
setenvironment() {
		export SOFT=${SOFT:-ServiceDesk}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/ServiceDesk}
		#export EDITTION=${EDITTION:-essential}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
}
# set command install
installmanageengine() {
keystroke() {
	if [[ ${EDITTION} == 'enterprise' ]]; then
cat <<EOF > keystroke
1
q
1
0
1
admin
admin@matmagoc.com
0
0
246
0
0
1
1
0
1
/opt/ManageEngine/ServiceDesk
/opt/ManageEngine/ServiceDesk
1
8080
1
1
1
3
EOF
	elif [[ ${EDITTION} == 'standard' ]]; then
cat <<EOF > keystroke
1
q
1
0
1
admin
admin@matmagoc.com
0
0
246
0
0
1
2
0
1
/opt/ManageEngine/ServiceDesk
/opt/ManageEngine/ServiceDesk
1
8080
1
1
1
3
EOF
	elif [[ ${EDITTION} == 'pro' ]]; then
cat <<EOF > keystroke
1
q
1
0
1
admin
admin@matmagoc.com
0
0
246
0
0
1
3
0
1
/opt/ManageEngine/ServiceDesk
/opt/ManageEngine/ServiceDesk
1
8080
1
1
1
3
EOF
	fi
}
	echo "Download and install"
	if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_ServiceDesk_Plus_64bit.bin
		else
			wget -O install.bin https://www.manageengine.com/products/service-desk/91677414/ManageEngine_ServiceDesk_Plus_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_ServiceDesk_Plus.bin
		else
			wget -O install.bin https://www.manageengine.com/products/service-desk/91677414/ManageEngine_ServiceDesk_Plus.bin
		fi
	else
		echo "Not support please edit and rebuild"
		exit 1
	fi
	echo "Install"
		chmod +x install.bin
		./install.bin -console < keystroke
	# remove install files
		rm -f install.bin keystroke
}

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

	echo "check path and install"
	if [[ -z "`ls ${SOFT_HOME}`" ]] || [[ ! -d "${SOFT_HOME}" ]]; then
#		rsync -arvpz --numeric-ids /start/ ${SOFT_HOME}
	# install manage engine
		setenvironment
		installmanageengine
	fi
# Run
cd ${SOFT_HOME}
./run.sh