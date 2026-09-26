#!/usr/bin/env bash

set -euo pipefail

readonly RELEASE_URL=https://github.com/AgentaaU/AaaU/releases/latest/download/aaau-linux.tar.gz
readonly WORK_DIR="$(mktemp -d)"
trap 'rm -rf -- "$WORK_DIR"' EXIT

curl -fL --retry 3 --output "$WORK_DIR/aaau-linux.tar.gz" "$RELEASE_URL"
tar -xzf "$WORK_DIR/aaau-linux.tar.gz" -C "$WORK_DIR" \
    aaau aaau-server aaau-editor

for binary in aaau aaau-server aaau-editor; do
    sudo install -m 0755 "$WORK_DIR/$binary" "/usr/local/bin/$binary"
done
