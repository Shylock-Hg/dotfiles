#! /usr/bin/env bash

FOLDER=Tools; while inotifywait -r -e modify,create,delete $FOLDER; do rclone sync $FOLDER gdrive:/$FOLDER --transfers 4; sleep 300; done

