#! /usr/bin/env sh

###############################################################################
#!  \brief  
#   \author Shylock Hg
#   \date 2018-11-25
#   \email tcath2s@gmail.com
###############################################################################

set -e  # exit when error

# Add user
eval \
\
# Archlinux installation
$NATIVE_INSTALL \
        base-devel \
        git vi vim emacs-nox gdb clang lldb cmake \
        openssh boost boost-libs valgrind man man-pages \
        wget sudo \
        python-pip python2-pip ruby nodejs npm \
        arm-none-eabi-gcc arm-none-eabi-gdb \
        arm-none-eabi-newlib arm-none-eabi-binutils && \
\
# yay
git clone https://aur.archlinux.org/yay.git && \
cd yay && makepkg --noconfirm -si && cd .. && rm -rf yay .cache && \
\
# Git configuration
git config --global user.name 'Shylock-Hg' && \
git config --global user.email 'tcath2s@gmail.com' && \
\
# Conda and torch, tensorflow
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh 2>/dev/null && \
sh Miniconda3-latest-Linux-x86_64.sh -b -p ./Miniconda3 && \
rm Miniconda3-latest-Linux-x86_64.sh && \
conda create --name=ml && \
conda install --name=ml tensorflow-gpu && \
conda install --name=ml -c pytorch pytorch torchvision cuda100 && \
yes y | conda clean --all && \
\
# boudica development environment
pip2 install --no-cache-dir --user pyyaml scons && \
\
# rust
curl https://sh.rustup.rs -sSf | sh -s -- -y && \
rustup install nightly && \
\
# zsh installation & oh-my-zsh configuration
$AUR_INSTALL zsh powerline-fonts && \
sudo chsh -s $(which zsh) shylock && \
curl -s https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh && \
\
# travis-ci cli
gem install travis -v 1.8.9 && \
\
# Vim installation and configuration
curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-vim.sh | sh && \
\
# Install my custom ultility to `/usr/local/bin`
curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build.sh | sh

# mysql installation and config
# eval ${AUR_INSTALL} mariadb \
#        && sudo usermod -a -G mysql shylock \
#        && sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Acceleration agent configuration for `github.com`, `archlinux sources`
#eval curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/build-speed.sh | sh
