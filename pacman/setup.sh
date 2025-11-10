#! /usr/bin/env bash

sudo pacman -Syu

sudo pacman -S --noconfirm --needed code yay mold ninja make cmake gcc clang \
    libc++ libc++abi \
    ripgrep podman \
    rclone inotify-tools \
    flatpak \
    fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-rime \
    ttf-jetbrains-mono noto-fonts noto-fonts-cjk \
    remmina freerdp tailscale \
    steam \
    wine wine-mono winetricks \
    cronie powertop

yay -S microsoft-edge-stable-bin \
    pgyvisitor
