#! /usr/bin/env bash

sudo nmcli con add ifname $1 type bridge con-name $1
sudo nmcli con add type bridge-slave ifname $2 master $1
# sudo nmcli con down "Wired connection 1"
sudo nmcli con up $1
