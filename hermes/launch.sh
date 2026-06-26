#!/bin/sh
# Hermes harness launch — runs on EVERY launch, as root, cwd /workspace, sh.
# Hermes is fully FILE-based (config.yaml), so there is NO env-based config to
# export here. We only re-sed the display.skin line from the CURRENT theme so a
# TRIBES_THEME toggle takes effect on relaunch. The ^  skin: anchor matches both
# the initial __TRIBES_SKIN__ placeholder and a previously-set value, so relaunch
# toggles work. Then exec hermes with --yolo (bypasses dangerous-command
# approvals; the microVM is the security boundary).
skin=$([ "$TRIBES_THEME" = light ] && echo daylight || echo default)
sed -i "s|^  skin:.*|  skin: $skin|" /workspace/.hermes/config.yaml

exec hermes --yolo
