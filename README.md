# Galaxy Linux

> **Arch Linux ARM + XFCE desktop for Samsung Galaxy and Android ---
> powered by Termux:X11.**

**Rootless • PRoot • Arch Linux ARM • XFCE • Termux:X11 • DeX-friendly**

Galaxy Linux turns a compatible Android phone or tablet into a portable
Linux workstation without rooting the device, replacing Android, or
unlocking the bootloader.

It runs an **Arch Linux ARM userspace** through PRoot. **XFCE** is the
graphical desktop running inside Arch, and **Termux:X11** displays that
desktop on Android or a Samsung DeX monitor.

> \[!IMPORTANT\] Galaxy Linux is an independent community project. It is
> not affiliated with or endorsed by Samsung, Arch Linux, Termux, or
> Termux:X11.

------------------------------------------------------------------------

## Architecture

``` text
Samsung Galaxy / Android
          │
          ▼
        Termux
          │
          ▼
     PRoot-Distro
          │
          ▼
   Arch Linux ARM
          │
          ▼
        XFCE
          │
          ▼
     Termux:X11
          │
          ▼
Phone / Tablet / Samsung DeX
```

### Why does an Arch project say XFCE?

They are different layers.

-   **Arch Linux ARM** is the Linux userspace/distribution. It supplies
    the filesystem, shell, libraries, `pacman`, packages and development
    environment.
-   **XFCE** is the graphical desktop environment running inside Arch.
-   **Termux:X11** is the X server/display bridge that lets Android show
    the Linux desktop.
-   **Samsung DeX** is an optional Samsung external-display environment.

XFCE does **not** replace Arch. A future Galaxy Linux profile could use
another desktop environment while still running Arch Linux underneath.

------------------------------------------------------------------------

## Features

-   Arch Linux ARM userspace
-   Rootless PRoot environment
-   XFCE desktop
-   Termux:X11 integration
-   Samsung DeX-friendly workflow
-   PulseAudio integration
-   Start and stop launchers
-   Existing-installation protection
-   Repair/reconfiguration mode
-   Clean uninstall workflow
-   Optional Developer Edition
-   Device compatibility reporting
-   Snapdragon/Adreno-aware graphics setup where supported
-   Software-rendering fallback where appropriate

------------------------------------------------------------------------

# Quick Start

## Requirements

Recommended:

-   64-bit ARM Android device
-   Samsung Galaxy S/Tab class device or equivalent
-   current Termux installation
-   Termux:X11 companion app
-   at least **5 GB free storage** for a practical desktop installation
-   reliable Internet connection during installation
-   keyboard and mouse for serious desktop use
-   Samsung DeX for the best external-monitor experience

**Samsung DeX is recommended, not required.**

> \[!NOTE\] PRoot is not a virtual machine and Galaxy Linux does not
> boot a separate Linux kernel. The Arch userspace runs on top of
> Android's existing kernel.

## 1. Install Termux and Termux:X11

Install a current supported Termux build and the Termux:X11 companion
application from their official project sources.

Galaxy Linux needs both the Termux-side `termux-x11` command and the
Android Termux:X11 app to display the desktop.

## 2. Install Galaxy Linux

### Stable Base Edition --- v0.1.1

``` bash
curl -fsSL https://raw.githubusercontent.com/Neclonesoul/galaxy-linux/v0.1.1/install.sh | bash
```

The version is deliberately pinned. This prevents the command from
silently executing a future, untested version of `main`.

The installer prepares the required Termux packages, creates the Arch
environment, configures XFCE and generates the Galaxy Linux launchers.

## 3. Start the desktop

``` bash
~/start-galaxy-linux
```

Open **Termux:X11** to view the desktop.

## 4. Stop the desktop

``` bash
~/stop-galaxy-linux
```

------------------------------------------------------------------------

# Developer Edition

Galaxy Linux Developer Edition extends the base desktop into a mobile
development workstation.

It is intended for workflows such as:

``` text
Galaxy → Termux → Arch → Code → Git → GitHub → Build → Deploy
```

Developer tooling includes support for:

-   Git
-   GitHub CLI
-   Hugo
-   Node.js and npm
-   Python, pip/venv and pipx
-   OpenSSH
-   rsync
-   ImageMagick
-   jq
-   ripgrep
-   fd
-   ShellCheck
-   tmux
-   Clang
-   CMake
-   general build tooling
-   Cloudflare Wrangler project workflows
-   optional Arduino/ESP development tooling

### Install Developer Edition directly

``` bash
curl -fsSL https://raw.githubusercontent.com/Neclonesoul/galaxy-linux/v0.1.1/install.sh \
  | bash -s -- --profile developer
```

### Check the developer environment

After installation:

``` bash
~/galaxy-dev-check
```

### Cloudflare projects

Wrangler should normally be installed per project:

``` bash
mkdir -p ~/Projects
cd ~/Projects/my-project

npm install --save-dev wrangler@latest
npx wrangler login
npx wrangler dev
npx wrangler deploy
```

------------------------------------------------------------------------

# Daily Use

Start the graphical desktop:

``` bash
~/start-galaxy-linux
```

Enter the Arch shell without launching XFCE:

``` bash
~/galaxy-linux-shell
```

Stop the graphical environment:

``` bash
~/stop-galaxy-linux
```

A useful project layout is:

``` bash
mkdir -p ~/Projects
cd ~/Projects
```

From there you can clone and work with normal development repositories:

``` bash
git clone <repository>
cd <repository>
```

Examples:

``` bash
hugo server --bind 0.0.0.0
```

``` bash
npm install
npm run dev
```

``` bash
python -m venv .venv
source .venv/bin/activate
```

------------------------------------------------------------------------

# Repair and Reconfiguration

Galaxy Linux is designed to detect an existing installation rather than
silently destroying it.

To intentionally rerun base configuration:

``` bash
./install.sh --repair
```

For Developer Edition:

``` bash
./install.sh --profile developer --repair
```

Do not use repair mode as a substitute for backing up important work.

------------------------------------------------------------------------

# Graphics Acceleration

Graphics support on Android is hardware- and software-dependent.

Snapdragon Galaxy devices using Qualcomm Adreno graphics may be able to
use the Turnip/Zink graphics stack. Galaxy Linux detects relevant device
information and can configure an accelerated path where appropriate.

**Hardware acceleration is not guaranteed.**

Compatibility can vary with:

-   Samsung model
-   Snapdragon or Exynos SoC
-   GPU generation
-   Android version
-   One UI version
-   Termux version
-   Termux:X11 version
-   Mesa/Turnip versions
-   individual Linux applications

A software-rendering fallback is preferable to pretending unsupported
hardware is accelerated.

------------------------------------------------------------------------

# Samsung DeX

DeX is not required to run Galaxy Linux, but it is one of the project's
primary use cases.

A Galaxy phone connected to a monitor, keyboard and mouse can provide:

-   Android applications through DeX
-   a conventional Arch shell
-   an XFCE Linux desktop
-   Git-based development
-   local web development
-   SSH administration
-   static-site development
-   Python and Node.js workflows

Galaxy Linux does not replace DeX. It adds a Linux workstation
environment that can be used alongside it.

------------------------------------------------------------------------

# USB, Arduino and ESP Development

Developer Edition can provide compilers, command-line tooling and
embedded-development utilities.

However, PRoot does not automatically grant unrestricted access to
Android USB devices. Android remains responsible for USB permissions and
device ownership.

Therefore:

-   source editing and compilation can work normally;
-   firmware/toolchain preparation can work normally;
-   direct USB flashing may require additional Android/Termux
    integration;
-   support varies by device and adapter.

Do not assume that a USB device visible to Android will automatically
appear as a conventional `/dev/ttyUSB*` device inside Arch.

------------------------------------------------------------------------

# Troubleshooting

## Black screen or cursor only

Termux:X11 documents compatibility options for devices that display a
black screen or rendering problems. Consult the upstream Termux:X11
documentation before changing the Galaxy Linux launcher.

## XFCE does not appear

Check that:

1.  Termux:X11 is installed.
2.  the Termux-side X11 packages are installed.
3.  the Galaxy Linux container exists.
4.  the X11 server is running.
5.  the PRoot session shares the required X11 temporary/socket path.
6.  `DISPLAY` is set by the launcher.

## Audio does not work

Restart the Galaxy Linux session:

``` bash
~/stop-galaxy-linux
~/start-galaxy-linux
```

## Developer tool missing

Run:

``` bash
~/galaxy-dev-check
```

Then rerun the developer profile if required:

``` bash
./install.sh --profile developer --repair
```

------------------------------------------------------------------------

# Uninstall

From a cloned copy of the repository:

``` bash
./uninstall.sh
```

Read the confirmation carefully.

> \[!WARNING\] Removing the Arch container permanently destroys files
> stored exclusively inside that container. Back up anything important
> first.

The uninstaller should not be treated as an Android/Termux reset tool.
Shared Termux packages may also be used by unrelated projects.

------------------------------------------------------------------------

# Device Compatibility

Galaxy Linux is intended to become community-tested rather than relying
on vague claims such as "works on all Samsung phones."

Useful device reports include:

  Field            Example
  ---------------- -----------------------------------
  Device           Galaxy S-series / Tab S-series
  SoC              Snapdragon / Exynos
  Android          Version
  One UI           Version
  Termux           Version/source
  Termux:X11       Version
  Display          Phone / DeX / external resolution
  XFCE             Working / partial / failed
  Audio            Working / partial / failed
  GPU renderer     Reported renderer
  Keyboard/mouse   Working / issues
  Notes            Known problems or fixes

See `docs/DEVICE-REPORT.md` for the reporting format.

------------------------------------------------------------------------

# Repository Layout

``` text
galaxy-linux/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── SECURITY.md
├── install.sh
├── uninstall.sh
├── bin/
│   ├── start-galaxy-linux
│   ├── stop-galaxy-linux
│   └── galaxy-dev-check
├── profiles/
│   └── developer/
│       └── bootstrap.sh
├── scripts/
│   └── arch-bootstrap.sh
└── docs/
    ├── DEVELOPER-EDITION.md
    ├── DEVICE-REPORT.md
    └── WORKFLOW.md
```

------------------------------------------------------------------------

# Versioning

The recommended public installer is pinned to a release:

``` text
v0.1.1
```

Using a tagged release gives users a reproducible entry point and
prevents an installation command copied months ago from unexpectedly
following a changed `main` branch.

Developers can clone the repository directly when testing current
development:

``` bash
git clone https://github.com/Neclonesoul/galaxy-linux.git
cd galaxy-linux
```

------------------------------------------------------------------------

# Security

Piping remote scripts into a shell is convenient but carries risk.

Before using the one-line installer, security-conscious users should
inspect the tagged script first or clone the repository and run it
locally:

``` bash
git clone --branch v0.1.1 --depth 1 \
  https://github.com/Neclonesoul/galaxy-linux.git

cd galaxy-linux
less install.sh
./install.sh
```

Report security-sensitive issues according to `SECURITY.md`.

------------------------------------------------------------------------

# Contributing

Testing across different Samsung and Android hardware is particularly
valuable.

Useful contributions include:

-   verified device reports
-   installer fixes
-   Termux:X11 compatibility improvements
-   documentation
-   graphics compatibility findings
-   DeX behaviour reports
-   reproducible bug reports
-   Developer Edition improvements

See `CONTRIBUTING.md` before submitting changes.

------------------------------------------------------------------------

# Project Status

**Early public release / active development.**

Galaxy Linux should currently be treated as an experimental workstation
project rather than a production operating system.

The immediate goals are:

1.  reliable installation on supported ARM64 Android hardware;
2.  repeatable Arch + XFCE startup through Termux:X11;
3.  documented Samsung DeX compatibility;
4.  reproducible device testing;
5.  a useful Developer Edition;
6.  conservative, evidence-based GPU support.

------------------------------------------------------------------------

# Acknowledgements

Galaxy Linux builds on the work of the wider open-source ecosystem,
particularly:

-   Termux
-   Termux:X11
-   PRoot
-   PRoot-Distro
-   Arch Linux / Arch Linux ARM
-   XFCE
-   Mesa
-   the many upstream projects included in Developer Edition

Please support and respect the upstream projects and their licenses.

------------------------------------------------------------------------

## License

See [`LICENSE`](LICENSE) for this repository's licensing terms.

------------------------------------------------------------------------

**Galaxy Linux**

*Your phone already has the computer. This project gives it a Linux
desk.*
