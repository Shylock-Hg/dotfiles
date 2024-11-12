#! /usr/bin/env bash

sudo zypper dup -yl

sudo zypper install -yl vim gcc gcc-c++ make cmake git powerline-fonts ctags clang \
    microsoft-edge-stable code \
    alacritty \
    google-noto-sans-cjk-fonts \
    fcitx5 fcitx5-configtool
