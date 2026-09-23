#! /usr/bin/env sh

###############################################################################
# build Acceleration Agent for `github.com`, `archlinux sources`
###############################################################################

# github.com
#echo -e '# github\n192.30.253.112 assets-cdn.github.com\n151.101.88.249 github.global.ssl.fastly.net' | sudo tee --append /etc/hosts

# archlinux sources
readonly ALIYUN_MIRROR='Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch'
if ! grep -Fqx "$ALIYUN_MIRROR" /etc/pacman.d/mirrorlist; then
    printf '%s\n' "$ALIYUN_MIRROR" | sudo tee /tmp/aliyun-mirrorlist >/dev/null
    sudo tee -a /tmp/aliyun-mirrorlist </etc/pacman.d/mirrorlist >/dev/null
    sudo cp /tmp/aliyun-mirrorlist /etc/pacman.d/mirrorlist
    sudo rm /tmp/aliyun-mirrorlist
fi
