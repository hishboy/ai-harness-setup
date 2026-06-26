#!/bin/sh
# opencode harness launch — runs on EVERY launch, as root, cwd /workspace, sh.
# opencode config is entirely FILE-based (opencode.json, written by bootstrap.sh)
# — there is no env-based config, and theme:"system" makes the TUI follow the
# terminal, so there is no per-launch rewrite and nothing to export here.
exec opencode
