#! /usr/bin/env bash

readonly SCRIPT_DIR=$(dirname $0)

sudo mkdir -p /etc/dnsmasq.d
sudo cp $SCRIPT_DIR/tailscale.conf /etc/dnsmasq.d/tailscale.conf

echo 'conf-dir=/etc/dnsmasq.d/,*.conf' | sudo tee -a /etc/dnsmasq.conf
