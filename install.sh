#!/usr/bin/env bash

set -e

REPO="https://github.com/DarkNetOpps/Namizun-Adaptive.git"
BRANCH="adaptive-controller"
INSTALL_DIR="/var/www/namizun"

echo "=== Namizun Adaptive Installer ==="

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

echo "[1/7] Installing packages"

apt update

apt install -y \
    git \
    redis-server \
    python3 \
    python3-venv \
    python3-pip

echo "[2/7] Starting Redis"

systemctl enable redis-server
systemctl start redis-server

echo "[3/7] Downloading Namizun"

if [ -d "$INSTALL_DIR" ]; then
    systemctl stop namizun 2>/dev/null || true
    rm -rf "$INSTALL_DIR"
fi

git clone \
    -b "$BRANCH" \
    "$REPO" \
    "$INSTALL_DIR"

echo "[4/7] Creating Python environment"

python3 -m venv "$INSTALL_DIR/venv"

echo "[5/7] Installing Python dependencies"

"$INSTALL_DIR/venv/bin/pip" install --upgrade pip

"$INSTALL_DIR/venv/bin/pip" install \
    -r "$INSTALL_DIR/requirements.txt"

echo "[6/7] Installing service"

cp "$INSTALL_DIR/else/namizun.service" \
    /etc/systemd/system/namizun.service

ln -sf "$INSTALL_DIR/else/namizun" \
    /usr/local/bin/namizun

systemctl daemon-reload
systemctl enable namizun

echo "[7/7] Starting Namizun"

systemctl restart namizun

echo ""
echo "================================"
echo "Namizun installed successfully"
echo "Check status:"
echo "systemctl status namizun"
echo "================================"
