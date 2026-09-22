#!/usr/bin/env bash
#
# install.sh - configure the Forgejo server and Actions runner under a dedicated
#              `forgejo` user/group, using the systemd units in this directory.
#
# Configuration and systemd units only: this script does NOT install the
# forgejo / forgejo-runner binaries and does NOT enable or start the services.
#
# Usage:
#   sudo ./install.sh
#
# All settings can be overridden via environment variables, e.g.:
#   sudo FORGEJO_URL=https://git.example.com RUNNER_TOKEN=xxxx ./install.sh
#
set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
BIN_DIR="${BIN_DIR:-/usr/local/bin}"
FORGEJO_HOME="${FORGEJO_HOME:-/var/lib/forgejo}"
RUNNER_HOME="${RUNNER_HOME:-/var/lib/forgejo-runner}"
CONFIG_DIR="${CONFIG_DIR:-/etc/forgejo}"
APP_INI="${APP_INI:-${CONFIG_DIR}/app.ini}"
RUNNER_CONFIG="${RUNNER_CONFIG:-${CONFIG_DIR}/runner/config.yml}"

# Server basics used when a fresh app.ini is generated.
FORGEJO_DOMAIN="${FORGEJO_DOMAIN:-$(hostname)}"
FORGEJO_HTTP_PORT="${FORGEJO_HTTP_PORT:-3000}"
FORGEJO_SSH_PORT="${FORGEJO_SSH_PORT:-222}"

# Actions runner registration. Leave FORGEJO_URL / RUNNER_TOKEN empty to skip
# registration and do it later by hand (the runner unit stays inactive until
# the .runner file exists).
FORGEJO_URL="${FORGEJO_URL:-}"
RUNNER_TOKEN="${RUNNER_TOKEN:-}"
RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
RUNNER_LABELS="${RUNNER_LABELS:-docker:docker://node:20-bookworm}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31mERROR:\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'

install.sh - configure the Forgejo server and Actions runner under a dedicated
             `forgejo` user/group, using the systemd units in this directory.

Configuration and systemd units only: this script does NOT install the
forgejo / forgejo-runner binaries and does NOT enable or start the services.

Usage:
  sudo ./install.sh

All settings can be overridden via environment variables, e.g.:
  sudo FORGEJO_URL=https://git.example.com RUNNER_TOKEN=xxxx ./install.sh
EOF
  exit 0
}
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then usage; fi
[[ $EUID -eq 0 ]] || die "must be run as root (try: sudo $0)"

# ---------------------------------------------------------------------------
# 1. Preflight: binaries must already be installed
# ---------------------------------------------------------------------------
require_binaries() {
  local bin
  for bin in "${BIN_DIR}/forgejo" "${BIN_DIR}/forgejo-runner"; do
    [[ -x "$bin" ]] || die "missing executable: ${bin} (install the binaries first; this script does not)"
  done
}

# ---------------------------------------------------------------------------
# 2. Dedicated user/group + directories
# ---------------------------------------------------------------------------
install_user_and_dirs() {
  log "Creating the forgejo user/group and data directories"
  install -m 0644 "${SCRIPT_DIR}/forgejo.sysusers" /usr/lib/sysusers.d/forgejo.conf
  install -m 0644 "${SCRIPT_DIR}/forgejo.tmpfiles" /usr/lib/tmpfiles.d/forgejo.conf
  systemd-sysusers /usr/lib/sysusers.d/forgejo.conf
  systemd-tmpfiles --create /usr/lib/tmpfiles.d/forgejo.conf
}

# ---------------------------------------------------------------------------
# 3. systemd units
# ---------------------------------------------------------------------------
install_units() {
  log "Installing systemd units"
  install -m 0644 "${SCRIPT_DIR}/forgejo.service"        /etc/systemd/system/forgejo.service
  install -m 0644 "${SCRIPT_DIR}/forgejo-runner.service" /etc/systemd/system/forgejo-runner.service
  systemctl daemon-reload
}

# ---------------------------------------------------------------------------
# 4. Server config
# ---------------------------------------------------------------------------
install_app_ini() {
  if [[ -e "$APP_INI" ]]; then
    log "Keeping existing ${APP_INI}"
    return
  fi
  log "Generating ${APP_INI} (review it afterwards!)"
  local secret internal
  secret="$(runuser -u forgejo -H -- "${BIN_DIR}/forgejo" generate secret SECRET_KEY)"
  internal="$(runuser -u forgejo -H -- "${BIN_DIR}/forgejo" generate secret INTERNAL_TOKEN)"

  cat >"$APP_INI" <<EOF
[server]
DOMAIN           = ${FORGEJO_DOMAIN}
ROOT_URL         = http://${FORGEJO_DOMAIN}:${FORGEJO_HTTP_PORT}/
HTTP_PORT        = ${FORGEJO_HTTP_PORT}
SSH_PORT         = ${FORGEJO_SSH_PORT}
DISABLE_SSH      = false
LFS_START_SERVER = true

[database]
DB_TYPE = sqlite3
PATH    = ${FORGEJO_HOME}/data/forgejo.db

[repository]
ROOT = ${FORGEJO_HOME}/repositories

[lfs]
PATH = ${FORGEJO_HOME}/lfs

[log]
ROOT_PATH = ${FORGEJO_HOME}/log

[security]
SECRET_KEY     = ${secret}
INTERNAL_TOKEN = ${internal}
EOF

  chown root:forgejo "$APP_INI"
  chmod 0640 "$APP_INI"
}

# ---------------------------------------------------------------------------
# 5. Runner config + registration
# ---------------------------------------------------------------------------
install_runner_config() {
  if [[ -e "$RUNNER_CONFIG" ]]; then
    log "Keeping existing ${RUNNER_CONFIG}"
    return
  fi
  log "Generating ${RUNNER_CONFIG}"
  "${BIN_DIR}/forgejo-runner" generate-config >"$RUNNER_CONFIG"
  chown root:forgejo "$RUNNER_CONFIG"
  chmod 0640 "$RUNNER_CONFIG"
}

register_runner() {
  if [[ -e "${RUNNER_HOME}/.runner" ]]; then
    log "Runner already registered; skipping (${RUNNER_HOME}/.runner)"
    return
  fi
  if [[ -z "$FORGEJO_URL" || -z "$RUNNER_TOKEN" ]]; then
    warn "FORGEJO_URL and/or RUNNER_TOKEN not set - skipping runner registration."
    warn "Register later with:"
    warn "  sudo -u forgejo -H bash -c 'cd ${RUNNER_HOME} && \\"
    warn "    ${BIN_DIR}/forgejo-runner register --config ${RUNNER_CONFIG} \\"
    warn "      --instance <URL> --token <TOKEN> --name ${RUNNER_NAME} --labels ${RUNNER_LABELS}'"
    return
  fi
  log "Registering runner '${RUNNER_NAME}' with ${FORGEJO_URL}"

  local -a extra=()
  if "${BIN_DIR}/forgejo-runner" register --help 2>&1 | grep -q -- '--no-interactive'; then
    extra+=(--no-interactive)
  fi

  runuser -u forgejo -H -- bash -c \
    "cd '${RUNNER_HOME}' && '${BIN_DIR}/forgejo-runner' register \
       --config '${RUNNER_CONFIG}' \
       --instance '${FORGEJO_URL}' \
       --token '${RUNNER_TOKEN}' \
       --name '${RUNNER_NAME}' \
       --labels '${RUNNER_LABELS}' ${extra[*]:-}"
}

# ---------------------------------------------------------------------------
main() {
  require_binaries
  install_user_and_dirs
  install_units
  install_app_ini
  install_runner_config
  register_runner
  log "Done. Review ${APP_INI}, then enable the services when ready:"
  log "  systemctl enable --now forgejo.service forgejo-runner.service"
}
main "$@"
