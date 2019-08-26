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
		export SOFT=${SOFT:-NetFlow}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/OpManager}
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
q
1
0
1
/opt/ManageEngine
/opt/ManageEngine
1
8060
9996
1
1
3
EOF
}
	echo "Download and install"
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_NetFlowAnalyzer_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/netflow/2028821/ManageEngine_NetFlowAnalyzer_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_NetFlowAnalyzer.bin
		else
			$download_save install.bin https://www.manageengine.com/products/netflow/2028821/ManageEngine_NetFlowAnalyzer.bin
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'enterprise' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_NFA_DE_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/netflow/2028821/ManageEngine_NFA_DE_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'free' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_NetFlowAnalyzer_Free_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/netflow/2028821/ManageEngine_NetFlowAnalyzer_Free_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'free' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_NetFlowAnalyzer_Free.bin
		else
			$download_save install.bin https://www.manageengine.com/products/netflow/2028821/ManageEngine_NetFlowAnalyzer_Free.bin
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