#!/usr/bin/env bash
# Usage: backup-home.sh [source-directory [backup-directory]]
set -euo pipefail
umask 077

if (( $# > 2 )); then
    echo "Usage: $0 [source-directory [backup-directory]]" >&2
    exit 2
fi
readonly SOURCE_DIR="${1:-$HOME}"
readonly BACKUP_DIR="${2:-$HOME/Data}"
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p -- "$BACKUP_DIR"
WORK_DIR=$(mktemp -d "$BACKUP_DIR/.home-backup.XXXXXX")
trap 'rm -rf -- "$WORK_DIR"' EXIT

tar --zst -cf "$WORK_DIR/shylock.tar.zst" -C "$SOURCE_DIR" Tools Documents Pictures Videos Music
"$SCRIPT_DIR/encrypt-backup.sh" "$WORK_DIR/shylock.tar.zst" 'tcath2s@icloud.com'
# Both stages must succeed before either previous backup is replaced.
mv -f -- "$WORK_DIR/shylock.tar.zst" "$BACKUP_DIR/shylock.tar.zst"
mv -f -- "$WORK_DIR/shylock.tar.zst.gpg" "$BACKUP_DIR/shylock.tar.zst.gpg"
