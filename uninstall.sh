#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

CONTAINER_NAME='galaxy-linux'

echo 'Galaxy Linux uninstaller'
echo
read -r -p "Delete the '$CONTAINER_NAME' container and all files inside it? [y/N] " answer
[[ "$answer" =~ ^[Yy]$ ]] || { echo 'Cancelled.'; exit 0; }

"$HOME/stop-galaxy-linux" 2>/dev/null || true
proot-distro remove "$CONTAINER_NAME" 2>/dev/null || true
rm -f "$HOME/start-galaxy-linux" "$HOME/stop-galaxy-linux" "$HOME/galaxy-linux-shell"
rm -rf "$HOME/.config/galaxy-linux"

echo 'Galaxy Linux container and launchers removed.'
echo 'Shared Termux packages were intentionally left installed because other Termux projects may use them.'
