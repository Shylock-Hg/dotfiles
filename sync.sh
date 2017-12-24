#!/bin/sh

#sync vim config
cp ~/.vimrc $1
cp -r ~/.vim $1

#sync shadowsocks config
cp -r ~/.ss.d $1
