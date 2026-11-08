#! /usr/bin/env bash

readonly SCRIPT_DIR=$(dirname $0)

sudo mkdir -p /etc/dnsmasq.d
sudo cp $SCRIPT_DIR/tailscale.conf /etc/dnsmasq.d/tailscale.conf

# Idempotent: appending on every run used to leave several identical lines.
if ! grep -qxF 'conf-dir=/etc/dnsmasq.d/,*.conf' /etc/dnsmasq.conf; then
  echo 'conf-dir=/etc/dnsmasq.d/,*.conf' | sudo tee -a /etc/dnsmasq.conf
fi

# Order dnsmasq after tailscaled and keep retrying, so a boot race between
# dnsmasq and the creation of tailscale0 can't leave the split DNS down.
sudo mkdir -p /etc/systemd/system/dnsmasq.service.d
sudo cp $SCRIPT_DIR/systemd/dnsmasq.service.d/10-tailscale.conf /etc/systemd/system/dnsmasq.service.d/10-tailscale.conf

# Route shylockhg.me and headscale.internal to dnsmasq on the local machine as
# well. The latter keeps short tailnet names (`ping work-wsl`) working without
# relying on Tailscale's own `~.` catch-all.
sudo mkdir -p /etc/systemd/resolved.conf.d
sudo rm -f /etc/systemd/resolved.conf.d/dns.conf
sudo cp $SCRIPT_DIR/resolved-forgejo.conf /etc/systemd/resolved.conf.d/forgejo.conf

# Tailscale installs a `~.` catch-all pointing at MagicDNS, whose upstreams
# (1.1.1.1/1.0.0.1, pushed by Headscale) resolve this device as being outside
# mainland China. That makes GeoDNS hand out Baidu's overseas cluster
# (www.baidu.com -> www.wshifen.com -> 103.235.46.x): 300-5500 ms instead of
# the ~130 ms the domestic answer costs. Dropping the catch-all leaves `~.` to
# the DHCP resolver from the router, while dnsmasq still covers shylockhg.me and
# forwards headscale.internal to MagicDNS so tailnet names keep resolving.
if command -v tailscale >/dev/null 2>&1; then
  sudo tailscale set --accept-dns=false || true
fi

# A reboot also picks all of this up; do it now when systemd is running.
# (Restarting is skipped in CI, where systemd is not the init process.)
if [[ -d /run/systemd/system ]]; then
  sudo systemctl try-restart dnsmasq.service
  sudo systemctl try-restart systemd-resolved.service
fi
