#! /usr/bin/env bash

rm -f ~/Data/gitlab.tar.zst
gpg2 --encrypt --recipient 'tcath2s@icloud.com' ~/Data/gitlab.tar.zst
