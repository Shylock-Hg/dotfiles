#! /usr/bin/env bash

readonly INPUT_FILE="$1"
readonly OFILE=${INPUT_FILE%.*}

base64 -d $1 > $OFILE
chmod 600 $OFILE
