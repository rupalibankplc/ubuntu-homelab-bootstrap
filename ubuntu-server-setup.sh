#!/bin/bash

# Ubuntu Server Full Toolchain Setup Script
# Covers: system updates, dev tools, DevOps, monitoring, networking, utilities
# Run as: sudo bash ubuntu-server-setup.sh

set -e

echo "=== Ubuntu Server Full Toolchain Setup ==="
echo "Starting at $(date)"

# Update system
echo -e "\n[1/10] Updating system..."
apt-get update
apt-get upgrade -y
apt-get autoremove -y

# Essential build tools
echo -e "\n[2/10] Installing build tools..."
apt-get install -y \
  build-essential \
  cmake \
  git \
  curl \
  wget \
  nano \
  vim \
  htop \
  tmux \
  screen

# Development tools & languages
echo -e "\n[3/10] Installing dev tools..."
apt-get install -y \
  python3 \
  python3-pip \
  python3-venv \
  nodejs \
  npm \
  openjdk-11-jdk-headless \
  ruby \
  golang-go

# DevOps & Container tools
echo -e "\n[4/10] Installing Docker & container tools..."
apt-get install -y \
  docker.io \
  docker-compose \
  podman \
  podman-compose

# Start Docker daemon
systemctl start docker
systemctl enable docker

# Networking & system utilities
echo -e "\n[5/10] Installing networking tools..."
apt-get install -y \
  net-tools \
  iputils-ping \
  dnsutils \
  traceroute \
  iperf3 \
  openssh-server \
  openssh-client \
  telnet \
  whois \
  nmap

# Monitoring & performance tools
echo -e "\n[6/10] Installing monitoring tools..."
apt-get install -y \
  sysstat \
  iotop \
  nethogs \
  lsof \
  strace \
  tcpdump \
  iftop

# Database clients
echo -e "\n[7/10] Installing database clients..."
apt-get install -y \
  postgresql-client \
  mysql-client \
  sqlite3 \
  redis-tools

# Security & admin tools
echo -e "\n[8/10] Installing security tools..."
apt-get install -y \
  openssl \
  sudo \
  acl \
  apparmor \
  fail2ban \
  ufw

# Compression & archive tools
echo -e "\n[9/10] Installing compression tools..."
apt-get install -y \
  zip \
  unzip \
  tar \
  gzip \
  bzip2 \
  xz-utils \
  p7zip-full

# Additional utilities
echo -e "\n[10/10] Installing additional utilities..."
apt-get install -y \
  jq \
  yq \
  tree \
  parallel \
  rsync \
  fzf \
  figlet

# Cleanup
echo -e "\nCleaning up..."
apt-get clean
apt-get autoclean

# Summary
echo -e "\n=== Setup Complete ==="
echo "Installed:"
echo "  • Build tools (gcc, make, cmake)"
echo "  • Development (Git, Python, Node.js, Java, Ruby, Go)"
echo "  • Container tools (Docker, Podman)"
echo "  • Networking (net-tools, nmap, dnsutils, traceroute)"
echo "  • Monitoring (htop, iotop, nethogs, sysstat)"
echo "  • Database clients (PostgreSQL, MySQL, Redis)"
echo "  • Security tools (OpenSSL, fail2ban, UFW)"
echo "  • Utilities (jq, tree, rsync, fzf)"
echo ""
echo "Next steps:"
echo "  1. Add user to docker group: sudo usermod -aG docker \$USER"
echo "  2. Enable UFW firewall: sudo ufw enable"
echo "  3. Install additional tools as needed"
echo ""
echo "Completed at $(date)"
