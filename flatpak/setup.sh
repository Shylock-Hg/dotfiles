#! /usr/bin/env bash

sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub

sudo flatpak remote-list -d

sudo flatpak install -y com.microsoft.Edge \
    com.tencent.wemeet \
    com.tencent.WeChat \
    com.usebottles.bottles
