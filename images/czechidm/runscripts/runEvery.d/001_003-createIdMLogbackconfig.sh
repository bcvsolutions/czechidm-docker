#!/bin/bash
echo "[$0] Checking IdM Logback configuration...";

if [ ! -z "${DOCKER_SKIP_IDM_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_IDM_CONFIGURATION is defined, skipping this script.";
  exit;
fi

# Those are defaults if not set from outside. Defaults on empty string.
if [ -z "${CZECHIDM_LOGGING_LEVEL}" ]; then
  CZECHIDM_LOGGING_LEVEL="INFO";
fi
if [ -z "${CZECHIDM_LOGGING_LEVEL_DB}" ]; then
  CZECHIDM_LOGGING_LEVEL_DB="ERROR";
fi

cd "$CZECHIDM_CONFIG/etc";

# check if the log level changed between container starts
if [ -f "logback-idm.previous" ]; then
  echo "[$0] The logback-idm.previous exists, checking loglevel change...";
  idmll=$(grep "CZECHIDM_LOGGING_LEVEL:" logback-idm.previous | cut -d: -f2-);
  idmlldb=$(grep "CZECHIDM_LOGGING_LEVEL_DB:" logback-idm.previous | cut -d: -f2-);

  if [ "$idmll" != "$CZECHIDM_LOGGING_LEVEL" ] || [ "$idmlldb" != "$CZECHIDM_LOGGING_LEVEL_DB" ]; then
    echo "[$0] Loglevel changed, removing old logging config logback-spring.xml.";
    rm -f logback-spring.xml;
  fi
fi

if [ ! -f "logback-spring.xml" ]; then
  echo "[$0] The logback-spring.xml does not exist, generating new...";

  cp "$TOMCAT_BASE/webapps/idm/WEB-INF/classes/logback-spring.xml" "$CZECHIDM_CONFIG/etc/logback-spring.xml";
  dos2unix "$CZECHIDM_CONFIG/etc/logback-spring.xml" 2>/dev/null;

  # use dev profile (idm+pgsql) and create docker profile from it, adjust logging of components
  # according to logging level variables; get rid of all other profiles
  xmlstarlet ed -L -d "//configuration/springProfile[@name!='dev']" logback-spring.xml && \
  xmlstarlet ed -L -u "//springProfile/@name" -v "docker" logback-spring.xml && \
  xmlstarlet ed -L -u "//springProfile/logger/@level" -v "$CZECHIDM_LOGGING_LEVEL" logback-spring.xml && \
  xmlstarlet ed -L -s "//appender[@name='DB']" -t elem -n filter -v "" \
    -a "//appender[@name='DB']/filter" -t attr -n class -v "ch.qos.logback.classic.filter.ThresholdFilter" \
    -s "//appender[@name='DB']/filter" -t elem -n level -v "$CZECHIDM_LOGGING_LEVEL_DB" logback-spring.xml

  chgrp tomcat logback-spring.xml;

  echo "CZECHIDM_LOGGING_LEVEL:$CZECHIDM_LOGGING_LEVEL" > logback-idm.previous;
  echo "CZECHIDM_LOGGING_LEVEL_DB:$CZECHIDM_LOGGING_LEVEL_DB" >> logback-idm.previous;
else
  echo "[$0] The logback-spring.xml already exists and up to date, using what we have.";
fi
