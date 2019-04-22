#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
set -u
# By default cmd1 | cmd2 returns exit code of cmd2 regardless of cmd1 success
# This is causing it to fail
set -o pipefail

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

# need root to run
	require_root

echo 'Check OS'
if [[ -f /etc/debian_version ]]; then
	# set host download
		export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Duplicati%20install"
	# Set frontend debian
		debian_cmd_interface
		export DUPLICATI_VER=2.0.4.5-1
		export D_CODEPAGE=UTF-8
		export D_LANG=en_US
		export UNINSTALL="${DOWNLOAD_TOOL}"
	# install depends
		install_package expect libsqlite3-0 locales \
			libmono-2.0-1 libmono-system-configuration-install4.0-cil libmono-system-data4.0-cil \
			libmono-system-drawing4.0-cil libmono-system-net4.0-cil libmono-system-net-http4.0-cil \
			libmono-system-net-http-webrequest4.0-cil libmono-system-runtime-serialization4.0-cil \
			libmono-system-servicemodel4.0a-cil libmono-system-servicemodel-discovery4.0-cil \
			libmono-system-serviceprocess4.0-cil libmono-system-transactions4.0-cil \
			libmono-system-web4.0-cil libmono-system-web-services4.0-cil libmono-microsoft-csharp4.0-cil \
			libappindicator3-0.1-cil gtk-sharp2 libappindicator1 libglib2.0-cil libgtk2.0-cil
		# libappindicator0.1-cil
	# install missing depend
		$download_save missing1.deb http://mirrors.kernel.org/ubuntu/pool/universe/liba/libappindicator/libappindicator0.1-cil_12.10.1+18.04.20180322.1-0ubuntu1_all.deb
		dpkg -i missing1.deb && remove_filefolder missing1.deb
	# install duplicati
		$download_save duplicati.deb https://updates.duplicati.com/beta/duplicati_${DUPLICATI_VER}_all.deb
		dpkg -i duplicati.deb && apt-get install -f -y && rm -f duplicati.deb
	# fix locales
		localedef -v -c -i ${D_LANG} -f ${D_CODEPAGE} ${D_LANG}.${D_CODEPAGE} || :
    		update-locale LANG=${D_LANG}.${D_CODEPAGE}
   		cert-sync /etc/ssl/certs/ca-certificates.crt
	# download entrypoint
		FILETEMP=/start.sh
		remove_file $FILETEMP
		say "download entrypoint.."
		$download_save $FILETEMP $DOWN_URL/start.sh
		chmod 755 $FILETEMP
	# remove packages
		clean_package
		clean_os
# OS - other
else
    say_err "Not support your OS"
    exit 1
fi