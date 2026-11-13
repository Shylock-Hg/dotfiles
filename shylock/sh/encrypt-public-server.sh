#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/encrypt-backup.sh" "$HOME/Data/headscale.dump.tar.zst" 'E63EE5A890228C2A'
"$SCRIPT_DIR/encrypt-backup.sh" "$HOME/Data/openclash.dump.tar.zst" 'E63EE5A890228C2A'
