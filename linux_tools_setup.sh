#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (or: sudo bash linux_tools_setup.sh)"
  exit 1
fi

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade

apt-get install -y \
  htop nmon btop neovim nano vim curl wget git unzip zip tar gzip xz-utils \
  rsync tree jq yq tmux screen mc ca-certificates gnupg lsb-release \
  software-properties-common build-essential openssh-client openssh-server \
  net-tools iproute2 iputils-ping dnsutils traceroute mtr-tiny tcpdump nmap \
  iftop iotop sysstat dstat lsof psmisc procps bash-completion cron \
  logrotate ufw fail2ban parted gdisk smartmontools ncdu

systemctl enable --now ssh
systemctl enable --now cron
systemctl enable --now fail2ban || true

apt-get -y autoremove
apt-get -y autoclean

echo "Linux tools installation completed."
