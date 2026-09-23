#! /usr/bin/env bash

set -euo pipefail

# Packages from pacman/setup.sh that have no openSUSE zypper package are not
# listed here: yay, wine-nine, opencode, openai-codex, claude-code, pgyvisitor,
# tinymist, forgejo-runner. Some of them are AUR helpers / npm / cargo packages.
REQUIRED_PACKAGES=(
    gcc gcc-c++ make stow tailscale opam nginx dnsmasq
)

OPTIONAL_PACKAGES=(
    vim cmake git ctags clang lldb \
    libc++1 libc++-devel libc++abi1 libc++abi-devel \
    mold ninja zstd ripgrep \
    code wget alacritty emacs rclone inotify-tools nodejs-default \
    powerline-fonts jetbrains-mono-fonts \
    google-noto-sans-cjk-fonts google-noto-sans-fonts google-noto-serif-fonts \
    wqy-microhei-fonts wqy-zenhei-fonts wqy-bitmap-fonts \
    google-roboto-fonts adobe-sourcehansans-cn-fonts adobe-sourcehanserif-cn-fonts \
    dejavu-fonts \
    fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-rime \
    podman python313-podman-compose docker docker-compose \
    remmina freerdp \
    wine winetricks wine-mono wine-gecko steam \
    cronie powertop aspell aspell-en samba mupdf \
    libreoffice libreoffice-l10n-zh_CN libreoffice-l10n-zh_TW \
    tesseract-ocr-traineddata-chi_sim tesseract-ocr-traineddata-chi_tra tesseract-ocr-traineddata-eng \
    qemu libvirt libvirt-daemon-qemu virt-manager virt-viewer vde2 bridge-utils \
    cdrecord mkisofs dvd+rw-tools \
    typst starship gitleaks glab gh forgejo
)

if [[ ${IN_CI:-false} == true ]]; then
    sudo zypper dup --dry-run -yl
    sudo zypper install -yl "${REQUIRED_PACKAGES[@]}"
    # Resolve packages unused by later CI stages without downloading them.
    sudo zypper install --dry-run -yl "${OPTIONAL_PACKAGES[@]}"
else
    sudo zypper dup -yl
    sudo zypper install -yl \
        "${REQUIRED_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}"
fi
