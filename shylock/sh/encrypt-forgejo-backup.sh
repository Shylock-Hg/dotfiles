#! /usr/bin/env bash

rm -f ~/Data/forgejo.tar.zst.gpg
gpg2 --encrypt --recipient 'E63EE5A890228C2A' ~/Data/forgejo.tar.zst
