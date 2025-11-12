#! /usr/bin/env bash

set -ex

readonly SCRIPT_DIR=$(dirname $0)

pushd $SCRIPT_DIR

# bash
ln -sf ~/dotfiles/bash/.my.bashrc ~/.my.bashrc
cp ~/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/dotfiles/aliases/.alias ~/.alias

# install on opensuse tumbleweed
./zypper/setup.sh

# install by flatpak
./flatpak/setup.sh

# wine and windows apps
./wine/setup.sh

# alacritty
ln -sf $(readlink -f .config/alacritty) ~/.config/alacritty

# git
ln -sf $(readlink -f ./git/.gitconfig) ~/.gitconfig

# vim
mkdir -p ~/.vim
./vim/setup-vim.sh
ln -sf $(readlink -f ./vim/.vimrc) ~/.vimrc

# wakatime
ln -sf $(readlink -f ./wakatime/.wakatime.cfg) ~/.wakatime.cfg

# rust
pushd ./rust
./setup-rust.sh
popd
. "$HOME/.cargo/env"

# datam
# require rust
cargo install datam
mkdir -p ~/.datam
ln -sf $(readlink -f ./datam/store.json) ~/.datam/store.json

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# ssh
#ln -sf $(readlink -f ./ssh/config) ~/.ssh/config

# podman
ln -sf $(readlink -f .config/containers) ~/.config/containers

# emacs
ln -sf $(readlink -f .config/emacs) ~/.config/emacs
rm -rf ~/.emacs*

# spacemacs
ln -sf $(readlink -f .spacemacs) ~/.spacemacs

# systemd
ln -sf $(readlink -f .config/systemd) ~/.config/systemd

# crontab
crontab $SCRIPT_DIR/crontab/jobs

# script
ln -sf $SCRIPT_DIR/sh ~/sh

# rustdesk
ln -sf $(readlink -f .config/rustdesk) ~/.config/rustdesk

popd # popd $(dirname $0)
