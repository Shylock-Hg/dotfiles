#! /usr/bin/env bash

# edge
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo zypper ar https://packages.microsoft.com/yumrepos/edge microsoft-edge
# vsocode
sudo zypper ar https://download.opensuse.org/repositories/devel:/tools:/ide:/vscode/openSUSE_Tumbleweed devel_tools_ide_vscode

sudo zypper --gpg-auto-import-keys refresh

