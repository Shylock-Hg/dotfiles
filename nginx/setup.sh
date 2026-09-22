#!/usr/bin/env bash

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly SOURCE_CONFIG="$SCRIPT_DIR/forgejo.conf"
readonly NGINX_CONFIG="/etc/nginx/nginx.conf"
readonly CONFIG_DIR="/etc/nginx/conf.d"
readonly TARGET_CONFIG="$CONFIG_DIR/forgejo.conf"
readonly INCLUDE_DIRECTIVE='    include /etc/nginx/conf.d/*.conf;'

in_docker() {
    # Container engines advertise themselves in the cgroup hierarchy (cgroup v1)
    # or use the unified "0::/" root (cgroup v2).
    if [ -f /proc/1/cgroup ]; then
        if grep -qE "(docker|lxc|containerd|kubepods)" /proc/1/cgroup \
            || grep -qE "^0::/$" /proc/1/cgroup; then
            return 0
        fi
    fi

    # CI runners (GitHub/Forgejo/Gitea Actions, etc.) set these variables.
    if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
        return 0
    fi

    return 1
}

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

if in_docker; then
    echo "Skipping nginx configuration test in container/CI." >&2
else
    nginx -t
fi

echo "Installed $TARGET_CONFIG."
echo "Reload nginx to apply it: systemctl reload nginx"
