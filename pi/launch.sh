#!/bin/sh
# Pi harness launch — runs on EVERY launch, as root, cwd /workspace, sh.
# Pi is fully FILE-based (bootstrap.sh wrote models.json + settings.json), so
# there is NO env-based config to export here. Pi's theme is "light/dark" (its
# Automatic mode — it queries OSC at startup and follows the terminal's
# light/dark), so no per-launch theme rewrite is needed either. Just exec.
exec pi
