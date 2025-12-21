#! /usr/bin/env bash

gpg2 --encrypt --recipient 'tcath2s@icloud.com' $1
base64 $1.gpg > $1.gpg.b64

rm $1.gpg
