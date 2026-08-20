#!/data/data/com.termux/files/usr/bin/bash
set -Eeuo pipefail

PROJECT='Galaxy Linux'
GALAXY_LINUX_VERSION='v0.1.1'
GITHUB_REPO='Neclonesoul/galaxy-linux'
CONTAINER_NAME='galaxy-linux'
ARCH_IMAGE='danhunsaker/archlinuxarm:20260517'
PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
ROOTFS="$PREFIX/var/lib/proot-distro/containers/$CONTAINER_NAME/rootfs"
ORIGINAL_ARGS=("$@")
SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
REPO_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" 2>/dev/null && pwd || pwd)"
c_reset='\033[0m'; c_blue='\033[1;34m'; c_green='\033[1;32m'; c_yellow='\033[1;33m'; c_red='\033[1;31m'
info(){ printf "%b[*]%b %s\n" "$c_blue" "$c_reset" "$*"; }
ok(){ printf "%b[+]%b %s\n" "$c_green" "$c_reset" "$*"; }
warn(){ printf "%b[!]%b %s\n" "$c_yellow" "$c_reset" "$*"; }
die(){ printf "%b[x]%b %s\n" "$c_red" "$c_reset" "$*" >&2; exit 1; }

PROFILE='base'
REPAIR=0

bootstrap_remote_if_needed() {
  if [[ -f "$REPO_DIR/scripts/arch-bootstrap.sh" && -f "$REPO_DIR/bin/start-galaxy-linux" ]]; then
    return 0
  fi

  command -v curl >/dev/null 2>&1 || die 'curl is required for the standalone installer.'
  command -v tar >/dev/null 2>&1 || die 'tar is required for the standalone installer.'

  local tmp archive extracted
  tmp="$(mktemp -d "${TMPDIR:-$PREFIX/tmp}/galaxy-linux.XXXXXX")"
  archive="$tmp/galaxy-linux.tar.gz"
  trap 'rm -rf "$tmp"' EXIT

  info "Downloading Galaxy Linux ${GALAXY_LINUX_VERSION} from GitHub..."
  curl --fail --location --silent --show-error \
    --proto '=https' --tlsv1.2 \
    "https://github.com/${GITHUB_REPO}/archive/refs/tags/${GALAXY_LINUX_VERSION}.tar.gz" \
    -o "$archive"

  tar -xzf "$archive" -C "$tmp"
  extracted="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d -name 'galaxy-linux-*' | head -n1)"
  [[ -n "$extracted" && -x "$extracted/install.sh" ]] || die 'Downloaded release archive is incomplete.'

  ok "Release ${GALAXY_LINUX_VERSION} downloaded. Continuing with the complete repository."
  if "$extracted/install.sh" "${ORIGINAL_ARGS[@]}"; then
    rm -rf "$tmp"
    trap - EXIT
    exit 0
  else
    local status=$?
    rm -rf "$tmp"
    trap - EXIT
    exit "$status"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile) PROFILE="${2:-}"; shift 2;;
    --developer) PROFILE='developer'; shift;;
    --base) PROFILE='base'; shift;;
    --repair) REPAIR=1; shift;;
    -h|--help)
      printf 'Usage: %s [--profile base|developer] [--developer] [--base] [--repair]\n' "$0"
      exit 0;;
    *) die "Unknown option: $1";;
  esac
done

[[ "$PROFILE" == 'base' || "$PROFILE" == 'developer' ]] || die "Profile must be base or developer."

trap 'printf "\n%b[x]%b Installation stopped near line %s.\n" "$c_red" "$c_reset" "$LINENO" >&2' ERR

[[ -n "${TERMUX_VERSION:-}" || -d /data/data/com.termux/files/usr ]] || die 'Run this from Termux on Android.'
[[ "$(uname -m)" == 'aarch64' ]] || die 'This release currently supports ARM64/aarch64 Android devices only.'

bootstrap_remote_if_needed

echo
printf "%b%s%b\n" "$c_blue" 'Galaxy Linux — Arch Linux ARM + XFCE desktop for Samsung/Android + Termux:X11' "$c_reset"
printf '%s\n\n' 'Arch userspace • XFCE desktop • Rootless PRoot • DeX-friendly'

BRAND="$(getprop ro.product.brand 2>/dev/null || true)"
MODEL="$(getprop ro.product.model 2>/dev/null || true)"
SOC="$(getprop ro.soc.model 2>/dev/null || getprop ro.board.platform 2>/dev/null || true)"
EGL="$(getprop ro.hardware.egl 2>/dev/null || true)"
printf 'Device: %s %s\nSoC:    %s\nEGL:    %s\n\n' "${BRAND:-unknown}" "${MODEL:-unknown}" "${SOC:-unknown}" "${EGL:-unknown}"

if [[ "${BRAND,,}" != *samsung* ]]; then
  warn 'This installer is tuned for Galaxy devices, but will continue on compatible ARM64 Android hardware.'
fi

info 'Updating Termux packages...'
pkg update -y
pkg upgrade -y

info 'Installing Termux dependencies...'
pkg install -y x11-repo
pkg install -y proot-distro pulseaudio git curl wget
pkg install -y termux-x11-nightly || die 'termux-x11-nightly could not be installed. Check the X11 repository and your Termux source.'

# Optional host-side graphics packages. Failure is non-fatal because software rendering remains usable.
info 'Preparing optional Mesa/Vulkan support...'
pkg install -y mesa-zink vulkan-loader-android 2>/dev/null || warn 'Mesa Zink/Vulkan host packages were unavailable; continuing.'
if printf '%s %s' "$SOC" "$EGL" | grep -Eiq 'snapdragon|qcom|adreno|sm[0-9]'; then
  if pkg install -y mesa-vulkan-icd-freedreno 2>/dev/null; then
    GPU_MODE='turnip-candidate'
    ok 'Qualcomm/Adreno candidate detected; Turnip package installed on the Termux host.'
  else
    GPU_MODE='software'
    warn 'Adreno candidate detected, but the Turnip package was unavailable. Software path remains available.'
  fi
else
  GPU_MODE='software'
  warn 'No reliable Qualcomm/Adreno signature detected. Defaulting to the compatibility rendering path.'
fi

STATE_DIR="$HOME/.config/galaxy-linux"
STATE_FILE="$STATE_DIR/install-state"
mkdir -p "$STATE_DIR"
PREVIOUS_PROFILE=''
PREVIOUS_VERSION=''
if [[ -f "$STATE_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$STATE_FILE" || true
  PREVIOUS_PROFILE="${INSTALLED_PROFILE:-}"
  PREVIOUS_VERSION="${INSTALLED_VERSION:-}"
fi

CONTAINER_EXISTS=0
if proot-distro list -q 2>/dev/null | grep -Fxq "$CONTAINER_NAME"; then
  CONTAINER_EXISTS=1
  warn "Container '$CONTAINER_NAME' already exists; it will not be replaced."
else
  info "Installing pinned Arch Linux ARM image: $ARCH_IMAGE"
  proot-distro install --name "$CONTAINER_NAME" "$ARCH_IMAGE"
fi

[[ -d "$ROOTFS/root" ]] || die "Container rootfs not found at $ROOTFS"

NEED_BASE_BOOTSTRAP=1
if [[ "$CONTAINER_EXISTS" -eq 1 && "$REPAIR" -eq 0 && "$PREVIOUS_VERSION" == "$GALAXY_LINUX_VERSION" ]]; then
  NEED_BASE_BOOTSTRAP=0
  ok "Galaxy Linux ${GALAXY_LINUX_VERSION} base environment is already configured; skipping package bootstrap."
fi

if [[ "$NEED_BASE_BOOTSTRAP" -eq 1 ]]; then
  info 'Copying container bootstrap...'
  install -m 0755 "$REPO_DIR/scripts/arch-bootstrap.sh" "$ROOTFS/root/galaxy-linux-bootstrap.sh"

  info 'Configuring Arch Linux desktop...'
  proot-distro login "$CONTAINER_NAME" -- /root/galaxy-linux-bootstrap.sh
fi

if [[ "$PROFILE" == 'developer' ]]; then
  if [[ "$REPAIR" -eq 0 && "$PREVIOUS_PROFILE" == 'developer' && "$PREVIOUS_VERSION" == "$GALAXY_LINUX_VERSION" ]]; then
    ok 'Developer Edition is already configured; skipping developer package bootstrap.'
  else
    info 'Installing Developer Edition profile...'
    install -m 0755 "$REPO_DIR/profiles/developer/bootstrap.sh" "$ROOTFS/root/galaxy-linux-developer-bootstrap.sh"
    proot-distro login "$CONTAINER_NAME" -- /root/galaxy-linux-developer-bootstrap.sh
  fi
fi

info 'Installing launch commands...'
install -m 0755 "$REPO_DIR/bin/start-galaxy-linux" "$HOME/start-galaxy-linux"
install -m 0755 "$REPO_DIR/bin/stop-galaxy-linux" "$HOME/stop-galaxy-linux"
if [[ "$PROFILE" == 'developer' ]]; then
  install -m 0755 "$REPO_DIR/bin/galaxy-dev-check" "$HOME/galaxy-dev-check"
fi

mkdir -p "$HOME/.config/galaxy-linux"
cat > "$HOME/.config/galaxy-linux/config" <<CFG
CONTAINER_NAME='$CONTAINER_NAME'
DISPLAY_NUMBER=':1'
GPU_MODE='$GPU_MODE'
PROFILE='$PROFILE'
CFG

cat > "$STATE_FILE" <<STATE
INSTALLED_VERSION='$GALAXY_LINUX_VERSION'
INSTALLED_PROFILE='$PROFILE'
STATE

cat > "$HOME/galaxy-linux-shell" <<'EOF2'
#!/data/data/com.termux/files/usr/bin/bash
set -e
proot-distro login galaxy-linux --shared-tmp
EOF2
chmod +x "$HOME/galaxy-linux-shell"

ok 'Installation complete.'
echo
printf '1. Install/open the matching Termux:X11 Android companion app.\n'
printf '2. Start desktop:  %b~/start-galaxy-linux%b\n' "$c_green" "$c_reset"
printf '3. Stop desktop:   %b~/stop-galaxy-linux%b\n' "$c_green" "$c_reset"
printf '4. Arch shell:     %b~/galaxy-linux-shell%b\n' "$c_green" "$c_reset"
if [[ "$PROFILE" == 'developer' ]]; then
  printf '5. Developer test: %b~/galaxy-dev-check%b\n' "$c_green" "$c_reset"
fi
echo
warn 'PRoot is not a VM and does not provide a separate Linux kernel. Some desktop, sandboxing, systemd and GPU features may differ from a normal Arch PC.'
