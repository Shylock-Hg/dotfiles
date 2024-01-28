#! /usr/bin/bash

# Setup rust environment with rustup/rust and mirror

set -e

export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup
export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo 'export RUSTUP_UPDATE_ROOT=https://mirrors.aliyun.com/rustup/rustup' >> ~/.bash_profile
echo 'export RUSTUP_DIST_SERVER=https://mirrors.aliyun.com/rustup' >> ~/.bash_profile
source ~/.bash_profile

cp .cargo.conf  ~/.cargo/config
