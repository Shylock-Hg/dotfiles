#! /usr/bin/env bash

pushd ~/Data

tar -cf bundle.tar gitlab.tar.zst.gpg  shylock.tar.zst.gpg
mkisofs -J -r -V "MY_DATA_BUNDLE" -o bundle.iso bundle.tar

popd
