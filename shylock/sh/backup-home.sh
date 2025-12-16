#! /usr/bin/env bash

pushd ~

tar --zst -cf ~/Data/shylock.tar.zst Tools Documents Pictures Videos Music
rm -f ~/Data/shylock.tar.zst.gpg
gpg2 --encrypt --recipient 'tcath2s@icloud.com' ~/Data/shylock.tar.zst

popd
