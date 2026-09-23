#! /usr/bin/env bash

if (( EUID == 0 )); then
    SUDO=()
else
    SUDO=(sudo)
fi

# Remove the previous mirror configuration when upgrading an existing image.
"${SUDO[@]}" zypper rr USTC:OSS USTC:NON-OSS USTC:UPDATE || true
"${SUDO[@]}" zypper rr BFSU:OSS BFSU:NON-OSS BFSU:UPDATE || true

"${SUDO[@]}" zypper mr -d repo-non-oss repo-oss repo-oss-debug repo-oss-source update-tumbleweed

"${SUDO[@]}" zypper ar -fcg 'https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/oss' BFSU:OSS
"${SUDO[@]}" zypper ar -fcg 'https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/non-oss' BFSU:NON-OSS
"${SUDO[@]}" zypper ar -fcg 'https://mirrors.bfsu.edu.cn/opensuse/update/tumbleweed' BFSU:UPDATE
