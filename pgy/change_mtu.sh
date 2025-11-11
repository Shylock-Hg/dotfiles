#! /usr/bin/env bash


# set tailscale0 mtu to avoid ssh blocked by pgy
sudo ip link set dev tailscale0 mtu 1200

