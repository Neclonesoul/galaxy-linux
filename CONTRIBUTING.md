# Contributing

Contributions are welcome, especially reproducible Samsung Galaxy device reports and small compatibility fixes.

Please keep installer changes conservative:

- Do not assume every Samsung device uses Qualcomm/Adreno.
- Do not silently delete user packages or Termux configuration.
- Pin major external rootfs/image inputs where practical.
- Make experimental GPU paths opt-in or gracefully fall back.
- Run `bash -n` against every shell script before opening a pull request.
- Explain the Galaxy model/SoC used for hardware-specific changes.

For compatibility reports, use `docs/DEVICE-REPORT.md`.
