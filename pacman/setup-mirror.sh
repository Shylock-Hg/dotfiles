#! /usr/bin/env sh

###############################################################################
# build Acceleration Agent for `github.com`, `archlinux sources`
###############################################################################

# github.com
#echo -e '# github\n192.30.253.112 assets-cdn.github.com\n151.101.88.249 github.global.ssl.fastly.net' | sudo tee --append /etc/hosts

# archlinux sources
sudo sed -i '1iServer = https://mirrors.sjtug.sjtu.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sudo sed -i '1iServer = https://mirrors.nju.edu.cn/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
sudo sed -i '1iServer = https://mirrors.163.com/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
