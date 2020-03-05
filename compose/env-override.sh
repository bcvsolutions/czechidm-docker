# BEWARE
# This is really nonstandard approach which lets you do funky things.
# The correct way to change ENV variables is to destroy the container
# and create a new one.
#
# This file is sourced before anything happens in the container.
# You can use it to override/set some env variables upon "docker-compose start".
# This overrides default behavior of docker-compose where variables have values
# from the time the "docker-compose up" was called.
# Any number of files can be hooked into run.d/ directory, it works as standard .d/
# directory you know from Linux.
#
# Hook it up to the compose file like this:
# volumes:
#      - ./env-override.sh:/runscripts/run.d/env-override.sh:ro
#
# Example of timezone override upon each start of the container.
# It is simply a sourced bash script.
#
# export TZ=Europe/Prague
# echo "[$0] OVERRIDE - Just exported new tz: $TZ"
