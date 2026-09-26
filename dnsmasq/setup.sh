#! /usr/bin/env bash

readonly SCRIPT_DIR=$(dirname $0)

sudo mkdir -p /etc/dnsmasq.d
sudo cp $SCRIPT_DIR/tailscale.conf /etc/dnsmasq.d/tailscale.conf

echo 'conf-dir=/etc/dnsmasq.d/,*.conf' | sudo tee -a /etc/dnsmasq.conf

# Route shylockhg.me to dnsmasq on the local machine as well
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo cp $SCRIPT_DIR/resolved-forgejo.conf /etc/systemd/resolved.conf.d/forgejo.conf
sudo systemctl restart systemd-resolved
