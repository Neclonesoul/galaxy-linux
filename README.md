# Galaxy Linux

**A rootless Arch Linux ARM desktop for Samsung Galaxy phones, tablets and DeX — powered by Termux, PRoot-Distro, Termux:X11 and XFCE.**

> Unofficial community project. Not affiliated with Samsung, Termux, Arch Linux or Arch Linux ARM.

Galaxy Linux turns a modern ARM64 Android device into a surprisingly capable pocket Linux workstation without rooting the phone. It installs a pinned Arch Linux ARM userspace inside PRoot-Distro, connects it to Termux:X11, bridges audio with PulseAudio, and gives you simple start/stop commands.

It is aimed first at **Samsung Galaxy S/Tab devices and Samsung DeX**, but compatible ARM64 Android hardware can work too.

## What it is

- Arch Linux ARM userspace with `pacman`
- XFCE desktop
- Firefox, Git, SSH, Curl, editors and basic developer utilities
- Termux:X11 display integration
- PulseAudio integration
- External display / Samsung DeX friendly
- Rootless: no bootloader unlock, Magisk or custom kernel required
- Snapdragon/Adreno detection with optional Termux-side Turnip/Zink packages
- Reversible container install

## What it is not

Galaxy Linux is **not** a virtual machine and it does not replace Android or boot a separate Linux kernel. PRoot intercepts and translates filesystem/system-call behaviour in userspace. Programs that depend on systemd boot, kernel modules, privileged namespaces, Docker-in-Docker, low-level USB access or strict sandboxing may not behave like they do on a normal Arch PC.

GPU acceleration is also device- and driver-dependent. The installer can prepare the Qualcomm Turnip/Zink host packages when it detects a likely Snapdragon/Adreno device, but the project deliberately does **not** promise that every Linux application inside PRoot will receive native hardware acceleration.

## Recommended hardware

- ARM64 Samsung Galaxy S / S+ / Ultra or Galaxy Tab S device
- Snapdragon/Adreno model preferred for experimentation with Turnip
- 8 GB RAM or more recommended
- 8–12 GB free storage recommended
- Samsung DeX, USB-C monitor, dock or HDMI adapter optional
- Bluetooth/USB keyboard and mouse optional

## Requirements

1. **Termux from F-Droid or the official Termux GitHub releases.** Avoid obsolete Play Store builds.
2. **Termux:X11 companion Android app** matching the Termux:X11 package you use.
3. Android ARM64/aarch64.
4. Internet connection for the first install.

## Install

For a public release, clone the repository instead of piping an unaudited remote script directly into a shell:

```bash
pkg update -y
pkg install git -y
git clone https://github.com/YOUR-USERNAME/galaxy-linux.git
cd galaxy-linux
chmod +x install.sh uninstall.sh bin/* scripts/*
./install.sh
```

The installer currently pins this Arch Linux ARM image:

```text
danhunsaker/archlinuxarm:20260517
```

Pinning avoids silently changing the entire userspace when an upstream `latest` tag moves.

## Start the desktop

Open the **Termux:X11** Android app, then in Termux run:

```bash
~/start-galaxy-linux
```

To enter the Arch shell without starting XFCE:

```bash
~/galaxy-linux-shell
```

To stop the desktop:

```bash
~/stop-galaxy-linux
```

## Arch basics

Inside the container:

```bash
pacman -Syu
pacman -Ss python
pacman -S python
python --version
```

## Samsung DeX workflow

A practical layout is:

1. Connect the Galaxy to a DeX display or dock.
2. Open Termux and Termux:X11.
3. Run `~/start-galaxy-linux`.
4. Put Termux:X11 full-screen on the external display.
5. Use Android/DeX for native apps and XFCE for Linux applications.

This keeps Android fully available while Linux runs as another application stack.

## Graphics modes

### Compatibility mode

This is the baseline. It prioritizes getting XFCE and ordinary X11 applications running reliably.

### Snapdragon / Adreno experimental path

When the installer sees a Qualcomm/Adreno-like hardware signature, it attempts to install these Termux-host packages:

```text
mesa-zink
vulkan-loader-android
mesa-vulkan-icd-freedreno
```

That prepares a Turnip/Zink-capable host environment, but PRoot graphics acceleration is not a universal plug-and-play boundary. Future releases can add tested per-device profiles rather than pretending that one environment-variable recipe fits every Galaxy generation.

## Why XFCE?

XFCE is light, conventional and comparatively forgiving in PRoot/X11 environments. KDE Plasma and GNOME are possible experiments, but they add more services, sandboxing assumptions and resource usage. Galaxy Linux therefore chooses reliability over screenshots.

## Troubleshooting

### Black screen with cursor

Stop the session:

```bash
~/stop-galaxy-linux
```

Then test Termux:X11 with legacy drawing by editing the `termux-x11` line in `~/start-galaxy-linux` to include:

```text
-legacy-drawing
```

### Wrong colours

Termux:X11 documents `-force-bgra` as a workaround on affected devices.

### XFCE cannot connect to display

Confirm the launcher is using `--shared-tmp`. Termux:X11 requires the PRoot session to share the host temporary directory so the X11 socket is visible; the launcher therefore uses `--shared-tmp`.

### Audio missing

From Termux, restart the launcher. It restarts PulseAudio and exports the loopback Pulse server into the container.

### Package installation fails

Arch Linux ARM is rolling software. First try:

```bash
~/galaxy-linux-shell
pacman -Syu
```

If the pinned image itself becomes incompatible, open an issue with your device model, Android version and the exact error.

## Uninstall

```bash
cd galaxy-linux
./uninstall.sh
```

The uninstaller deletes the Galaxy Linux container and launchers but intentionally leaves shared Termux packages installed. Removing packages such as `proot-distro`, PulseAudio or Termux:X11 automatically could break unrelated Termux projects.

## Repository layout

```text
galaxy-linux/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── install.sh
├── uninstall.sh
├── bin/
│   ├── start-galaxy-linux
│   └── stop-galaxy-linux
├── scripts/
│   └── arch-bootstrap.sh
└── docs/
    └── DEVICE-REPORT.md
```

## Device reports wanted

The most useful contribution is a reproducible device report: Galaxy model, SoC, GPU, Android version, RAM, DeX mode, whether XFCE launches, audio status, external resolution and renderer information.

See `docs/DEVICE-REPORT.md`.

## Security model

This project is designed as a development/workstation environment, not a security boundary. PRoot is not isolation equivalent to a VM. Do not run untrusted binaries merely because they are inside the container.

## Roadmap

- Tested Galaxy device compatibility table
- DeX DPI/resolution profiles
- Optional developer bundle: Python, Node.js, Hugo, GitHub CLI and Cloudflare tooling
- Optional VS Code/code-server profile
- Device-specific Turnip/Zink acceleration profiles backed by actual renderer tests
- Backup/export command for the Linux home directory
- Installer self-test and diagnostic report

## License

MIT. See `LICENSE`.
