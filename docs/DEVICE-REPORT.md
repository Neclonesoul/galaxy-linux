# Device Compatibility Report

Copy this template into a GitHub issue.

```text
Galaxy model:
Model number:
Region:
Android version:
One UI version:
SoC:
GPU:
RAM:
Termux source/version:
Termux:X11 version:
External display / DeX:
Display resolution:

Install completed: yes/no
XFCE launches: yes/no
Keyboard/mouse: working/issues
Audio: working/issues
Firefox: working/issues

Host Vulkan test (if performed):
Linux OpenGL renderer (if performed):

Exact error/output:

Notes:
```

Useful Termux commands:

```bash
getprop ro.product.model
getprop ro.product.device
getprop ro.soc.model
getprop ro.board.platform
getprop ro.hardware.egl
uname -m
termux-info
```
