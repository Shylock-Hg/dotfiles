#! /usr/bin/env bash


# set tailscale0 mtu to avoid ssh blocked by pgy
ip link set dev tailscale0 mtx 1200
