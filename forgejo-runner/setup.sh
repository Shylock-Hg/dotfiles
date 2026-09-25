#! /usr/bin/env bash
#
# Install the Forgejo Actions runner configuration and its systemd drop-in.
#
# The registration token is handed to the runner as a systemd credential
# (LoadCredential) so it is never stored in config.yaml or exposed through the
# process arguments. The registration data is taken from, in order:
#   * FORGEJO_RUNNER_UUID / FORGEJO_RUNNER_TOKEN environment variables
#   * ./uuid and ./token files next to this script (gitignored)
#   * the files already installed under /etc/forgejo-runner
#   * an interactive prompt
#
# Usage:
#   sudo FORGEJO_RUNNER_UUID=... FORGEJO_RUNNER_TOKEN=... ./setup.sh
#   sudo ./setup.sh
#
# Note: like gitlab-runner, this is intentionally NOT wired into the top-level
# dotfiles/setup.sh because it needs per-machine registration secrets.

set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_SRC="$SCRIPT_DIR/config.yaml"
readonly DROPIN_SRC="$SCRIPT_DIR/forgejo-runner.service.d/override.conf"
readonly CONFIG_DIR=/etc/forgejo-runner
readonly CONFIG_DST="$CONFIG_DIR/config.yaml"
readonly TOKEN_DST="$CONFIG_DIR/token"
readonly DROPIN_DIR=/etc/systemd/system/forgejo-runner.service.d
readonly DROPIN_DST="$DROPIN_DIR/override.conf"
readonly RUNNER_GROUP=forgejo-runner

if (( EUID != 0 )); then
    echo "Run this script as root (for example: sudo $0)." >&2
    exit 1
fi

for file in "$CONFIG_SRC" "$DROPIN_SRC"; do
    if [[ ! -f "$file" ]]; then
        echo "Missing required file: $file" >&2
        exit 1
    fi
done

if ! command -v forgejo-runner >/dev/null 2>&1; then
    echo "forgejo-runner is not installed or is not available in PATH." >&2
    exit 1
fi

if ! getent group "$RUNNER_GROUP" >/dev/null; then
    echo "Group '$RUNNER_GROUP' does not exist; install the forgejo-runner package first." >&2
    exit 1
fi

# --- registration data -------------------------------------------------------

uuid="${FORGEJO_RUNNER_UUID:-}"
if [[ -z "$uuid" && -f "$SCRIPT_DIR/uuid" ]]; then
    uuid="$(<"$SCRIPT_DIR/uuid")"
fi
if [[ -z "$uuid" && -f "$CONFIG_DST" ]]; then
    uuid="$(sed -n 's/^[[:space:]]*uuid:[[:space:]]*//p' "$CONFIG_DST" | head -n1)"
fi
if [[ -z "$uuid" && -t 0 ]]; then
    read -rp "Runner UUID (Forgejo: Site Administration -> Actions -> Runners): " uuid
fi
if [[ -z "$uuid" || "$uuid" == "__RUNNER_UUID__" ]]; then
    echo "A runner UUID is required (set FORGEJO_RUNNER_UUID or create ./uuid)." >&2
    exit 1
fi

token="${FORGEJO_RUNNER_TOKEN:-}"
if [[ -z "$token" && -f "$SCRIPT_DIR/token" ]]; then
    token="$(<"$SCRIPT_DIR/token")"
fi
if [[ -z "$token" && -f "$TOKEN_DST" ]]; then
    echo "Reusing existing token in $TOKEN_DST."
    token="$(<"$TOKEN_DST")"
fi
if [[ -z "$token" && -t 0 ]]; then
    read -rsp "Runner registration token: " token
    echo
fi
if [[ -z "$token" ]]; then
    echo "A runner token is required (set FORGEJO_RUNNER_TOKEN or create ./token)." >&2
    exit 1
fi

# --- install configuration ---------------------------------------------------

install -d -m 0750 -o root -g "$RUNNER_GROUP" "$CONFIG_DIR"

# config.yaml is readable by the runner user only.
tmp_config="$(mktemp)"
trap 'rm -f "$tmp_config"' EXIT
sed "s|__RUNNER_UUID__|${uuid}|g" "$CONFIG_SRC" > "$tmp_config"
install -o root -g "$RUNNER_GROUP" -m 0640 "$tmp_config" "$CONFIG_DST"

# The token is read by systemd as root and injected as a credential, so neither
# the runner user nor anyone else needs direct access to it.
umask 077
printf '%s\n' "$token" > "$TOKEN_DST"
chown root:root "$TOKEN_DST"
chmod 0600 "$TOKEN_DST"

install -d -m 0755 "$DROPIN_DIR"
install -m 0644 "$DROPIN_SRC" "$DROPIN_DST"

# --- done --------------------------------------------------------------------

echo "Installed $CONFIG_DST and $DROPIN_DST."
echo
echo "The service was not started. Apply it with:"
echo "    sudo systemctl daemon-reload"
echo "    sudo systemctl enable --now forgejo-runner.service"
