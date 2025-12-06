#! /usr/bin/env bash

sudo pacman -Syu

MY_WINE="wine"

if [ $(grep '^ID=' /etc/os-release) == "ID=cachyos" ];then
  MY_WINE="wine-cachyos wine-cachyos-opt"
fi

sudo pacman -S --noconfirm --needed \
    code yay mold ninja make cmake gcc clang lldb \
    libc++ libc++abi \
    ripgrep vim emacs stow \
    rclone inotify-tools \
    flatpak nodejs \
    fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-rime \
    ttf-jetbrains-mono noto-fonts noto-fonts-cjk wqy-microhei wqy-zenhei wqy-bitmapfont \
    remmina freerdp tailscale \
    steam \
    $MY_WINE wine-mono wine-gecko wine-nine winetricks \
    cronie powertop typst starship \
    hunspell hunspell-en_us \
    docker docker-compose podman podman-compose \
    nginx nginx-mod-stream \
    qemu-full libvirt virt-manager virt-viewer dnsmasq vde2 bridge-utils

# Append firewall_backend = "iptables" to /etc/libvirt/network.conf resolve the network connection
# of NAT network problem of guesthk
yay -S microsoft-edge-stable-bin \
    pgyvisitor \
    tinymist
