#! /usr/bin/env bash

FOLDER=Workspace/cpa; while inotifywait -r -e modify,create,delete $FOLDER; do rclone sync --exclude build/ --exclude .cache/ $FOLDER dropbox:/$FOLDER --transfers 4; sleep 300; done

