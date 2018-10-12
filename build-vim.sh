#! /usr/bin/env sh

################################################################################
# build my custom vim environment from pure os 
################################################################################

# NATIVE_INSTALL='yes | sudo pacman -Sy'
# need export NATIVE_INSTALL before run the script
if [ -z "$NATIVE_INSTALL" ]; then 
	echo 'error : Undefined `NATIVE_INSTALL`!'
	exit 1
fi

if command -v curl > /dev/null ; then
	echo 'Curl is satisfied!'
else
	eval $NATIVE_INSTALL curl
fi

# reduct native setting of vim
#cp ./.vimrc.native $HOME/.vimrc
curl -s https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/.vimrc.native -o $HOME/.vimrc

# install and configure `pathogen`, `git`, `vim` and `viman`
curl -s https://raw.githubusercontent.com/Shylock-Hg/viman/master/install.sh | sh

if command -v viman > /dev/null ; then
	echo 'Viman is in PATH!'
else
	export PATH="$PATH:$HOME/.local/bin"
fi

#cp ./viman/.viman.yml $HOME/.viman.yml
curl -s https://raw.githubusercontent.com/Shylock-Hg/config.linux/master/viman/.viman.yml -o $HOME/.viman.yml
viman -Sf $HOME/.viman.yml

