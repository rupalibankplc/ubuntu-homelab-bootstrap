#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (or: sudo bash docker_cockpit_portainer_setup.sh)"
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release ufw cockpit

install -m 0755 -d /etc/apt/keyrings

if [[ ! -f /etc/apt/keyrings/docker.asc ]]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc
fi

ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo $VERSION_CODENAME)

cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable
EOF

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker
systemctl enable --now containerd
systemctl enable --now cockpit.socket

docker volume create portainer_data || true

if docker ps -a --format '{{.Names}}' | grep -q '^portainer$'; then
  docker rm -f portainer
fi

docker run -d \
  --name portainer \
  --restart=always \
  -p 9443:9443 \
  -p 8000:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data \
  portainer/portainer-ce:latest

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 9090/tcp
ufw allow 9443/tcp
ufw allow 8000/tcp
ufw --force enable

echo "Docker, Cockpit, Portainer and UFW installation completed."
