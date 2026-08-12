#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Creating admin user..."
bash ./create_sunny.sh || true

echo "[2/4] Installing Linux tools..."
bash ./linux_tools_setup.sh

echo "[3/4] Installing Docker, Cockpit, Portainer..."
bash ./docker_cockpit_portainer_setup.sh

echo "[4/4] Checking ports..."
bash ./check_ports.sh || true

echo "Bootstrap complete."
