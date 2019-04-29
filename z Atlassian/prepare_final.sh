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
		$download_save ${SOFT_INSTALL}/agent.jar http://media.matmagoc.com/atlassian-agent.jar
		if [[ -f  "${SOFT_INSTALL}/bin/start-${SOFT}.sh" ]]; then
			echo 'JAVA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> "${SOFT_INSTALL}/bin/start-${SOFT}.sh"
		elif [[ -f  "${SOFT_INSTALL}/bin/start_${SOFT}.sh" ]]; then
			echo 'JAVA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> "${SOFT_INSTALL}/bin/start_${SOFT}.sh"
		elif [[ -f  "${SOFT_INSTALL}/start-${SOFT}.sh" ]]; then
			echo 'JAVA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> "${SOFT_INSTALL}/start-${SOFT}.sh"
		elif [[ -f  "${SOFT_INSTALL}/start_${SOFT}.sh" ]]; then
			echo 'JAVA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> "${SOFT_INSTALL}/start_${SOFT}.sh"
		elif [[ -f  "${SOFT_INSTALL}/bin/start.sh" ]]; then
			echo 'JAVA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> "${SOFT_INSTALL}/bin/start.sh"
		elif [[ -f  "${SOFT_INSTALL}/start.sh" ]]; then
			echo 'JAVA_OPTS="-javaagent:${SOFT_INSTALL}/agent.jar ${CATALINA_OPTS}"' >> "${SOFT_INSTALL}/start.sh"
		fi
	else
		$download_save $FILETEMP $DOWN_URL/${SOFT}_start.sh
	fi
	set_file_mod +x $FILETEMP