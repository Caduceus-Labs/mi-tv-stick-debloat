#!/usr/bin/env bash
# Shared helper: loads .env, resolves adb, exposes $ADB and $STICK_IP.
LIB_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$LIB_ROOT/.env" ]; then
  set -a; . "$LIB_ROOT/.env"; set +a
fi

: "${STICK_IP:?STICK_IP not set. Copy .env.example to .env and set your stick IP.}"

if [ -z "${ADB:-}" ]; then
  if command -v adb >/dev/null 2>&1; then
    ADB=adb
  elif [ -x "$HOME/platform-tools/adb" ]; then
    ADB="$HOME/platform-tools/adb"
  else
    echo "adb not found. Install platform-tools or set ADB in .env." >&2
    exit 1
  fi
fi