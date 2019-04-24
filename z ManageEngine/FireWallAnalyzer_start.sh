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

# download option
say_warning "Check and set download tool..."
if machine_has "curl"; then
    # download_tool for command download. use like this $download_tool
    export download_tool="curl -Ls"
    # DOWNLOAD_TOOL use when remove download tool package
    export DOWNLOAD_TOOL="curl"
    export download_save=download_with_curl
    say "use curl"
elif machine_has "wget"; then
    export download_tool="wget"
    export DOWNLOAD_TOOL="wget"
    export download_save=download_with_wget
    say "use wget"
else
    say_err "without download tool"
    sleep 3
    exit $FALSE
fi
if machine_has "curl" && machine_has "wget"; then export DOWNLOAD_TOOL="wget curl";fi

# set environment
setenvironment() {
		export SOFT=${SOFT:-FireWallAnalyzer}
		#export SOFTSUB=${SOFTSUB:-core}
		export SOFT_HOME=${SOFT_HOME:-/opt/ManageEngine/OpManager}
		#export EDITTION=${EDITTION:-essential}
		export FIXED=${FIXED:-false}

	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20ManageEngine"
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
/opt/ManageEngine
/opt/ManageEngine
1
8060
1
1
3
EOF
}
	echo "Download and install"
	if [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		keystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_FirewallAnalyzer_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/firewall/61794333/ManageEngine_FirewallAnalyzer_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'essential' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_FirewallAnalyzer.bin
		else
			$download_save install.bin https://www.manageengine.com/products/firewall/61794333/ManageEngine_FirewallAnalyzer.bin
		fi
	elif [[ ${MACHINE_TYPE} == 'x86_64' ]] && [[ ${EDITTION} == 'enterprise' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_FirewallAnalyzer_DE_64bit.bin
		else
			$download_save install.bin https://www.manageengine.com/products/firewall/distributed-monitoring/11042744/ManageEngine_FirewallAnalyzer_DE_64bit.bin
		fi
	elif [[ ${MACHINE_TYPE} != 'x86_64' ]] && [[ ${EDITTION} == 'enterprise' ]]; then
		opmanagerkeystroke
		if [[ ${FIXED} == 'true' ]]; then
			$download_save install.bin http://media.matmagoc.com/ManageEngine/ManageEngine_FirewallAnalyzer_DE.bin
		else
			$download_save install.bin https://www.manageengine.com/products/firewall/distributed-monitoring/11042744/ManageEngine_FirewallAnalyzer_DE.bin
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