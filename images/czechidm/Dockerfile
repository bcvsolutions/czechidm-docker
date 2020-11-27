FROM bcv-tomcat:8.5.60-r0

ENV MAVEN_MAJOR 3
ENV MAVEN_VERSION 3.6.3
ENV MAVEN_HOME /idmbuild/maven/current

ENV CZECHIDM_VERSION 10.6.3
ENV CZECHIDM_BUILDROOT /idmbuild
# convenience for our image
ENV TOMCAT_BASE /opt/tomcat/current
ENV CZECHIDM_CONFIG /opt/czechidm

# install sw and link it where necessary
RUN yum install -y xmlstarlet openssl dos2unix which && \
		yum clean all

# get new postgres driver
# checksum & grep is a poor-man's integrity/signature verification
RUN	wget https://jdbc.postgresql.org/download/postgresql-42.2.11.jar -P $TOMCAT_BASE/lib/ && \
		sha256sum $TOMCAT_BASE/lib/postgresql-42.2.11.jar | grep -q 31e9f3dc586c07477235893279ee80036de377681badaa1f27db6b74ab2437f4

# harden tomcat config and clean tomcat-bundled webapps
RUN cd $TOMCAT_BASE/conf && \
		xmlstarlet ed -L \
		-u "/Server[@port='8005' and @shutdown='SHUTDOWN']/@port" -v "-1" \
		-a "//Connector[@port='8080']" -t attr -n maxSwallowSize -v "-1" \
		server.xml && \
		\
		xmlstarlet ed -L -N ns="http://xmlns.jcp.org/xml/ns/javaee" \
		-u "//ns:servlet/ns:servlet-name[text()='default']/../ns:init-param/ns:param-name[text()='showServerInfo']/../ns:param-value/text()" -v "false" \
		web.xml && \
		\
		rm -rf $TOMCAT_BASE/webapps/{examples,docs,ROOT,host-manager,manager} && \
		chown root:root -v $TOMCAT_BASE/webapps

# create directory structure for idmtool and build IdM;
# checksums/ directory is used internally by the container to store module's checksums so we know when to rebuild idm.war;
# also download, install and set up maven
RUN groupadd -r idmbuild && \
		useradd -r -s /sbin/nologin -g idmbuild -d "$CZECHIDM_BUILDROOT" idmbuild && \
		mkdir -pv $CZECHIDM_BUILDROOT/{product,modules,dist,tool,frontend/config,frontend/czechidm-modules,target,trustcert,checksums,maven} && \
		chmod -v o-rwx "$CZECHIDM_BUILDROOT" && \
		chown -Rfv idmbuild:idmbuild "$CZECHIDM_BUILDROOT" && \
		\
# The ddist() function is copied from
# https://github.com/docker-library/tomcat/blob/807a2b4f219d70f5ba6f4773d4ee4ee155850b0d/8.5/jdk8/openjdk/Dockerfile
# and stripped off PGP check. The ddist() code is under Apache License 2.0.
		ddist() { \
		local f="$1"; shift; \
		local distFile="$1"; shift; \
		local success=; \
		local distUrl=; \
		for distUrl in \
			'https://www.apache.org/dyn/closer.cgi?action=download&filename=' \
			https://www-us.apache.org/dist/ \
			https://www.apache.org/dist/ \
			https://archive.apache.org/dist/ \
		; do \
				if wget -O "$f" "$distUrl$distFile" && [ -s "$f" ]; then \
					success=1; \
					break; \
				fi; \
			done; \
			[ -n "$success" ]; \
		}; \
		\
		ddist "$CZECHIDM_BUILDROOT/maven/apache-maven-$MAVEN_VERSION-bin.tar.gz" "maven/maven-$MAVEN_MAJOR/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz"; \
		\
		cd "$CZECHIDM_BUILDROOT/maven" && \
		tar xzvf "apache-maven-$MAVEN_VERSION-bin.tar.gz" && \
		ln -s apache-maven-$MAVEN_VERSION current && \
# do maven configuration here - local m2 repo and disable interactive mode
		xmlstarlet ed -L -N ns="http://maven.apache.org/SETTINGS/1.0.0" \
			-s "/ns:settings" -t elem -n "localRepository" -v "$CZECHIDM_BUILDROOT/maven/m2" \
			-s "/ns:settings" -t elem -n "interactiveMode" -v "false" \
			"$MAVEN_HOME/conf/settings.xml";

# We just copy the war into the container here. We do not extract the idm-tool,
# because it also needs whole lib/ with it - that would make more than 100MB of
# dead weight.
COPY "dropin/idm-app-$CZECHIDM_VERSION.war" "dropin/application-docker.TPL.properties" "$CZECHIDM_BUILDROOT/product/"

# finally, copy over the runscripts; this adds our runscripts to the Tomcat baseimage
COPY runscripts "$RUNSCRIPTS_PATH/"
RUN find "$RUNSCRIPTS_PATH/" -name "*.sh" -exec chmod -v u+x {} \;

# create CzechIdM config & data structures
RUN mkdir -pv $CZECHIDM_CONFIG/{etc,lib,backup,data} && \
		chmod -v 750 $CZECHIDM_CONFIG && \
		chgrp -Rv tomcat $CZECHIDM_CONFIG && \
		chown -v tomcat $CZECHIDM_CONFIG/{backup,data}

CMD ["/bin/bash","-c","$RUNSCRIPTS_PATH/run.sh"]

EXPOSE 8009/tcp
EXPOSE 8080/tcp

# For volumes documentation, see README.md.
