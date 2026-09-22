#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CERT_DIR="/etc/nginx/ssl"
readonly TRUST_DIR="/etc/ca-certificates/trust-source/anchors"

if (( EUID != 0 )); then
    echo "Run this script as root (for example: sudo $0)." >&2
    exit 1
fi

for file in ca.crt shylockhg.me.crt shylockhg.me.key; do
    if [[ ! -f "$SCRIPT_DIR/$file" ]]; then
        echo "Missing required file: $SCRIPT_DIR/$file" >&2
        exit 1
    fi
done

if ! command -v update-ca-trust >/dev/null 2>&1; then
    echo "update-ca-trust is not installed or is not available in PATH." >&2
    exit 1
fi

install -d -m 0755 "$TRUST_DIR"
install -m 0644 "$SCRIPT_DIR/ca.crt" "$TRUST_DIR/ca.crt"
update-ca-trust

install -d -m 0700 "$CERT_DIR"
install -m 0644 "$SCRIPT_DIR/shylockhg.me.crt" "$CERT_DIR/shylockhg.me.crt"
install -m 0600 "$SCRIPT_DIR/shylockhg.me.key" "$CERT_DIR/shylockhg.me.key"

echo "Installed CA certificate and updated the system trust store."
echo "Installed certificate and key in $CERT_DIR."
