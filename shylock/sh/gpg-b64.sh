#! /usr/bin/env bash

gpg2 --encrypt --recipient 'E63EE5A890228C2A' $1
base64 $1.gpg > $1.gpg.b64

rm $1.gpg
