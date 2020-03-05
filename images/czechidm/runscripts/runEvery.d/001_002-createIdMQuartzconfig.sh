#!/bin/bash
echo "[$0] Checking IdM Quartz configuration...";

if [ ! -z "${DOCKER_SKIP_IDM_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_IDM_CONFIGURATION is defined, skipping this script.";
  exit;
fi

cd "$CZECHIDM_CONFIG/etc";

if [ ! -f "quartz-docker.properties" ]; then
  echo "[$0] The quartz-docker.properties does not exist, generating new...";

  cp "$TOMCAT_BASE/webapps/idm/WEB-INF/classes/quartz-dev.properties" "$CZECHIDM_CONFIG/etc/quartz-docker.properties";
  dos2unix "$CZECHIDM_CONFIG/etc/quartz-docker.properties" 2>/dev/null;
  tcount=$(grep 'org.quartz.threadPool.threadCount' quartz-docker.properties | cut -d= -f2);
  if [ "$tcount" -lt 10 ]; then
    echo "[$0] Quartz threadCount from default config is $tcount, setting to 10.";
    sed -i \
        -e 's/org\.quartz\.threadPool\.threadCount.*/org\.quartz\.threadPool\.threadCount=10/' \
        quartz-docker.properties;
  else
    echo "[$0] No changes to the default config necessary.";
  fi

  chgrp tomcat quartz-docker.properties;
else
  echo "[$0] The quartz-docker.properties already exists, using what we have.";
fi
