#! /usr/bin/env sh

###############################################################################
# deploy docker image to docker hub
###############################################################################

docker build -t $DOCKER_USERNAME/$REPO docker/dev
