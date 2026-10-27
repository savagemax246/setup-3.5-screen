# PiScreen-64

**A modern installer for generic 3.5-inch SPI touchscreens on Raspberry Pi OS 64-bit.**

PiScreen-64 helps bring older 3.5-inch SPI touchscreen displays back to life on modern Raspberry Pi installations, without relying on outdated Buster-era installation scripts or legacy driver packages.

Designed for headless installations, including Raspberry Pi OS Lite.

## Features

- Supports 480×320 SPI touchscreen configurations.
- Uses the Raspberry Pi `piscreen` device-tree overlay.
- Uses the kernel DRM display driver.
- Supports ILI9486 display controllers and XPT2046 touch controllers on compatible display boards.
- Designed for 64-bit Raspberry Pi OS.
- Works without a desktop environment.
- Automatically detects the boot configuration directory.
- Creates timestamped configuration backups.
- Optional framebuffer console mapping.
- Includes an undo option to restore the previous display configuration.

## Compatibility

| Component | Support |
|---|---|
| Raspberry Pi 3B+ | Tested |
| Raspberry Pi OS Lite | Tested |
| Debian Trixie-based Raspberry Pi OS | Tested |
| 64-bit ARM (ARM64) | Tested |
| 3.5-inch 480×320 SPI displays | Intended |
| ILI9486 | Intended |
| XPT2046 touch | Intended |
| Headless installations | Supported |

**Tested configuration:** Raspberry Pi 3 Model B+ running Raspberry Pi OS Lite 64-bit (Trixie).

Different manufacturers use different wiring, display controllers, and touch configurations. Compatibility with every generic display clone is not guaranteed.

## Installation

### 1. Update Raspberry Pi OS

```bash
sudo apt update
sudo apt full-upgrade -y
```

### 2. Download the installer

Download `setup-3.5-screen.sh` from this repository.

### 3. Run the installer

Run as your normal user:

```bash
bash setup-3.5-screen.sh
```

The installer will:

1. Locate your Raspberry Pi boot configuration.
2. Check for the `piscreen` overlay.
3. Back up your existing `config.txt`.
4. Remove previous display configuration blocks created by this installer.
5. Enable SPI.
6. Configure the display overlay.
7. Ask whether you want to reboot.

## Optional: Enable framebuffer console

If the display remains blank after installation, try:

```bash
bash setup-3.5-screen.sh --fbcon
```

This also adds:

```text
fbcon=map:1
```

to the kernel command line.

Reboot to apply the changes.

## Undo / Restore

To restore the most recent `config.txt` backup:

```bash
bash setup-3.5-screen.sh --undo
```

**Note:** The current undo implementation restores `config.txt`, but does not yet restore a modified `cmdline.txt`.

## Verify the display

After reboot, check for framebuffer devices:

```bash
ls /dev/fb*
```

Check the kernel messages:

```bash
dmesg | grep -i -E 'ili9486|piscreen|drm|spi'
```

You can also check whether SPI is enabled:

```bash
ls /dev/spidev*
```

## Configuration

The installer adds the following configuration to `config.txt`:

```ini
# 35screen-begin
[all]
dtparam=spi=on
dtoverlay=piscreen,drm,speed=16000000
# 35screen-end
```

Display configuration is handled through the Raspberry Pi device-tree overlay and kernel display support.

## Requirements

- Raspberry Pi running Raspberry Pi OS.
- SPI-compatible 3.5-inch display.
- Available `piscreen` device-tree overlay.
- Administrative privileges through `sudo`.
- Internet access for initial operating-system updates.

## Troubleshooting

**The screen stays blank**

Try the optional `--fbcon` mode and inspect the kernel messages.

**The overlay cannot be found**

Update your Raspberry Pi OS installation:

```bash
sudo apt update
sudo apt full-upgrade
```

**No framebuffer device appears**

Check the kernel messages and confirm that the display overlay loaded successfully.

**Touchscreen does not respond**

Display support does not automatically guarantee touch support. Touch-controller configuration and device-tree support may vary between display boards.

## Contributing

Testing on additional Raspberry Pi models, operating-system versions, and display manufacturers is welcome.

Please include:

- Raspberry Pi model.
- Raspberry Pi OS version and architecture.
- Display manufacturer and model.
- Whether the display works.
- Whether touchscreen input works.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

**PiScreen-64**

Modern Raspberry Pi software. Older SPI displays. No desktop required.
