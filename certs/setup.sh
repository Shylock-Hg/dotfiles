#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CERT_DIR="/etc/nginx/ssl"

if (( EUID != 0 )); then
    echo "Run this script as root (for example: sudo $0)." >&2
    exit 1
fi

for file in shylockhg.me.crt shylockhg.me.key; do
    if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
        echo "Missing required file: $SCRIPT_DIR/$file" >&2
        exit 1
    fi
done

install -d -m 0700 "$CERT_DIR"
install -m 0644 "$SCRIPT_DIR/shylockhg.me.crt" "$CERT_DIR/shylockhg.me.crt"
install -m 0600 "$SCRIPT_DIR/shylockhg.me.key" "$CERT_DIR/shylockhg.me.key"

echo "Installed certificate and key in $CERT_DIR."
