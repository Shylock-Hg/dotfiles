#! /usr/bin/env bash

sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
# edge
#sudo zypper ar https://packages.microsoft.com/yumrepos/edge microsoft-edge
# vsocode
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" |sudo tee /etc/zypp/repos.d/vscode.repo > /dev/null

# Only refresh the repository that was just added. Refreshing every
# repository here also contacts the unrelated openSUSE defaults
# (download.opensuse.org, codecs.opensuse.org); a transient failure of any
# of them would abort the whole setup before the package installer runs.
sudo zypper --gpg-auto-import-keys refresh code

