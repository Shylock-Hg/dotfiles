#!/usr/bin/env bash
set -euo pipefail

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/encrypt-backup.sh" "$HOME/Data/forgejo.tar.zst" 'E63EE5A890228C2A'
