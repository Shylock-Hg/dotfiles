#! /usr/bin/env sh

###############################################################################
#!  \brief  
#   \author Shylock Hg
#   \date 2018-12-23
#   \email tcath2s@gmail.com
###############################################################################
set -e;

# environament variable for system package manager
export readonly NATIVE_INSTALL='sudo pacman --noconfirm --needed -Sy'
export readonly AUR_INSTALL='yay --noconfirm --needed -Sy'

# Git configuration
eval git config --global user.name 'Shylock-Hg' && \
git config --global user.email 'tcath2s@gmail.com' && \
\
# zsh installation & oh-my-zsh configuration
$NATIVE_INSTALL zsh powerline-fonts && \
sudo chsh -s /bin/zsh shylock && \
echo 'export SHELL=/usr/sbin/zsh' >> $HOME/.zshenv && \
curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh && \
\
# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y && \
\
# yay
git clone https://aur.archlinux.org/yay.git && \
cd yay && makepkg --noconfirm -si && cd .. && rm -rf yay .cache && \
\
# Conda and torch, tensorflow
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>/dev/null && \
sh Miniconda3-latest-Linux-x86_64.sh -b -p ./Miniconda3 && \
rm Miniconda3-latest-Linux-x86_64.sh && \
$HOME/Miniconda3/bin/conda create --name=ml && \
$HOME/Miniconda3/bin/conda install --name=ml tensorflow-gpu && \
$HOME/Miniconda3/bin/conda install --name=ml -c pytorch pytorch torchvision cuda92 && \
yes y | conda clean --all && \
echo 'export PATH="$PATH:/home/shylock/Miniconda3/bin"' >> $HOME/.zshenv && \
\
# local node, ruby and python path
echo 'export PATH="$PATH:/home/shylock/node_modules/.bin"' >> $HOME/.zshenv && \
echo 'export PATH="$PATH:/home/shylock/.gem/ruby/2.5.0/bin"' >> $HOME/.zshenv && \
echo 'export PATH="$PATH:/home/shylock/.local/bin"' >> $HOME/.zshenv && \
echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/lib"' >> $HOME/.zshenv && \
\
# travis-ci cli
gem install travis -v 1.8.9 --no-rdoc --no-ri && \
\
# Vim installation and configuration
curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-vim.sh | sh && \
\
# Install my custom ultility to `/usr/local/bin`
curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build.sh | sh && \
\
# gnome/xorg session
echo 'export XDG_CURRENT_DESKTOP=GNOME-Classic:GNOME' >> $HOME/.xinitrc && \
echo 'export GNOME_SHELL_SESSION_MODE=classic' >> $HOME/.xinitrc && \
echo 'exec gnome-session --session=gnome-classic' >> $HOME/.xinitrc && \
\
# vscode
$NATIVE_INSTALL code && \
# vscode setting map
ln -sf $HOME/.config/'Code - OSS' $HOME/.config/Code && \
ln -sf $HOME/.vscode-oss $HOME/.vscode && \
# reStructuredText supports for vscode plugin
pip install --user docutils doc8
