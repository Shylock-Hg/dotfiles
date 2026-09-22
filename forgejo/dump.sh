#! /usr/bin/env bash
#
# Dump the whole Forgejo instance (database, repositories, LFS, attachments,
# packages, config, custom files, ...) to ~/Data/forgejo.tar.zst.
#
# The archive is produced by `forgejo dump`, the official format intended for
# backup/migration. To restore, extract it over the target instance's work-path
# and custom-path, then run `forgejo migrate` / `forgejo doctor` as needed.
#
# Usage: ./dump.sh [output-file]

set -euo pipefail

readonly DEST="${1:-$HOME/Data/forgejo.tar.zst}"
readonly WORK_PATH=/var/lib/forgejo
readonly CONFIG=/etc/forgejo/app.ini

mkdir -p "$(dirname "$DEST")"

# forgejo dump must run as the forgejo user. Use a throwaway directory that the
# user can write to, then move the result into place.
tmpdir="$(mktemp -d /var/tmp/forgejo-dump.XXXXXX)"
trap 'sudo rm -rf "$tmpdir"' EXIT
sudo chown forgejo:forgejo "$tmpdir"

sudo -u forgejo forgejo dump \
    -w "$WORK_PATH" \
    -c "$CONFIG" \
    --type tar.zst \
    --file "$tmpdir/forgejo.tar.zst"

sudo mv "$tmpdir/forgejo.tar.zst" "$DEST"
sudo chown "$(id -u):$(id -g)" "$DEST"

echo "Wrote $DEST"
