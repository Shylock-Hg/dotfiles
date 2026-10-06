#! /usr/bin/env bash

rm -f ~/Data/headscale.dump.tar.zst.gpg
gpg2 --encrypt --recipient 'E63EE5A890228C2A' ~/Data/headscale.dump.tar.zst

rm -f ~/Data/openclash.dump.tar.zst.gpg
gpg2 --encrypt --recipient 'E63EE5A890228C2A' ~/Data/openclash.dump.tar.zst
