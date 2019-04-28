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

export DOWN_URL="https://raw.githubusercontent.com/babim/docker-tag-options/master/z%20Postgresql%20install"

# install by OS
echo 'Check OS'
if [[ -f /etc/debian_version ]] || [[ -f /etc/lsb-release ]]; then
	# set environment
	debian_cmd_interface
		PG_APP_HOME=${PG_APP_HOME:-"/etc/docker-postgresql"} \
		PG_USER=${PG_USER:-"postgres"} \
		PG_HOME=${PG_HOME:-"/var/lib/postgresql"} \
		PG_RUNDIR=${PG_RUNDIR:-"/run/postgresql"} \
		PG_LOGDIR=${PG_LOGDIR:-"/var/log/postgresql"} \
		PG_CERTDIR=${PG_CERTDIR:-"/etc/postgresql/certs"}
	# add repo
		debian_add_repo_key https://www.postgresql.org/media/keys/ACCC4CF8.asc \
		&& echo "deb http://apt.postgresql.org/pub/repos/apt/ $OSDEB-pgdg main" > /etc/apt/sources.list.d/pgdg.list
	# install
		install_package acl sudo \
		postgresql-${PG_VERSION} postgresql-client-${PG_VERSION} postgresql-contrib-${PG_VERSION} \
		&& create_symlink ${PG_DATADIR}/postgresql.conf /etc/postgresql/${PG_VERSION}/main/postgresql.conf \
		&& create_symlink ${PG_DATADIR}/pg_hba.conf /etc/postgresql/${PG_VERSION}/main/pg_hba.conf \
		&& create_symlink ${PG_DATADIR}/pg_ident.conf /etc/postgresql/${PG_VERSION}/main/pg_ident.conf
	# download config files
		check_file /entrypoint.sh && remove_file /start.sh
		FILETEMP=/entrypoint.sh
			$download_save $FILETEMP $DOWN_URL$FILETEMP
		set_filefolder_mod 755 $FILETEMP
	# clean
		remove_filefolder ${PG_HOME}
		remove_download_tool
		clean_os

elif [ -f /etc/alpine-release ]; then
	# FROM POSTGRESQL DOCKER ALPINE OFFICIAL
		# alpine includes "postgres" user/group in base install
		set -ex; \
			postgresHome="$(getent passwd postgres)"; \
			postgresHome="$(echo "$postgresHome" | cut -d: -f6)"; \
			[ "$postgresHome" = '/var/lib/postgresql' ]; \
			create_folder "$postgresHome"; \
			set_filefolder_owner postgres:postgres "$postgresHome"

		# su-exec (gosu-compatible) is installed further down

		# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
		# alpine doesn't require explicit locale-file generation
		export LANG=en_US.utf8
		OSSP_UUID_VERSION=1.6.2

		create_folder /docker-entrypoint-initdb.d

		# install
		set -ex \
		\
		&& install_package --virtual .fetch-deps \
			ca-certificates \
			openssl \
			tar \
		\
		&& $download_save postgresql.tar.bz2 "https://ftp.postgresql.org/pub/source/v$PG_VERSION/postgresql-$PG_VERSION.tar.bz2" \
		&& create_folder /usr/src/postgresql \
		&& tar \
			--extract \
			--file postgresql.tar.bz2 \
			--directory /usr/src/postgresql \
			--strip-components 1 \
		&& remove_file postgresql.tar.bz2 \
		\
		&& install_package --virtual .build-deps \
			bison \
			coreutils \
			dpkg-dev dpkg \
			flex \
			gcc \
			libc-dev \
			libedit-dev \
			libxml2-dev \
			libxslt-dev \
			make \
			perl-ipc-run \
			openssl-dev \
			util-linux-dev \
			zlib-dev \
			icu-dev \
			perl-utils
	#		openldap-dev \
	#		krb5-dev \
	# configure: error: Perl module IPC::Run is required to run TAP tests \
	#		perl-dev \
	#		python-dev \
	#		python3-dev \
	#		tcl-dev \

		cd /usr/src/postgresql
	# update "DEFAULT_PGSOCKET_DIR" to "/var/run/postgresql" (matching Debian)
	# see https://anonscm.debian.org/git/pkg-postgresql/postgresql.git/tree/debian/patches/51-default-sockets-in-var.patch?id=8b539fcb3e093a521c095e70bdfa76887217b89f
		awk '$1 == "#define" && $2 == "DEFAULT_PGSOCKET_DIR" && $3 == "\"/tmp\"" { $3 = "\"/var/run/postgresql\""; print; next } { print }' src/include/pg_config_manual.h > src/include/pg_config_manual.h.new \
		&& grep '/var/run/postgresql' src/include/pg_config_manual.h.new \
		&& mv src/include/pg_config_manual.h.new src/include/pg_config_manual.h \
		&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" 
	# explicitly update autoconf config.guess and config.sub so they support more arches/libcs
		$download_save config/config.guess 'https://git.savannah.gnu.org/cgit/config.git/plain/config.guess?id=7d3d27baf8107b630586c962c057e22149653deb' \
		&& $download_save config/config.sub 'https://git.savannah.gnu.org/cgit/config.git/plain/config.sub?id=7d3d27baf8107b630586c962c057e22149653deb'
	# configure options taken from: \
	# https://anonscm.debian.org/cgit/pkg-postgresql/postgresql.git/tree/debian/rules?h=9.5 \
		./configure \
			--build="$gnuArch" \
			--enable-integer-datetimes \
			--enable-thread-safety \
			--enable-tap-tests \
			--disable-rpath \
			--with-uuid=e2fs \
			--with-gnu-ld \
			--with-pgport=5432 \
			--with-system-tzdata=/usr/share/zoneinfo \
			--prefix=/usr/local \
			--with-includes=/usr/local/include \
			--with-libraries=/usr/local/lib \
			--with-openssl \
			--with-libxml \
			--with-libxslt \
			--with-icu \
		&& make -j "$(nproc)" world \
		&& make install-world \
		&& make -C contrib install
	# "/usr/src/postgresql/src/backend/access/common/tupconvert.c:105: undefined reference to `libintl_gettext'" \
	#		--enable-nls \
	# skip debugging info -- we want tiny size instead \
	#		--enable-debug \
	# these make our image abnormally large (at least 100MB larger), which seems uncouth for an "Alpine" (ie, "small") variant :) \
	#		--with-krb5 \
	#		--with-gssapi \
	#		--with-ldap \
	#		--with-tcl \
	#		--with-perl \
	#		--with-python \
	#		--with-pam \

		runDeps="$( \
			scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
				| tr ',' '\n' \
				| sort -u \
				| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
		)" \
		&& install_package --virtual .postgresql-rundeps \
			$runDeps \
			bash \
			su-exec \
			tzdata

	# make the sample config easier to munge (and "correct by default") \
		sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /usr/local/share/postgresql/postgresql.conf.sample
		create_folder /var/run/postgresql && set_filefolder_owner postgres:postgres /var/run/postgresql && set_filefolder_mod 2777 /var/run/postgresql

		PGDATA=/var/lib/postgresql/data
		create_folder "$PGDATA" && set_filefolder_owner postgres:postgres "$PGDATA" && set_filefolder_mod 777 "$PGDATA" # this 777 will be replaced by 700 at runtime (allows semi-arbitrary "--user" values)

	# download config files
		FILETEMP=/alpine_start.sh
			$download_save $FILETEMP $DOWN_URL$FILETEMP
			set_filefolder_mod 755 $FILETEMP

	# Clean
		remove_package .fetch-deps .build-deps $DOWNLOAD_TOOL \
		&& cd / \
		&& remove_filefolder \
			/usr/src/postgresql \
			/usr/local/share/doc \
			/usr/local/share/man \
		&& find /usr/local -name '*.a' -delete

# OS - other
else
    say_err "Not support your OS"
    exit 1
fi