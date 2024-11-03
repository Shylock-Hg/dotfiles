#! /usr/bin/env bash

pushd $(dirname $0)

# bash
ln -sf ~/dotfiles/bash/.bashrc ~/.bashrc
ln -sf ~/dotfiles/aliases/.alias ~/.alias

# install on opensuse tumbleweed
./opensuse-tumbleweed/setup-mirror.opensuse-tumbleweed.sh
./opensuse-tumbleweed/setup-ms-repo.opensuse.sh
./install.opensuse.sh

# alacritty
mkdir -p ~/.config/alacritty
ln -sf ~/dotfiles/alacritty/.alacritty.toml ~/.config/alacritty/.alacritty.toml

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
