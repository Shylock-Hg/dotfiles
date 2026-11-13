#!/usr/bin/env bash
# Encrypt one archive, preserving the previous backup until GPG succeeds.
# Usage: encrypt-backup.sh archive recipient
set -euo pipefail
umask 077

if [[ $# != 2 ]]; then
    echo "Usage: $0 archive recipient" >&2
    exit 2
fi
readonly ARCHIVE="$1"
readonly RECIPIENT="$2"
WORK_DIR=$(mktemp -d "${ARCHIVE}.encrypt.XXXXXX")
trap 'rm -rf -- "$WORK_DIR"' EXIT

gpg2 --encrypt --recipient "$RECIPIENT" --output "$WORK_DIR/backup.gpg" -- "$ARCHIVE"
mv -f -- "$WORK_DIR/backup.gpg" "${ARCHIVE}.gpg"
