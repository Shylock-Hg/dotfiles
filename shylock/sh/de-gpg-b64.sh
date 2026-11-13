#!/usr/bin/env bash
set -euo pipefail
umask 077

if [[ $# != 1 || $1 != *.gpg.b64 ]]; then
    echo "Usage: $0 file.gpg.b64" >&2
    exit 2
fi
readonly INPUT_FILE="$1"
readonly OFILE="${INPUT_FILE%.gpg.b64}"
WORK_DIR=$(mktemp -d "${OFILE}.decrypt.XXXXXX")
trap 'rm -rf -- "$WORK_DIR"' EXIT

base64 -d -- "$INPUT_FILE" > "$WORK_DIR/input.gpg"
gpg2 --decrypt "$WORK_DIR/input.gpg" > "$WORK_DIR/plaintext"
chmod 600 "$WORK_DIR/plaintext"
mv -f -- "$WORK_DIR/plaintext" "$OFILE"
