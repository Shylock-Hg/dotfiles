#! /usr/bin/env bash
#
# Dump the whole Forgejo instance (database, repositories, LFS, attachments,
# packages, config, custom files, ...) to ~/Data/forgejo.tar.zst.
#
# The archive is produced by `forgejo dump`, the official format intended for
# backup/migration. To restore, extract it over the target instance's work-path
# and custom-path, then run `forgejo migrate` / `forgejo doctor` as needed.
#
# The Forgejo service is stopped for the duration of the dump so the database
# and repositories are not modified while they are being copied, and started
# again afterwards (only if it was running before).
#
# Usage: ./dump.sh [output-file]

set -euo pipefail

readonly DEST="${1:-$HOME/Data/forgejo.tar.zst}"
readonly WORK_PATH=/var/lib/forgejo
readonly CONFIG=/etc/forgejo/app.ini
readonly SERVICE=forgejo.service

mkdir -p "$(dirname "$DEST")"

# forgejo dump must run as the forgejo user. Use a throwaway directory that the
# user can write to, then move the result into place.
tmpdir="$(mktemp -d /var/tmp/forgejo-dump.XXXXXX)"

# Make sure the service is restarted and the temporary directory removed even
# if the dump fails. The previous state is remembered so an instance that was
# already stopped is left stopped.
was_running=false
cleanup() {
    if [[ "$was_running" == true ]]; then
        sudo systemctl start "$SERVICE"
    fi
    sudo rm -rf "$tmpdir"
}
trap cleanup EXIT

if systemctl is-active --quiet "$SERVICE"; then
    was_running=true
    sudo systemctl stop "$SERVICE"
fi

sudo chown forgejo:forgejo "$tmpdir"

sudo -u forgejo forgejo dump \
    -w "$WORK_PATH" \
    -c "$CONFIG" \
    --type tar.zst \
    --file "$tmpdir/forgejo.tar.zst"

sudo mv "$tmpdir/forgejo.tar.zst" "$DEST"
sudo chown "$(id -u):$(id -g)" "$DEST"

echo "Wrote $DEST"
