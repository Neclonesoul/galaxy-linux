#!/bin/bash
set -Eeuo pipefail

export LANG=C.UTF-8

printf '[*] Initializing Arch package system...\n'
if command -v pacman-key >/dev/null 2>&1; then
  pacman-key --init || true
  pacman-key --populate archlinuxarm || true
fi

pacman -Syu --noconfirm

printf '[*] Installing XFCE desktop and core utilities...\n'
pacman -S --needed --noconfirm \
  xfce4 xfce4-goodies \
  dbus \
  mesa \
  firefox \
  git curl wget openssh \
  nano vim \
  sudo \
  ttf-dejavu noto-fonts \
  xorg-xrandr xorg-xsetroot \
  htop

# Nice-to-have utilities should never make the base desktop installation fail.
pacman -S --needed --noconfirm fastfetch 2>/dev/null || true

# PRoot does not provide a normal systemd boot. Create a machine-id for D-Bus if absent.
mkdir -p /var/lib/dbus /etc
if [[ ! -s /etc/machine-id ]]; then
  if command -v dbus-uuidgen >/dev/null 2>&1; then
    dbus-uuidgen --ensure=/etc/machine-id || true
  else
    cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id || true
  fi
fi
[[ -e /var/lib/dbus/machine-id ]] || ln -s /etc/machine-id /var/lib/dbus/machine-id 2>/dev/null || true

mkdir -p /root/Desktop /root/.config/xfce4
cat > /root/Desktop/README.txt <<'TXT'
Galaxy Linux
============

You are inside an Arch Linux ARM userspace running rootlessly through PRoot-Distro.

Useful commands:
  pacman -Syu
  pacman -Ss <package>
  pacman -S <package>

Host launchers live in the Termux home directory:
  ~/start-galaxy-linux
  ~/stop-galaxy-linux
  ~/galaxy-linux-shell

This is not a full virtual machine and does not boot its own Linux kernel.
TXT

printf '[+] Arch desktop configuration complete.\n'
