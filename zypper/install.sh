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
    code wget alacritty emacs rclone inotify-tools nodejs-default npm-default \
    python313 python313-pip \
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
    ffmpeg ImageMagick blender espeak-ng kdenlive \
    typst starship gitleaks glab gh forgejo
)

if [[ ${IN_CI:-false} == true ]]; then
    # Fetch the repository metadata once, then reuse it with --no-refresh so
    # the following zypper calls do not hit the network again.
    sudo zypper --gpg-auto-import-keys refresh

    sudo zypper --no-refresh dup --dry-run -yl
    sudo zypper --no-refresh install -yl "${REQUIRED_PACKAGES[@]}"
    # Resolve packages unused by later CI stages without downloading them.
    # Minimal container images substitute busybox for gawk. Kdenlive's KDE
    # dependencies need real awk; explicitly model that replacement in this
    # dry-run transaction without changing the running container.
    OPTIONAL_REMOVALS=()
    if rpm -q busybox-gawk >/dev/null 2>&1; then
        OPTIONAL_REMOVALS=(-busybox-gawk)
    fi
    sudo zypper --no-refresh install --dry-run -yl -- \
        "${OPTIONAL_PACKAGES[@]}" "${OPTIONAL_REMOVALS[@]}"
else
    sudo zypper dup -yl
    sudo zypper install -yl \
        "${REQUIRED_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}"
fi
