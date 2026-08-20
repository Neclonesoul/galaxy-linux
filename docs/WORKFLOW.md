# Phone-to-Production Workflow

Developer Edition is designed around a simple path from a fresh Galaxy device to a deployed project.

```text
Samsung Galaxy / DeX
        ↓
Termux host
        ↓
Galaxy Linux (Arch + XFCE)
        ↓
Git / GitHub
        ↓
Hugo, Node.js or Python project
        ↓
Cloudflare / other Git-based deployment
```

## Typical static-site workflow

```bash
~/galaxy-linux-shell
mkdir -p ~/Projects && cd ~/Projects
git clone <repo>
cd <repo>
hugo server --bind 0.0.0.0
hugo --minify
git add -A
git commit -m "Publish update"
git push
```

## Typical Cloudflare Worker workflow

Inside the project:

```bash
npm install --save-dev wrangler@latest
npx wrangler login
npx wrangler dev
npx wrangler deploy
```

## Why the split between Termux and Arch?

Termux remains the Android-facing host layer. It owns PRoot-Distro, Termux:X11 and PulseAudio integration. Arch provides the conventional glibc Linux userspace and development packages. Keeping that boundary explicit makes the system easier to understand and debug.
