#! /usr/bin/env bash

# Remove the previous mirror configuration when upgrading an existing image.
sudo zypper rr USTC:OSS USTC:NON-OSS USTC:UPDATE || true

sudo zypper mr -d repo-non-oss repo-oss repo-oss-debug repo-oss-source update-tumbleweed


sudo zypper ar -fcg 'https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/oss' BFSU:OSS
sudo zypper ar -fcg 'https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/non-oss' BFSU:NON-OSS
sudo zypper ar -fcg 'https://mirrors.bfsu.edu.cn/opensuse/update/tumbleweed' BFSU:UPDATE
