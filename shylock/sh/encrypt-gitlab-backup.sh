#! /usr/bin/env bash

rm -f ~/Data/gitlab.tar.zst.gpg
gpg2 --encrypt --recipient 'E63EE5A890228C2A' ~/Data/gitlab.tar.zst
