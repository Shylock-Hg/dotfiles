#! /usr/bin/env bash

FOLDER=Workspace/TigerC; while inotifywait -r -e modify,create,delete $FOLDER; do rclone --exclude='target/' sync $FOLDER dropbox:/$FOLDER --transfers 4; sleep 300; done
