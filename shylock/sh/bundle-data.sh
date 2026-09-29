#! /usr/bin/env bash

set -ex

readonly SCRIPT_DIR=$(dirname $0)
$SCRIPT_DIR/../../forgejo/dump.sh
$SCRIPT_DIR/encrypt-forgejo-backup.sh
$SCRIPT_DIR/encrypt-public-server.sh
$SCRIPT_DIR/backup-home.sh
#$SCRIPT_DIR/backup-elpa-mirror.sh

cp -r $SCRIPT_DIR/../../gpg ~/Data

pushd ~/Data

tar -cf bundle.tar forgejo.tar.zst.gpg  shylock.tar.zst.gpg headscale.dump.tar.zst.gpg openclash.dump.tar.zst.gpg #elpa-mirror-*
mkisofs -J -r -V "MY_DATA_BUNDLE" -o bundle.iso bundle.tar gpg

# cleanup
rm -rf ./gitlab.* ./shylock.* ./gpg ./forgejo.* headscale.dump.tar.zst openclash.dump.tar.zst #elpa-mirror-*

popd
