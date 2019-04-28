#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

	# set environment
		PHP_VERSION=${PHP_VERSION:-false}
	# install
		install_supervisor
	# Supervisor config
		create_folder 	/var/log/supervisor/
		create_folder 	/etc/supervisor/conf.d/
	# download sypervisord config
	FILETEMP=supervisor/supervisord.conf
		$download_save 	/etc/$FILETEMP $DOWN_URL/$FILETEMP
	FILETEMP=/etc/supervisord.conf
		create_symlink 	$FILETEMP /etc/supervisor/supervisord.conf
	# php
		if has_value "${PHP_VERSION}" && ! check_value_false "${PHP_VERSION}"; then
			# fix value version
			has_equal "$PHP_VERSION" "56" 		&& export PHP_VERSION=5.6;
			has_equal "$PHP_VERSION" "70" 		&& export PHP_VERSION=7.0;
			has_equal "$PHP_VERSION" "71"		&& export PHP_VERSION=7.1;
			has_equal "$PHP_VERSION" "72"		&& export PHP_VERSION=7.2;
		FILETEMP=/etc/supervisor/conf.d/phpfpm-${PHP_VERSION}.conf
			remove_file 	$FILETEMP
			check_file 	/etc/php/${PHP_VERSION}/fpm ]] || $download_save $FILETEMP $DOWN_URL/supervisor/conf.d/phpfpm-${PHP_VERSION}.conf
		fi
	# apache
	#if check_file "/usr/sbin/apache2ctl"; then
	if machine_has apache2ctl; then
		FILETEMP=supervisor/conf.d/apache.conf
			$download_save 	/etc/$FILETEMP $DOWN_URL/$FILETEMP
	fi
	# nginx
	#if check_file "/usr/sbin/nginx"; then
	if machine_has nginx; then
		FILETEMP=supervisor/conf.d/nginx.conf
			$download_save 	/etc/$FILETEMP $DOWN_URL/$FILETEMP
	fi
	# litespeed
	#if check_file "/usr/local/lsws/bin/lswsctrl"; then
	if machine_has lswsctrl; then
		FILETEMP=supervisor/conf.d/litespeed.conf
			$download_save 	/etc/$FILETEMP $DOWN_URL/$FILETEMP
	fi