#!/bin/sh
# OpenClaw harness launch — runs on EVERY launch, as root, cwd /workspace, sh.
# OpenClaw config is entirely FILE-based (exec-approvals.json + openclaw.json,
# written by bootstrap.sh) — there is no env-based config and no theme knob — so
# there is nothing to export here. `tui --local` opens the local agent TUI
# directly against the pre-seeded config.
exec openclaw tui --local
