#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

set -e

# option with entrypoint
if [ -f "/option.sh" ]; then /option.sh; fi

	echo "check path and install"
	if [ ! -z "`ls ${SOFT_HOME}`" ]; then
		cp -R /start/* ${SOFT_HOME}
	fi
# Run
cd ${SOFT_HOME}/bin
./run.sh