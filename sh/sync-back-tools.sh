#! /usr/bin/env bash

FOLDER=Tools; 

mkdir -p ~/Tools

rclone sync gdrive:/$FOLDER $FOLDER --transfers 4
