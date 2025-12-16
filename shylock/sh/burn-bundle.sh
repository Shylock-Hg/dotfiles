#! /usr/bin/env bash

growisofs -Z /dev/sr0="$HOME/Data/bundle.iso"
#wodim -v dev=/dev/sr0 speed=8 -data ~/Data/bundle.iso
#wodim dev=/dev/sr0 -fix
