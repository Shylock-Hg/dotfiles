#! /usr/bin/env sh

################################################################################
# build my custom vim environment from pure os 
################################################################################

# NATIVE_INSTALL='yes | sudo pacman -Sy'
# need export NATIVE_INSTALL before run the script
#if [ -z "$NATIVE_INSTALL" ]; then
#	echo 'error : Undefined `NATIVE_INSTALL`!'
#	exit 1
#fi

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://githubraw.com/junegunn/vim-plug/master/plug.vim

# install and configure `pathogen`, `git`, `vim` and `viman`
# curl https://raw.githubusercontent.com/Shylock-Hg/viman/master/install.sh | sh

#if command -v viman > /dev/null ; then
#	echo 'Viman is in PATH!'
#else
#	export PATH="$PATH:$HOME/.local/bin"
#fi

#cp ./viman/.viman.yml $HOME/.viman.yml
#if curl https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/viman/.viman.yml -o $HOME/.viman.yml ; then
#        viman -Sf $HOME/.viman.yml
#fi

