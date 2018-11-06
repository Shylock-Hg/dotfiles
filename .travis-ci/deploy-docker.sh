#! /usr/bin/env sh

if echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin; then
#        docker push $DOCKER_USERNAME/$REPO
        docker push $DOCKER_USERNAME/blog
fi

