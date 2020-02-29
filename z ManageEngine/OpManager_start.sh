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
		export SOFT=${SOFT:-OpManager}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/OpManager}
		export EDITTION=${EDITTION:-essential}
		export FIXED=${FIXED:-false}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
}
# set command install
installmanageengine() {
opmanagerkeystroke() {
cat <<EOF > keystroke













Y
N
${SOFT_HOME}
8060


EOF
}

	echo "Download and install"
	export FILE_TEMP=install.bin
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'enterprise' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_${SOFTSUB}_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_${SOFTSUB}_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'free' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_Free_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_Free_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'free' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_Free.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_Free.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'plus' ]]; then
		curl -Ls https://www.manageengine.com/it-operations-management/29809517/ManageEngine_OpManager_Plus_64bit.bin -o $FILE_TEMP
	else
		echo "Not support please edit and rebuild"
		exit 1
	fi
	echo "Install"
		chmod +x $FILE_TEMP
		opmanagerkeystroke
		./$FILE_TEMP -i console < keystroke
	# remove install files
		rm -f $FILE_TEMP keystroke
	# fix reading serverparameters.conf
	if [[ ! -f "${SOFT_HOME}/conf/OpManager/serverparameters.conf" ]]; then
		cp ${SOFT_HOME}/ancillary/en/html/serverparameters.conf ${SOFT_HOME}/conf/OpManager/
	fi
}
installapm() {
	echo "Download and install APM"
	export FILE_TEMP=install.bin
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${APMINSTALL} == 'true' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_APM_PlugIn_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_APM_PlugIn_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${APMINSTALL} == 'true' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_OpManager_APM_PlugIn.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/network-monitoring/29809517/ManageEngine_OpManager_APM_PlugIn.bin -o $FILE_TEMP
		fi
	else
		echo "Not support cant install APM Plugin"
		exit 1
	fi
	echo "Install"
		chmod +x install.bin
cat <<EOF > keystroke

1
1
1
9090
8443
${SOFT_HOME}
Y




EOF
		./install.bin -i console < keystroke
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
# if error
	export DELAY=${DELAY:-300}
		echo "run ${SOFT_HOME}/bin/changeDBServer.sh to other database server"
		echo "If postgresql on local server start failed"
		echo "change DELAY environment value to long time by -e DELAY"