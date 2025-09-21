#!/bin/bash

set -e

echo "=== Install Dev Tools ==="

sudo apt-get update

# Docker
if ! command -v docker &> /dev/null; then
  echo "[*] Installing Docker..."
  sudo apt-get install -y docker.io
  sudo usermod -aG docker $USER
  echo "    Note: Please log out and back in for Docker permissions"
else
  echo "[=] Docker already installed"
fi

# Docker Compose Plugin
if ! docker compose version &> /dev/null; then
  echo "[*] Installing Docker Compose Plugin..."
  sudo apt-get install -y docker-compose-plugin
else
  echo "[=] Docker Compose Plugin already installed"
fi

# Python 3
if ! command -v python3 &> /dev/null; then
  echo "[*] Installing Python..."
  sudo apt-get install -y python3 python3-pip
else
  echo "[=] Python already installed: $(python3 -V)"
fi

# Django
if ! python3 -m pip show django &> /dev/null; then
  echo "[*] Installing Django..."
  python3 -m pip install --user django
else
  echo "[=] Django already installed"
fi

echo "=== Done ==="
