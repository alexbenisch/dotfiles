#!/bin/bash
# Install the udev rule for the Grundig Digta Foot Control 540 USB pedal.
#
# The pedal is a vendor HID device with no evdev node; voxtype-pedal reads it
# via /dev/grundig-pedal. The rule lives in /etc, outside chezmoi's reach, so
# this script installs it. Edit the rule here and chezmoi re-runs the script
# (run_onchange_ hashes its own contents). See docs/voxtype-digital-mic.md.
set -euo pipefail

RULE=/etc/udev/rules.d/70-grundig-footpedal.rules
CONTENT='# Grundig Digta Foot Control 540 USB: give the logged-in user access to its hidraw node
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="15d8", ATTRS{idProduct}=="0024", TAG+="uaccess", SYMLINK+="grundig-pedal"'

# Already installed and identical: nothing to do, and no sudo prompt.
if [ -f "$RULE" ] && [ "$(cat "$RULE")" = "$CONTENT" ]; then
  exit 0
fi

printf '%s\n' "$CONTENT" | sudo tee "$RULE" >/dev/null
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=hidraw
echo "udev-grundig-footpedal: installed $RULE"
