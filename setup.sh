#! /usr/bin/env bash

set -ex

readonly CONFIG_DIR='.config'

readonly SCRIPT_DIR=$(dirname $0)

pushd $SCRIPT_DIR

# Install by native package manager
if command -v zypper >/dev/null 2>&1; then
  # install on opensuse tumbleweed
  ./zypper/setup.sh
elif command -v pacman > /dev/null 2>&1; then
  ./pacman/setup.sh
else
  echo "Error: unsupported package manager."
  exit 1
fi

# install by flatpak
./flatpak/setup.sh

# wine and windows apps
./wine/setup.sh

# git
# ln -sf $(readlink -f ./git/.gitconfig) ~/.gitconfig

# vim
mkdir -p ~/.vim
./vim/setup-vim.sh
ln -sf $(readlink -f ./vim/.vimrc) ~/.vimrc

# wakatime
# ln -sf $(readlink -f ./wakatime/.wakatime.cfg) ~/.wakatime.cfg

# rust
pushd ./rust
./setup-rust.sh
popd
. "$HOME/.cargo/env"

# datam
# require rust
cargo install datam
mkdir -p ~/.datam
ln -sf $(readlink -f ./datam/store.json) ~/.datam/store.json

# tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# ssh
#ln -sf $(readlink -f ./ssh/config) ~/.ssh/config

# emacs
rm -rf ~/.emacs*
git clone --depth=1 git@github.com:Shylock-Hg/prelude.git ~/.config/emacs

# spacemacs
#ln -sf $(readlink -f .spacemacs) ~/.spacemacs

# crontab
#crontab $SCRIPT_DIR/crontab/jobs

# sync home
stow shylock

popd # popd $(dirname $0)
