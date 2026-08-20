# Developer Edition

Galaxy Linux Developer Edition is the optional workstation profile for people who want to build and publish software from a Samsung Galaxy device.

## Included

- Git and GitHub CLI
- Hugo
- Node.js and npm
- Python, `venv`, pip and pipx
- OpenSSH and rsync
- ImageMagick
- jq, ripgrep, fd and ShellCheck
- C/C++ build tools (`base-devel`, Clang, CMake, Make)
- tmux, Vim and Nano
- Optional serial/embedded utilities when available: Minicom, Picocom, AVRDUDE and Arduino CLI
- `esptool` through pipx when installation succeeds

## Cloudflare

Wrangler is deliberately not installed globally by Galaxy Linux. Add it to each project:

```bash
npm install --save-dev wrangler@latest
npx wrangler --version
npx wrangler login
```

That keeps a repository's Wrangler version reproducible and avoids one global CLI silently changing every project.

## Hugo workflow

```bash
mkdir -p ~/Projects
cd ~/Projects
hugo new site example
cd example
hugo server --bind 0.0.0.0
```

Production build:

```bash
hugo --minify
```

## GitHub workflow

```bash
gh auth login
gh auth status

git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

Then create or clone repositories normally.

## Python workflow

Use a virtual environment instead of installing application dependencies into Arch's system Python:

```bash
python -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
```

## Android / Arduino / ESP notes

Galaxy Linux can provide compilers, CLI tools and serial utilities, but PRoot is not a normal Linux kernel environment and does not automatically expose Android USB devices as `/dev/ttyUSB*` or `/dev/ttyACM*`.

For embedded work, use the Android/Termux USB-permission path appropriate to your adapter and board, or use network/OTA workflows where possible. Treat direct USB flashing as device-specific rather than guaranteed functionality.

## Verify the workstation

From Termux:

```bash
~/galaxy-dev-check
```

For Cloudflare, run the Wrangler check from inside an actual Node project after installing it locally.
