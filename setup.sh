#! /usr/bin/env bash

set -ex

pushd $(dirname $0)

# bash
ln -sf ~/dotfiles/bash/.my.bashrc ~/.my.bashrc
cp ~/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/dotfiles/aliases/.alias ~/.alias

# install on opensuse tumbleweed
./opensuse-tumbleweed/setup.sh

# install by flatpak
./flatpak/setup.sh

# alacritty
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/alacritty/.alacritty.toml ~/.config/alacritty/alacritty.toml

# git
ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig

# vim
mkdir -p ~/.vim
./vim/setup-vim.sh
ln -sf ~/dotfiles/vim/.vimrc ~/.vimrc

# wakatime
ln -sf ~/dotfiles/wakatime/.wakatime.cfg ~/.wakatime.cfg

# rust
pushd ./rust
./setup-rust.sh
popd
. "$HOME/.cargo/env"

# datam
# require rust
cargo install datam
mkdir -p ~/.datam
ln -sf ~/dotfiles/datam/store.json ~/.datam/store.json

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# ssh
#ln -sf ~/dotfiles/ssh/config ~/.ssh/config

# podman
ln -sf ~/dotfiles/containers ~/.config/containers

# emacs
ln -sf ~/dotfiles/emacs/.emacs ~/.emacs

popd # popd $(dirname $0)
