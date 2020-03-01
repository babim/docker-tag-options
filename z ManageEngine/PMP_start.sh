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
		export SOFT=${SOFT:-PMP}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/PMP}
		#export EDITTION=${EDITTION:-essential}
		export FIXED=${FIXED:-false}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
}
# set command install
installmanageengine() {
keystroke() {
cat <<EOF > keystroke












Y
${SOFT_HOME}
Y
1




EOF
}
	echo "Download and install"
	export FILE_TEMP=install.bin
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'pro' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_PMP_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'pro' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_PMP.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'msp' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_PMP_MSP_64bit.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP_MSP_64bit.bin -o $FILE_TEMP
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'msp' ]]; then
		if [[ ${FIXED} == 'true' ]]; then
			curl -Ls http://media.matmagoc.com/ManageEngine/ManageEngine_PMP_MSP.bin -o $FILE_TEMP
		else
			curl -Ls https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP_MSP.bin -o $FILE_TEMP
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
if [[ ! -f "/etc/rc.d/init.d/pmp-service" ]]; then
	cd ${SOFT_HOME}/bin
	./pmp.sh install
fi
/etc/rc.d/init.d/pmp-service start
sleep infinity