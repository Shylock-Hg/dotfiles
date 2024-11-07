#! /usr/bin/env bash

set -ex

pushd $(dirname $0)

# bash
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/dotfiles/aliases/.alias ~/.alias

# install on opensuse tumbleweed
./opensuse-tumbleweed/setup.sh

# alacritty
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/alacritty/.alacritty.toml ~/.config/alacritty/.alacritty.toml

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

popd # popd $(dirname $0)
