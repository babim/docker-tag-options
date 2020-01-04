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

#####################################
    ####### Set download tool #######
    ####### and load library ########
# check has package
function    machine_has() {
        hash "$1" > /dev/null 2>&1
        return $?; }
# Check and set download tool
echo "Check and set download tool..."
if machine_has "curl"; then
    source <(curl -s https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
elif machine_has "wget"; then
    source <(wget -qO- https://raw.githubusercontent.com/babim/docker-tag-options/master/lib/libbash)
else
    echo "without download tool"
    sleep 3
    exit 1
fi
download_option
#####################################
}
# set command install
installmanageengine() {
keystroke() {
cat <<EOF > keystroke











y
/opt/ManageEngine/PMP
y
1




EOF
}
	echo "Download and install"
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'pro' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_PMP_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'pro' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_PMP.bin
		else
			$download_save install.bin https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP.bin
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'msp' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_PMP_MSP_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP_MSP_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'msp' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_PMP_MSP.bin
		else
			$download_save install.bin https://www.manageengine.com/products/passwordmanagerpro/8621641/ManageEngine_PMP_MSP.bin
		fi
	else
		echo "Not support please edit and rebuild"
		exit 1
	fi
	echo "Install"
		chmod +x install.bin
		./install.bin -i console < keystroke
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
if [[ ! -f "/etc/rc.d/init.d/pmp-service" ]]; then
	cd ${SOFT_HOME}/bin
	./pmp.sh install
fi
/etc/rc.d/init.d/pmp-service start
sleep infinity