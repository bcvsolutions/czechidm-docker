#!/bin/bash
echo "[$0] Checking IdM secret.key...";

if [ ! -z "${DOCKER_SKIP_IDM_CONFIGURATION+x}" ]; then
  echo "[$0] The DOCKER_SKIP_IDM_CONFIGURATION is defined, skipping this script.";
  exit;
fi

cd "${CZECHIDM_CONFIG}/etc";

if [ ! -z "${DOCKER_SECURE_SECRETS+x}" ]; then
  echo "[$0] Explicitly securing /run/secrets directory because DockerCE!";
  chown root:tomcat /run/secrets;
  chmod 750 /run/secrets;
fi

if [ -L "secret.key" ] && [ ! -e "secret.key" ]; then
  echo "[$0] The secret.key appears to be broken symlink, unlinking...";
  unlink secret.key;
fi

if [ ! -f "secret.key" ] && [ -f "/run/secrets/secret.key" ]; then
  echo "[$0] Found secret key mounted in /run/secrets/secret.key, symlinking...";
  ln -s /run/secrets/secret.key secret.key;
fi

if [ ! -f "secret.key" ] && [ ! -L "secret.key" ]; then
  echo "[$0] The secret.key does not exist, generating new...";
  openssl rand -hex 8 > secret.key;
  chgrp tomcat secret.key;
  chmod 640 secret.key;
else
  length=$(wc -c secret.key | cut -d' ' -f1);
  if [ "$length" -ne 17 ] && [ "$length" -ne 33 ]; then
    echo "[$0] Weird secret.key found, not 17 or 33b long.";
  fi
  echo "[$0] The secret.key already exists, using what we have.";
fi
