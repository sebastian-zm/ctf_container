#!/usr/bin/env bash
set -euo pipefail

echo "Updating apt and installing packages..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    apt-transport-https \
    software-properties-common \
    wget \
    curl \
    gnupg \
    unzip \
    git \
    build-essential \
    python3 \
    python3-dev \
    python3-pip \
    openjdk-11-jdk-headless \
    binutils \
    hexedit \
    iputils-ping \
    tshark \
    ffmpeg \
    sox \
    apktool \
    aircrack-ng \
    binwalk \
    steghide \
    gpg \
    wget

# Note: tshark may ask questions during install; ensure DEBIAN_FRONTEND=noninteractive is set in your container build

echo "Installing Python packages (pip3)..."
python3 -m pip install --no-cache-dir --upgrade pip
python3 -m pip install --no-cache-dir \
    requests \
    numpy \
    pandas \
    matplotlib \
    pycrypto \
    pillow \
    oletools \
    opencv-python-headless \
    pyzbar \
    pymodbus \
    volatility3

# JADX (CLI)
JADX_VERSION="1.5.3"
echo "Installing jadx ${JADX_VERSION}..."
wget -q "https://github.com/skylot/jadx/releases/download/v${JADX_VERSION}/jadx-${JADX_VERSION}.zip" -O /tmp/jadx.zip
unzip -q /tmp/jadx.zip -d /opt/
rm -f /tmp/jadx.zip
ln -sf /opt/jadx-${JADX_VERSION}/bin/jadx /usr/local/bin/jadx

# Optional GHIDRA (headless analyzer)
if [ -n "${GHIDRA_URL:-}" ]; then
  echo "Downloading GHIDRA from GHIDRA_URL..."
  mkdir -p /opt/ghidra
  wget -qO /tmp/ghidra.zip "${GHIDRA_URL}"
  unzip -q /tmp/ghidra.zip -d /opt/ghidra
  rm -f /tmp/ghidra.zip
  echo "GHIDRA extracted to /opt/ghidra (use support/analyzeHeadless for headless analysis)"
else
  echo "GHIDRA not downloaded (set GHIDRA_URL to auto-download)."
fi

echo "Done. Tools installed."
echo "Useful CLIs installed: jadx, apktool, binwalk, steghide, tshark, ffmpeg, sox, aircrack-ng, hexedit, binutils (objdump/readelf/etc.), python3/pip (with packages), openjdk headless."

