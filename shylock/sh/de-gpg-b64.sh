#! /usr/bin/env bash

readonly INPUT_FILE="$1"
readonly GPG_FILE=${INPUT_FILE%.*}
readonly OFILE=${GPG_FILE%.*}

base64 -d $1 > $GPG_FILE
gpg2 --decrypt $GPG_FILE > $OFILE
chmod 600 $OFILE

rm $GPG_FILE
