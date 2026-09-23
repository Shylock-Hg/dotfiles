#! /usr/bin/env sh

###############################################################################
# build Acceleration Agent for `github.com`, `archlinux sources`
###############################################################################

# github.com
#echo -e '# github\n192.30.253.112 assets-cdn.github.com\n151.101.88.249 github.global.ssl.fastly.net' | sudo tee --append /etc/hosts

# archlinux sources
readonly ALIYUN_MIRROR='Server = https://mirrors.aliyun.com/archlinux/$repo/os/$arch'
as_root() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

if ! grep -Fqx "$ALIYUN_MIRROR" /etc/pacman.d/mirrorlist; then
    printf '%s\n' "$ALIYUN_MIRROR" | as_root tee /tmp/aliyun-mirrorlist >/dev/null
    as_root tee -a /tmp/aliyun-mirrorlist </etc/pacman.d/mirrorlist >/dev/null
    as_root cp /tmp/aliyun-mirrorlist /etc/pacman.d/mirrorlist
    as_root rm /tmp/aliyun-mirrorlist
fi
