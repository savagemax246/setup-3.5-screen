#!/usr/bin/env bash
# Setup for the generic 3.5" 480x320 SPI touch screen (ILI9486 display + XPT2046 touch;
# JUN-ELECTRON and Waveshare (A)/(B)-style clones) on a Raspberry Pi.
# Uses the kernel's built-in DRM driver through the official Raspberry Pi "piscreen" overlay.
# Worked on a Pi 3B+ with Raspberry Pi OS Lite (Trixie).
#
# Usage (run as your normal user on the Pi):
#   bash setup-3.5-screen.sh            install
#   bash setup-3.5-screen.sh --fbcon    install + force the text console onto the screen
#                                       (only needed if the screen stays blank after reboot)
#   bash setup-3.5-screen.sh --undo     restore the most recent config backup
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Run this as your normal user (it calls sudo itself)."
  exit 1
fi

CFG=/boot/firmware/config.txt
[ -f "$CFG" ] || CFG=/boot/config.txt
CMD=/boot/firmware/cmdline.txt
[ -f "$CMD" ] || CMD=/boot/cmdline.txt
[ -f "$CFG" ] || { echo "Can't find config.txt"; exit 1; }

MODE="${1:-install}"
STAMP="$(date +%Y%m%d-%H%M%S)"

ask_reboot() {
  read -r -p "Reboot now? [y/N] " ans
  if [ "$ans" = "y" ]; then sudo reboot; fi
}

if [ "$MODE" = "--undo" ]; then
  BACKUP="$(ls -t "$CFG".bak-screen-* 2>/dev/null | head -n 1 || true)"
  [ -n "$BACKUP" ] || { echo "No backup found next to $CFG."; exit 1; }
  sudo cp "$BACKUP" "$CFG"
  echo "Restored $BACKUP"
  ask_reboot
  exit 0
fi

echo "[1/3] Checking the piscreen overlay exists..."
if ! ls /boot/firmware/overlays /boot/overlays 2>/dev/null | grep -qi '^piscreen'; then
  echo "The piscreen overlay wasn't found. Update first:"
  echo "  sudo apt update && sudo apt full-upgrade"
  exit 1
fi

echo "[2/3] Backing up and updating $CFG..."
sudo cp "$CFG" "$CFG.bak-screen-$STAMP"
# Remove any earlier screen setup blocks (this script's or the old Waveshare (G) attempt)
sudo sed -i '/# waveshare-35g-begin/,/# waveshare-35g-end/d;/# 35screen-begin/,/# 35screen-end/d' "$CFG"
sudo tee -a "$CFG" >/dev/null <<'EOF'

# 35screen-begin
[all]
dtparam=spi=on
dtoverlay=piscreen,drm,speed=16000000
# 35screen-end
EOF

echo "[3/3] Console settings..."
if [ "$MODE" = "--fbcon" ] && [ -f "$CMD" ]; then
  if ! grep -q 'fbcon=map:1' "$CMD"; then
    sudo cp "$CMD" "$CMD.bak-screen-$STAMP"
    sudo sed -i '1 s/$/ fbcon=map:1/' "$CMD"
    echo "Added fbcon=map:1 to $CMD"
  fi
else
  echo "Skipped (not needed unless the screen stays blank; rerun with --fbcon)."
fi

echo
echo "Done. Backup saved as $CFG.bak-screen-$STAMP"
echo "After reboot, check with:  ls /dev/fb* ; dmesg | grep -i ili9486"
ask_reboot
exit 0
