#! /usr/bin/env bash

readonly TARBALL=bundle.tar

rclone sync ~/Data/$TARBALL dropbox:/$TARBALL --transfers 4
