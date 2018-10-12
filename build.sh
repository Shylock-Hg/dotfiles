#! /usr/bin/env sh

###############################################################################
# install my custom ultility scripts to `/usr/bin`
# 1. archlinux-python
# 2. mksource
# 3. win2nix
###############################################################################

# archlinux-python
sudo curl -s https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/archlinux-python.sh -o /usr/local/bin/archlinux-python
sudo chmod a+x /usr/local/bin/archlinux-python

# mksource
sudo curl -s https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/mksource.sh -o /usr/local/bin/mksource
sudo chmod a+x /usr/local/bin/mksource

# win2nix
sudo curl -s https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/win2nix.sh -o /usr/local/bin/win2nix
sudo chmod a+x /usr/local/bin/win2nix

