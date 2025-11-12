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
    python3-venv \
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

# Install Node.js (LTS) from NodeSource
NODE_MAJOR=20
NODE_GPG=/usr/share/keyrings/nodesource.gpg
NODE_LIST=/etc/apt/sources.list.d/nodesource.list
if [ ! -f "${NODE_LIST}" ]; then
  echo "Adding NodeSource repository for Node.js ${NODE_MAJOR}.x..."
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o "${NODE_GPG}"
  echo "deb [signed-by=${NODE_GPG}] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" > "${NODE_LIST}"
  apt-get update -y
else
  echo "NodeSource repository already configured."
fi

echo "Installing Node.js..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs

# Install required global npm CLIs
echo "Installing global npm CLIs..."
npm install -g @openai/codex @google/gemini-cli @github/copilot

# Note: tshark may ask questions during install; ensure DEBIAN_FRONTEND=noninteractive is set in your container build

PYTHON_VENV_DIR="/opt/python-tools"
PYTHON_VENV_BIN="${PYTHON_VENV_DIR}/bin"
PYTHON_VENV_PATH_SNIPPET="/etc/profile.d/python-tools-path.sh"

echo "Creating Python virtual environment at ${PYTHON_VENV_DIR}..."
if [ ! -d "${PYTHON_VENV_DIR}" ]; then
  python3 -m venv "${PYTHON_VENV_DIR}"
else
  echo "Virtual environment already exists; reusing."
fi

echo "Installing Python packages inside virtual environment..."
"${PYTHON_VENV_BIN}/python" -m pip install --no-cache-dir --upgrade pip
"${PYTHON_VENV_BIN}/python" -m pip install --no-cache-dir \
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

echo "Adding ${PYTHON_VENV_BIN} to global PATH..."
cat <<'EOF' > "${PYTHON_VENV_PATH_SNIPPET}"
if [ -d /opt/python-tools/bin ]; then
  export PATH="/opt/python-tools/bin:${PATH}"
fi
EOF

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
