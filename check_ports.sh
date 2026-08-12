#!/usr/bin/env bash
set -e

echo "Listening Ports"
sudo ss -tulpn | grep -E ':(22|80|443|8080|8081|8443|9090|9443|51820|51821)\b' || true
echo

echo "Docker Containers"
if command -v docker >/dev/null 2>&1; then
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"
else
  echo "Docker is not installed."
fi
