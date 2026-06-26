#!/bin/sh
# Cline harness launch — runs on EVERY launch, as root, cwd /workspace, sh.
# Cline's auth is a persisted file written by bootstrap.sh, so there is no
# env-based config to export here. -i opens the interactive TUI; --auto-approve
# true runs without prompting (the VM is the security boundary).

exec cline -i --auto-approve true
