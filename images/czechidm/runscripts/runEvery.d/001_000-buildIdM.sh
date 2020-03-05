#!/bin/bash

echo "[$0] Checking IdM modules, build root is $CZECHIDM_BUILDROOT .";
cd "$CZECHIDM_BUILDROOT";

rebuild="false";
# checking all dirs where we can expect things to change
for dir in modules frontend/config frontend/czechidm-modules; do
  echo "[$0] Checking directory: $dir.";
  hashfile=$(echo "$dir" | sed 's#/#-#');
  # this file contains hashed entries of a directory - to check when files change
  if [ ! -f "checksums/$hashfile" ] && [ "$(ls -A $dir)x" == "x" ]; then
    #no checksum and also empty dir - nothing to build
    echo "[$0] Hashfile: $hashfile does not exist and directory: $dir is empy, moving on.";
    continue;
  fi
  if [ ! -f "checksums/$hashfile" ] && [ "$(ls -A $dir)x" != "x" ]; then
    #no checksum but non-empty dir - we will rebuild
    echo "[$0] Hashfile: $hashfile does not exist but directory: $dir is not empy, will rebuild.";
    md5sum $dir/* | sort -k2 > "checksums/$hashfile.new";
    rebuild="true";
    continue;
  fi
  if [ -f "checksums/$hashfile" ]; then
    #checksum exists, this means we check the dir against it
    #it does not matter if dir is empty or not - we would be checking it anyway
    md5sum $dir/* | sort -k2 > "checksums/$hashfile.new";
    diff "checksums/$hashfile" "checksums/$hashfile.new";
    res=$?;
    if [ "$res" -eq "0" ]; then
      echo "[$0] No changes detected for dir $dir, hashfile $hashfile, moving on.";
      rm -f "checksums/$hashfile.new";
      continue;
    else
      echo "[$0] Changes detected for dir $dir, hashfile $hashfile. Will rebuild CzechIdM application.";
      rebuild="true";
      # there is no point in checking further, but we do not break the loop
      # here because we use it to create all '$hashfile.new' files
    fi
  fi
done

# to rebuild or not to rebuild?
if [ "$rebuild" == "false" ]; then
  echo "[$0] No rebuild necessary.";
  # on the first run, the IdM will not be deployed so we have to check if we need
  # to do a deploy using plain product IdM
  if [ "$(ls -A $TOMCAT_BASE/webapps)x" == "x" ]; then
    echo "[$0] No IdM found deployed in Tomcat, deploying unmodified product CzechIdM...";
    cd "$TOMCAT_BASE/webapps";
    mkdir idm;
    cd idm;
    jar xf "$CZECHIDM_BUILDROOT/product/idm-app-$CZECHIDM_VERSION.war";
  fi
  exit;
fi
echo "[$0] Rebuilding CzechIdM...";
# doing the rebuild here
cd "$CZECHIDM_BUILDROOT/tool" && \
jar xf "$CZECHIDM_BUILDROOT/product/idm-app-$CZECHIDM_VERSION.war" WEB-INF/idm-tool.jar WEB-INF/lib && \
mv WEB-INF/* ./ && \
rmdir WEB-INF && \
sudo -Eu idmbuild java -jar idm-tool.jar -p --build;
res=$?;
if [ "$res" -eq "0" ]; then
  echo "[$0] Build successful, deploying new IdM into Tomcat...";
  rm -rf "$TOMCAT_BASE/webapps/idm" && \
  cd "$TOMCAT_BASE/webapps" && \
  mkdir idm && \
  cd idm;
  jar xf "$CZECHIDM_BUILDROOT/dist/idm.war" && \
  rm -f "$CZECHIDM_BUILDROOT/dist/idm.war";
  # update hashfiles
  cd "$CZECHIDM_BUILDROOT";
  for oname in checksums/*.new; do
    nname=$(echo "$oname" | sed 's/.new$//');
    mv "$oname" "$nname";
  done
else
  echo "[$0] Build failed. Retaining old IdM. Cleaning up the unsuccessful build...";
  rm -f "$CZECHIDM_BUILDROOT/dist/idm.war";
  # clean new hashfiles and retain the old ones
  rm -f checksums/*.new;
fi

# in any case, cleanup the tool/ directory to not consume space
# also clean temporary dirs, there should not be anything important therein
echo "[$0] Cleaning up the IdM Tool directory.";
rm -rf $CZECHIDM_BUILDROOT/tool/*;
rm -rf $CZECHIDM_BUILDROOT/dist/*;
rm -rf $CZECHIDM_BUILDROOT/target/*;

# by default, we get rid of m2 packages
# unless DOCKER_PERSIST_M2_REPO is set
if [ -z "${DOCKER_PERSIST_M2_REPO+x}" ]; then
  echo "[$0] Cleaning up the Maven M2 repo directory.";
  rm -rf $CZECHIDM_BUILDROOT/maven/m2/*;
else
  echo "[$0] Leaving Maven M2 repo directory as is.";
fi

# by default, we get rid of nodejs packages
# unless DOCKER_PERSIST_NODEJS_REPO is set
if [ -z "${DOCKER_PERSIST_NODEJS_REPO+x}" ]; then
  echo "[$0] Cleaning up the NodeJS cache directory and configs.";
  rm -rf $CZECHIDM_BUILDROOT/.node-gyp;
  rm -rf $CZECHIDM_BUILDROOT/.npm;
  rm -f  $CZECHIDM_BUILDROOT/.babel.json;
else
  echo "[$0] Leaving NodeJS cache and config as is.";
fi
