#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# Stop script on NZEC
set -e
# Stop script if unbound variable found (use ${var:-} if intentional)
# set -u
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

if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
		FILETEMP=percona-release_0.1-4.${OSDEB}_all.deb
		$download_save $FILETEMP https://repo.percona.com/apt/$FILETEMP
		dpkg -i $FILETEMP
		remove_file $FILETEMP

	# # install depend
	# apt-get install -y --no-install-recommends \
	# apt-transport-https ca-certificates
	# # add repo Percona
	# set -ex; \
	# 	key='430BDF5C56E7C94E848EE60C1C4CBDCDCD2EFD2A'; \
	# 	export GNUPGHOME="$(mktemp -d)"; \
	# 	gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	# 	gpg --export "$key" > /etc/apt/trusted.gpg.d/percona.gpg; \
	# 	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	# 	rm -rf "$GNUPGHOME"; \
	# 	key='4D1BB29D63D98E422B2113B19334A25F8507EFA5'; \
	# 	export GNUPGHOME="$(mktemp -d)"; \
	# 	gpg --no-tty --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
	# 	gpg --export "$key" >> /etc/apt/trusted.gpg.d/percona.gpg; \
	# 	command -v gpgconf > /dev/null && gpgconf --kill all || :; \
	# 	rm -rf "$GNUPGHOME"; \
	# 	apt-key list > /dev/null
	# # add Percona's repo for xtrabackup (which is useful for Galera)
	# echo "deb https://repo.percona.com/apt $OSDEB main" > /etc/apt/sources.list.d/percona.list \
	# 	&& { \
	# 		echo 'Package: *'; \
	# 		echo 'Pin: release o=Percona Development Team'; \
	# 		echo 'Pin-Priority: 998'; \
	# 	} > /etc/apt/preferences.d/percona

elif [[ -f /etc/redhat-release ]]; then
	# add repo Percona
	rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
else
    say_err "Not support your OS"
    exit 1
fi