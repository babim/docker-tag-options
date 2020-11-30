#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# set environment
setenvironment() {
	export ORACLE_VERSION=12.2.0.1.0
	if [[ $ORACLE_VERSION == 12.2.0.1.0 ]]; then export ORCL_PATH=12_2; fi
	PHP_VERSION=${PHP_VERSION:-false}
}

# install by OS
echo 'Check OS'
if [[ -f /etc/lsb-release ]] || [[ -f /etc/debian_version ]]; then
	# set environment
		setenvironment
		debian_cmd_interface
	# install add repo
		curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -y -
		curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
	# install mssql-tool
		apt-get update
		ACCEPT_EULA=Y install_package msodbcsql17
	# optional: for bcp and sqlcmd
		ACCEPT_EULA=Y install_package mssql-tools
		'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
		'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
		source ~/.bashrc
	# optional: for unixODBC development headers
		install_package -y unixodbc-dev
	# install with pecl
	 	pecl install sqlsrv
		pecl install pdo_sqlsrv
	if [[ "$PHP_VERSION" == "7.0" || "$PHP_VERSION" == "70" ]];then
		printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.0/mods-available/sqlsrv.ini
		printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.0/mods-available/pdo_sqlsrv.ini
		exit
		phpenmod -v 7.0 sqlsrv pdo_sqlsrv
	elif [[ "$PHP_VERSION" == "7.1" || "$PHP_VERSION" == "71" ]];then
		printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.1/mods-available/sqlsrv.ini
		printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.1/mods-available/pdo_sqlsrv.ini
		exit
		phpenmod -v 7.1 sqlsrv pdo_sqlsrv
	elif [[ "$PHP_VERSION" == "7.2" || "$PHP_VERSION" == "72" ]];then
		printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.2/mods-available/sqlsrv.ini
		printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.2/mods-available/pdo_sqlsrv.ini
		exit
		phpenmod -v 7.2 sqlsrv pdo_sqlsrv
	elif [[ "$PHP_VERSION" == "7.3" || "$PHP_VERSION" == "73" ]];then
		printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.3/mods-available/sqlsrv.ini
		printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.3/mods-available/pdo_sqlsrv.ini
		exit
		phpenmod -v 7.3 sqlsrv pdo_sqlsrv
	elif [[ "$PHP_VERSION" == "7.4" || "$PHP_VERSION" == "74" ]];then
		printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/7.4/mods-available/sqlsrv.ini
		printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/7.4/mods-available/pdo_sqlsrv.ini
		exit
		phpenmod -v 7.4 sqlsrv pdo_sqlsrv
	fi

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi
