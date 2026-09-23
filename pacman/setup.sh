#! /usr/bin/env bash

readonly SCRIPT_DIR=$(dirname $0)
# set mirrors
$SCRIPT_DIR/setup-mirror.sh

WINE_PACKAGES=(wine)

if [[ $(grep '^ID=' /etc/os-release) == "ID=cachyos" ]]; then
  WINE_PACKAGES=(wine-cachyos wine-cachyos-opt)
fi

sudo pacman -Syu --noconfirm

REQUIRED_PACKAGES=(
    gcc make stow tailscale opam nginx dnsmasq
)

OPTIONAL_PACKAGES=(
    code yay mold ninja cmake clang lldb \
    libc++ libc++abi \
    ripgrep vim emacs \
    rclone inotify-tools \
    flatpak nodejs \
    fcitx5 fcitx5-configtool fcitx5-chinese-addons fcitx5-rime \
    ttf-jetbrains-mono noto-fonts noto-fonts-cjk wqy-microhei wqy-zenhei wqy-bitmapfont \
    ttf-roboto adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts ttf-dejavu \
    remmina freerdp \
    steam \
    "${WINE_PACKAGES[@]}" wine-mono wine-gecko winetricks \
    cronie powertop typst starship \
    aspell aspell-en \
    docker docker-compose podman podman-compose \
    nginx-mod-stream \
    qemu-full libvirt virt-manager virt-viewer vde2 \
    samba mupdf tesseract-data-chi_sim tesseract-data-chi_tra tesseract-data-eng \
    libreoffice-fresh libreoffice-fresh-zh-cn libreoffice-fresh-zh-tw \
    cdrtools dvd+rw-tools \
    gitleaks \
    opencode glab github-cli openai-codex claude-code \
    forgejo forgejo-cli forgejo-runner
)

# Append firewall_backend = "iptables" to /etc/libvirt/network.conf resolve the network connection
# of NAT network problem of guesthk
if [[ ${IN_CI:-false} == true ]]; then
  sudo pacman -S --noconfirm --needed "${REQUIRED_PACKAGES[@]}"
  # Resolve the remaining workstation packages without downloading gigabytes
  # that no later CI setup step uses.
  sudo pacman -Sp --needed --print-format '%n %v' \
      "${OPTIONAL_PACKAGES[@]}" tinymist
else
  sudo pacman -S --noconfirm --needed \
      "${REQUIRED_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}"
  yay -S --noconfirm pgyvisitor tinymist
fi
