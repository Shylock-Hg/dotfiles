#! /usr/bin/bash

# Setup rust environment with rustup/rust and mirror

set -e

export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

if [ -f '~/.zshenv' ]; then
    echo "export RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}" >> ~/.zshenv
    echo "export RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}" >>  ~/.zshenv
fi



if [ -f '~/.bashrc' ]; then
    echo "export RUSTUP_UPDATE_ROOT=${RUSTUP_UPDATE_ROOT}" >> ~/.bashrc
    echo "export RUSTUP_DIST_SERVER=${RUSTUP_DIST_SERVER}" >>  ~/.bashrc
fi

ln -sf $(readlink -f .cargo.conf)  ~/.cargo/config
ln -sf ~/.cargo/config ~/.cargo/config.toml

 . "$HOME/.cargo/env"

rustup component add rust-analyzer
