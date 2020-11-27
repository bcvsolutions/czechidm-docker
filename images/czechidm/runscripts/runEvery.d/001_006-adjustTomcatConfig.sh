#!/bin/bash
echo "[$0] Configuring Tomcat for IdM...";

if [ ! -z "${DOCKER_SKIP_IDM_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_IDM_CONFIGURATION is defined, skipping this script.";
  exit;
fi

configfile="$RUNSCRIPTS_PATH/startTomcat.d/001_006-adjustTomcatConfig.sh";

echo -n > "$configfile";

echo "JAVA_OPTS=\"\$JAVA_OPTS -Dspring.profiles.active=docker\"" >> "$configfile";


# Tell tomcat to use IdM config folder
echo "[$0] Adding setenv.sh file to Tomcat bin/ ...";

echo 'CLASSPATH=/opt/czechidm/etc:/opt/czechidm/lib/*' > "$TOMCAT_BASE/bin/setenv.sh";
chgrp tomcat "$TOMCAT_BASE/bin/setenv.sh";
