#! /usr/bin/env sh

################################################################################
# build my custom vim environment from pure os 
################################################################################

# NATIVE_INSTALL='sudo pacman -Sy'
# need export NATIVE_INSTALL before run the script
if [ -z "$NATIVE_INSTALL" ]; then 
	echo 'error : Undefined `NATIVE_INSTALL`!'
	exit 1
fi

if command -v curl > /dev/null ; then
	echo 'Curl is satisfied!'
else
	$NATIVE_INSTALL curl
fi

# install and configure `pathogen`, `git`, `vim` and `viman`
curl -sL https://raw.githubusercontent.com/Shylock-Hg/viman/master/install.sh | sh

# backup `.vimrc`, `.viman.yml`, `shadowsocks`
if ./sync.sh -o reduct ; then
	viman -Sf $HOME/.viman.yml
else
	echo 'error : reduct configuration failed!'
fi

