#! /usr/bin/env bash

FOLDER=Workspace/TigerC; while inotifywait -r -e modify,create,delete $FOLDER; do sleep 300; rclone --exclude='target/' sync $FOLDER dropbox:/$FOLDER --transfers 4; done
