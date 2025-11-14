#! /usr/bin/env bash


FOLDER=Documents; while inotifywait -r -e modify,create,delete $FOLDER; do sleep 300; rclone sync $FOLDER gdrive:/$FOLDER  --transfers 4; done
