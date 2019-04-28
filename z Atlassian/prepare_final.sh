#!/bin/bash
#  ____        _     _
# | __ )  __ _| |__ (_)_ __ ___
# |  _ \ / _` | '_ \| | '_ ` _ \
# | |_) | (_| | |_) | | | | | | |
# |____/ \__,_|_.__/|_|_| |_| |_|

# need root to run
	require_root

# download docker entry
	FILETEMP=/docker-entrypoint.sh
	say "download entrypoint.."
# visible code
	if check_value_true "${VISIBLECODE}"; then
		$download_save $FILETEMP $DOWN_URL/${SOFT}_fixed.sh
		if [[ "${SOFT}" = "confluence" || "${SOFT}" = "jira" ]]; then
			$download_save ${SOFT_INSTALL}/agent.jar http://media.matmagoc.com/atlassian-agent.jar
			echo 'export CATALINA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> ${SOFT_INSTALL}/bin/setenv.sh
		fi
	else
		$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
	fi
	set_filefolder_mod +x $FILETEMP