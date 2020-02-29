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

# set environment
setenvironment() {
		export SOFT=${SOFT:-AppManager}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/AppManager}
		#export EDITTION=${EDITTION:-essential}
		export FIXED=${FIXED:-false}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
}
# set command install
installmanageengine() {
keystroke() {
	if [[ ${EDITTION} == 'essential' ]] || [[ ${EDITTION} == 'pro' ]] || [[ ${EDITTION} == 'professional' ]]; then
cat <<EOF > keystroke










Y
1
1
1
9090
8443
1
${SOFT_HOME}
N




EOF
	elif [[ ${EDITTION} == 'enterprise' ]]; then
cat <<EOF > keystroke










Y
2
1
1
9090
8443
1
${SOFT_HOME}
N




EOF
	elif [[ ${EDITTION} == 'free' ]]; then
cat <<EOF > keystroke










Y
3
1
1
9090
8443
1
${SOFT_HOME}
N




EOF
	fi
}
	echo "Download and install"
	export FILE_TEMP=install.bin
	if [[ ${MACHINE_TYPE} == 'x86_64' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_ApplicationsManager_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/products/applications_manager/54974026/ManageEngine_ApplicationsManager_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_ApplicationsManager.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/products/applications_manager/54974026/ManageEngine_ApplicationsManager.bin -o $FILE_TEMP
		fi
	else
		echo "Not support please edit and rebuild"
		exit 1
	fi
	echo "Install"
		chmod +x $FILE_TEMP
		keystroke
		./$FILE_TEMP -i console < keystroke
	# remove install files
		rm -f $FILE_TEMP keystroke
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
./startApplicationsManager.sh
sleep infinity