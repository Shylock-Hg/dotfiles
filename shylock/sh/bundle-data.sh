#! /usr/bin/env bash

set -ex

readonly SCRIPT_DIR=$(dirname $0)

$SCRIPT_DIR/encrypt-gitlab-backup.sh
$SCRIPT_DIR/backup-home.sh

cp -r $SCRIPT_DIR/../../gpg ~/Data

pushd ~/Data

tar -cf bundle.tar gitlab.tar.zst.gpg  shylock.tar.zst.gpg elpa-mirror-*
mkisofs -J -r -V "MY_DATA_BUNDLE" -o bundle.iso bundle.tar gpg

# cleanup
rm -rf ./gitlab.* ./shylock.* ./gpg

popd
