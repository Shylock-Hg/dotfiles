#! /usr/bin/env bash

sudo zypper dup -yl

# Packages from pacman/setup.sh that have no openSUSE zypper package are not
# listed here: yay, wine-nine, opencode, openai-codex, claude-code, pgyvisitor,
# tinymist, forgejo-runner. Some of them are AUR helpers / npm / cargo packages.
sudo zypper install -yl \
    vim gcc gcc-c++ make cmake git ctags clang lldb \
    libc++1 libc++-devel libc++abi1 libc++abi-devel \
    mold ninja zstd ripgrep \
    code wget alacritty emacs stow rclone inotify-tools nodejs-default \
    powerline-fonts jetbrains-mono-fonts \
    google-noto-sans-cjk-fonts google-noto-sans-fonts google-noto-serif-fonts \
    wqy-microhei-fonts wqy-zenhei-fonts wqy-bitmap-fonts \
    google-roboto-fonts adobe-sourcehansans-cn-fonts adobe-sourcehanserif-cn-fonts \
    dejavu-fonts \
    fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-rime \
    podman python313-podman-compose docker docker-compose \
    nginx tailscale remmina freerdp \
    wine winetricks wine-mono wine-gecko steam \
    cronie powertop aspell aspell-en samba mupdf \
    libreoffice libreoffice-l10n-zh_CN libreoffice-l10n-zh_TW \
    tesseract-ocr-traineddata-chi_sim tesseract-ocr-traineddata-chi_tra tesseract-ocr-traineddata-eng \
    qemu libvirt libvirt-daemon-qemu virt-manager virt-viewer dnsmasq vde2 bridge-utils \
    cdrecord mkisofs dvd+rw-tools \
    typst starship opam gitleaks glab gh forgejo
