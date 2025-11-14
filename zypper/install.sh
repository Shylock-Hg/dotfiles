#! /usr/bin/env bash

sudo zypper dup -yl

until sudo zypper install -yl vim gcc gcc-c++ make cmake git powerline-fonts ctags clang \
    code wget \
    alacritty wine winetricks \
    google-noto-sans-cjk-fonts \
    fcitx5 fcitx5-configtool \
    jetbrains-mono-fonts \
    ripgrep \
    podman \
    rclone inotify-tools \
    mold ninja zstd flatpak stow
do
    echo 'Try again'
done
 
