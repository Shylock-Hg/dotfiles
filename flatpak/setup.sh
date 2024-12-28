#! /usr/bin/env bash

sudo flatpak remote-list -d

sudo flatpak install -y com.microsoft.Edge \
    com.tencent.wemeet \
    com.tencent.WeChat
