#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_CONFIG="$SCRIPT_DIR/forgejo.conf"
readonly NGINX_CONFIG="/etc/nginx/nginx.conf"
readonly CONFIG_DIR="/etc/nginx/conf.d"
readonly TARGET_CONFIG="$CONFIG_DIR/forgejo.conf"
readonly INCLUDE_DIRECTIVE='    include /etc/nginx/conf.d/*.conf;'

if (( EUID != 0 )); then
    echo "Run this script as root (for example: sudo $0)." >&2
    exit 1
fi

for file in "$SOURCE_CONFIG" "$NGINX_CONFIG"; do
    if [[ ! -f "$file" ]]; then
        echo "Missing required file: $file" >&2
        exit 1
    fi
done

if ! command -v nginx >/dev/null 2>&1; then
    echo "nginx is not installed or is not available in PATH." >&2
    exit 1
fi

if ! grep -Eq '^[[:space:]]*include[[:space:]]+(/etc/nginx/)?conf\.d/\*\.conf;' "$NGINX_CONFIG" \
    && ! grep -Eq '^[[:space:]]*http[[:space:]]*\{' "$NGINX_CONFIG"; then
    echo "Could not find the http block in $NGINX_CONFIG." >&2
    exit 1
fi

install -d -m 0755 "$CONFIG_DIR"
install -m 0644 "$SOURCE_CONFIG" "$TARGET_CONFIG"

if ! grep -Eq '^[[:space:]]*include[[:space:]]+(/etc/nginx/)?conf\.d/\*\.conf;' "$NGINX_CONFIG"; then
    cp --preserve=mode,ownership,timestamps \
        "$NGINX_CONFIG" "$NGINX_CONFIG.pre-forgejo"
    sed -i "/^[[:space:]]*http[[:space:]]*{/a\\$INCLUDE_DIRECTIVE" "$NGINX_CONFIG"
fi

nginx -t

echo "Installed $TARGET_CONFIG."
echo "Reload nginx to apply it: systemctl reload nginx"
