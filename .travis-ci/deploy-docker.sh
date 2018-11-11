#! /usr/bin/env sh

if echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin; then
	docker push $DOCKER_USERNAME/$REPO
fi

