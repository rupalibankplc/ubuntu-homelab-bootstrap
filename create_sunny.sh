#!/usr/bin/env bash
set -euo pipefail
USERNAME="sunny"

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (or: sudo bash create_sunny.sh)"
  exit 1
fi

if id "$USERNAME" &>/dev/null; then
  echo "User '$USERNAME' already exists."
else
  adduser --gecos "" "$USERNAME"
fi

groupadd -f cockpit-admin

for grp in sudo docker adm systemd-journal users plugdev video audio render input netdev dialout cdrom lpadmin sambashare cockpit-admin; do
  getent group "$grp" >/dev/null || groupadd "$grp"
  usermod -aG "$grp" "$USERNAME"
done

echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USERNAME
chmod 440 /etc/sudoers.d/90-$USERNAME

apt-get update
apt-get install -y openssh-server
systemctl enable --now ssh

echo "alias sudo=''" >> /home/$USERNAME/.bash_aliases
chown $USERNAME:$USERNAME /home/$USERNAME/.bash_aliases

echo "User '$USERNAME' configured."
