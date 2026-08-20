#!/bin/bash
set -Eeuo pipefail
export LANG=C.UTF-8

printf '[*] Installing Galaxy Linux Developer Edition toolchain...\n'
pacman -Syu --noconfirm

pacman -S --needed --noconfirm \
  base-devel \
  git github-cli \
  openssh rsync \
  curl wget \
  nodejs npm \
  python python-pip python-pipx \
  hugo \
  imagemagick \
  jq \
  ripgrep fd \
  unzip zip tar \
  nano vim \
  shellcheck \
  tmux \
  make cmake clang

printf '[*] Installing optional embedded/serial utilities when available...\n'
for package in minicom picocom avrdude arduino-cli; do
  pacman -S --needed --noconfirm "$package" 2>/dev/null || \
    printf '[!] Optional package unavailable: %s\n' "$package"
done

# Keep Python tooling isolated from Arch's system Python.
python -m pipx ensurepath >/dev/null 2>&1 || true
if command -v pipx >/dev/null 2>&1; then
  pipx install esptool >/dev/null 2>&1 || true
fi

mkdir -p /root/.config/galaxy-linux /root/Projects
cat > /root/.config/galaxy-linux/developer-edition <<'EOF2'
GALAXY_LINUX_DEVELOPER_EDITION=1
EOF2

cat > /root/DEVELOPER-QUICKSTART.txt <<'EOF2'
Galaxy Linux — Developer Edition
================================

Core tools:
  git --version
  gh --version
  hugo version
  node --version
  npm --version
  python --version
  magick -version
  ssh -V

Suggested project workflow:
  mkdir -p ~/Projects && cd ~/Projects
  git clone <repository>
  cd <repository>

Cloudflare Wrangler:
  npm install --save-dev wrangler@latest
  npx wrangler --version
  npx wrangler login

Hugo:
  hugo server --bind 0.0.0.0
  hugo --minify

Python:
  python -m venv .venv
  source .venv/bin/activate
  python -m pip install --upgrade pip

Embedded / serial note:
  PRoot does not provide transparent raw USB access. Serial/USB workflows
  depend on Android/Termux device permissions and the specific adapter.
EOF2

printf '[+] Developer Edition installed.\n'
