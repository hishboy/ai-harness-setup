#!/bin/sh
# Hermes harness launch — runs on EVERY launch, as root, cwd /workspace, sh.
# Hermes is fully FILE-based (config.yaml), so there is NO env-based config to
# export here. We only re-sed the display.skin line from the CURRENT theme so a
# TRIBES_THEME toggle takes effect on relaunch. The ^  skin: anchor matches both
# the initial __TRIBES_SKIN__ placeholder and a previously-set value, so relaunch
# toggles work. Then exec hermes with --yolo (bypasses dangerous-command
# approvals; the microVM is the security boundary).
# The ^  skin: line is present in BOTH configs bootstrap.sh can produce: the full
# proxy config and the BYO skin-only config (display block only). Guard on [ -f ]
# anyway so a missing file never makes sed -i create/break one.
if [ -f /workspace/.hermes/config.yaml ]; then
  skin=$([ "$TRIBES_THEME" = light ] && echo daylight || echo default)
  sed -i "s|^  skin:.*|  skin: $skin|" /workspace/.hermes/config.yaml
fi

exec hermes --yolo
