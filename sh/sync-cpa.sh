#! /usr/bin/env bash

FOLDER=Workspace/cpa; while inotifywait -r -e modify,create,delete $FOLDER; do sleep 300; rclone sync --exclude build/ --exclude .cache/ $FOLDER dropbox:/$FOLDER --transfers 4; done

