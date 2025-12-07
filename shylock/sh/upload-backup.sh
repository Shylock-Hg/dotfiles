#! /usr/bin/env bash

readonly TARBALL=shylock.tar.zst

rclone sync ~/$TARBALL dropbox:/$TARBALL --transfers 4
