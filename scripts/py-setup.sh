#!/bin/bash
set -euo pipefail
echo "Starting environment setup..."

# Update packages
apt update -y
apt install -y software-properties-common curl

# Add deadsnakes PPA if missing
if ! grep -Rq "deadsnakes" /etc/apt/sources.list.d/; then
    echo "Adding deadsnakes PPA..."
    add-apt-repository -y ppa:deadsnakes/ppa
    apt update -y
else
    echo "Deadsnakes PPA already present."
fi

# Install Python
if command -v python3 >/dev/null 2>&1; then
    echo "Python3 already present: $(python3 --version)"
else
    echo "Installing Python 3.12 from deadsnakes..."
    apt install -y python3.12 python3.12-venv python3-pip
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 2
    echo "Python installed: $(python3 --version)"
fi

# Ensure pip
if command -v pip3 >/dev/null 2>&1; then
    echo "pip already present: $(pip3 --version)"
else
    echo "Installing pip..."
    apt install -y python3-pip
    echo "pip installed: $(pip3 --version)"
fi

# Ensure venv module
if python3 -m venv --help >/dev/null 2>&1; then
    echo "venv module is available."
else
    echo "Installing venv module..."
    apt install -y python3-venv
    echo "venv installed."
fi

# Test venv creation
echo "Testing virtual environment creation..."
python3 -m venv /tmp/test_venv && echo "Virtual environment created." || echo "Failed to create venv"

# Install Node.js via nvm
if command -v node >/dev/null 2>&1; then
    echo "Node already installed: $(node -v)"
else
    echo "Installing Node.js with nvm..."
    export NVM_DIR="$HOME/.nvm"
    mkdir -p "$NVM_DIR"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    . "$NVM_DIR/nvm.sh"
    nvm install 22
    echo "Node installed: $(node -v)"
    echo "npm installed: $(npm -v)"
fi

# Install PM2
if command -v pm2 >/dev/null 2>&1; then
    echo "pm2 already installed."
else
    echo "Installing pm2..."
    npm install -g pm2
    echo "pm2 installed: $(pm2 -v)"
fi

echo "Setup complete."
