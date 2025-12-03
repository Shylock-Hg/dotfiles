#! /usr/bin/env bash

readonly SCRIPT_DIR=$(dirname $0)

pushd $SCRIPT_DIR

gpg2 --import ./myprikeys.asc
gpg2 --import ./mypubkeys.asc
gpg2 -K
gpg2 -k

gpg2 --import-ownertrust ./otrust.txt

popd
