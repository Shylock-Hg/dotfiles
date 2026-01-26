#! /usr/bin/env sh

sudo sed -i '1iServer = https://mirrors.ustc.edu.cn/cachyos/repo/$arch_v4/$repo' /etc/pacman.d/mirrorlist
sudo sed -i '1iServer = https://mirror.nju.edu.cn/cachyos/repo/$arch_v4/$repo' /etc/pacman.d/mirrorlist
