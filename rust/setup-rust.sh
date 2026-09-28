#! /usr/bin/bash

# Setup rust environment with rustup/rust and mirror

set -e
set -o pipefail

# Regional mirrors are faster but not always reachable. Try the configured
# mirror first and fall back to the official rustup server; a single mirror
# can time out (the CachyOS CI job failed this way) and should not fail the
# whole build when another source is available.
#
# Each entry is "<dist server> <update root>".
readonly MIRRORS=(
    "https://mirrors.ustc.edu.cn/rust-static https://mirrors.ustc.edu.cn/rust-static/rustup"
    "https://static.rust-lang.org https://static.rust-lang.org/rustup"
)

install_rustup() {
    local dist_server="$1"
    local update_root="$2"

    export RUSTUP_DIST_SERVER="$dist_server"
    export RUSTUP_UPDATE_ROOT="$update_root"

    # Retry transient network errors while downloading rustup and the
    # toolchain. Re-running the installer is safe: rustup updates in place.
    curl --proto '=https' --tlsv1.2 -sSf \
        --retry 5 --retry-delay 5 --retry-all-errors --connect-timeout 30 \
        https://sh.rustup.rs | sh -s -- -y
}

installed=false
for mirror in "${MIRRORS[@]}"; do
    read -r dist_server update_root <<< "$mirror"
    if install_rustup "$dist_server" "$update_root"; then
        echo "Installed rustup from ${dist_server}."
        installed=true
        break
    fi
    echo "rustup install from ${dist_server} failed; trying the next mirror." >&2
done

if [[ $installed != true ]]; then
    echo "Error: failed to install rustup from any configured mirror." >&2
    exit 1
fi

persist_env() {
    local rc_file="$1"

    [ -f "$rc_file" ] || return 0

    grep -q '^export RUSTUP_UPDATE_ROOT=' "$rc_file" \
        || echo "export RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}" >> "$rc_file"
    grep -q '^export RUSTUP_DIST_SERVER=' "$rc_file" \
        || echo "export RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}" >> "$rc_file"
}

persist_env "$HOME/.zshenv"
persist_env "$HOME/.bashrc"

ln -sf "$(readlink -f .cargo.conf)" "$HOME/.cargo/config"
ln -sf "$HOME/.cargo/config" "$HOME/.cargo/config.toml"

. "$HOME/.cargo/env"

rustup component add rust-analyzer
