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
		export SOFT=${SOFT:-AssetExplorer}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/AssetExplorer}
		#export EDITTION=${EDITTION:-essential}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
}
# set command install
installmanageengine() {
keystroke() {
	if [[ ${EDITTION} == 'pro' ]]; then
cat <<EOF > keystroke
1
1
0
1
admin
admin@example.com
0
0
246
0
0
1
1
0
1
/opt/ManageEngine/AssetExplorer
/opt/ManageEngine/AssetExplorer
1
8080
1
1
3
EOF
	elif [[ ${EDITTION} == 'free' ]]; then
cat <<EOF > keystroke
1
1
0
1
admin
admin@example.com
0
0
246
0
0
1
2
0
1
/opt/ManageEngine/AssetExplorer
/opt/ManageEngine/AssetExplorer
1
8080
1
1
3
EOF
	fi
}
	echo "Download and install"
	if [[ ${MACHINE_TYPE} != 'x86_64' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			wget -O install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_AssetExplorer.bin
		else
			wget -O install.bin https://www.manageengine.com/products/asset-explorer/87652187/ManageEngine_AssetExplorer.bin
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