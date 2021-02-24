#!/bin/bash
echo "[$0] Fixing privileges and ownership on (mounted) directories...";

chown tomcat:tomcat "$CZECHIDM_CONFIG/backup"
chmod u+rwx "$CZECHIDM_CONFIG/backup"

chown tomcat:tomcat "$CZECHIDM_CONFIG/data"
chmod u+rwx "$CZECHIDM_CONFIG/data"