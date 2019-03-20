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
		export SOFT=${SOFT:-OpManager}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/OpManager}
		export EDITTION=${EDITTION:-essential}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
}
# set command install
installmanageengine() {
	echo "Download and install"
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_64bit.bin
		else
			wget -O install.bin https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager.bin
		else
		wget -O install.bin https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager.bin
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'enterprise' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_${SOFTSUB}_64bit.bin
		else
		wget -O install.bin https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_${SOFTSUB}_64bit.bin
		fi
	else
		echo "Not support please edit and rebuild"
		exit 1
	fi
	echo "Install"
		chmod +x install.bin
cat <<EOF > keystroke
1
q
1
0
1
Admin
admin@matmagoc.com
0
0
184
0
0
1
q
1
${SOFT_HOME}
${SOFT_HOME}
1
8060
1
1
0
1
1
3
EOF
		./install.bin -console < keystroke
		rm -f install.bin keystroke
}
installapm() {
	echo "Download and install APM"
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${APMINSTALL} == 'true' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_APM_PlugIn_64bit.bin
		else
			wget -O install.bin https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_APM_PlugIn_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${APMINSTALL} == 'true' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_APM_PlugIn.bin
		else
			wget -O install.bin https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_APM_PlugIn.bin
		fi
	else
		echo "Not support cant install APM Plugin"
		exit 1
	fi
	echo "Install"
		chmod +x install.bin
cat <<EOF > keystroke
1
0
1
0
1
0
1
9090
8443
1
/opt/ManageEngine/OpManager
/opt/ManageEngine/OpManager
1
1
3
EOF
		./install.bin -console < keystroke
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
		if [[ ${APMINSTALL} == 'true' ]]; then installapm; fi
	fi
# Run
cd ${SOFT_HOME}/bin
./run.sh