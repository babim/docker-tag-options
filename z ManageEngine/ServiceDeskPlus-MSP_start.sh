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
		export SOFT=${SOFT:-ServiceDeskPlus-MSP}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/ServiceDeskPlus-MSP}
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
	if [[ ${EDITTION} == 'enterprise' ]]; then
cat <<EOF > keystroke
1
q
1
0
1
admin
admin@example.com
0
0
184
0
0
1
1
0
1
/opt/ManageEngine/ServiceDeskPlus-MSP
/opt/ManageEngine/ServiceDeskPlus-MSP
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
admin@example.com
0
0
184
0
0
1
2
0
1
/opt/ManageEngine/ServiceDeskPlus-MSP
/opt/ManageEngine/ServiceDeskPlus-MSP
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
1
q
1
0
1
admin
admin@example.com
0
0
184
0
0
1
3
0
1
/opt/ManageEngine/ServiceDeskPlus-MSP
/opt/ManageEngine/ServiceDeskPlus-MSP
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
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_ServiceDesk_Plus_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/service-desk/91677414/ManageEngine_ServiceDesk_Plus_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_ServiceDesk_Plus.bin
		else
			$download_save install.bin https://www.manageengine.com/products/service-desk/91677414/ManageEngine_ServiceDesk_Plus.bin
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
cd ${SOFT_HOME}/bin
./run.sh
# if error
	export DELAY=${DELAY:-300}
		echo "run ${SOFT_HOME}/bin/changeDBServer.sh to other database server"
		echo "If postgresql on local server start failed"
		echo "change DELAY environment value to long time by -e DELAY"