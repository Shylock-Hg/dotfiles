#! /usr/bin/env bash

FOLDER=Documents; 

mkdir -p ~/Tools

rclone sync gdrive:/$FOLDER $FOLDER --transfers 4
