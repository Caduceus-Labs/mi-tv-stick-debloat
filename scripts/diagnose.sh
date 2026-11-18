#!/usr/bin/env bash
# Snapshot of load / RAM / swap / top CPU — the numbers that reveal lag causes.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../lib.sh"

"$ADB" connect "$STICK_IP:5555" >/dev/null 2>&1 || true
echo "Device: $("$ADB" shell getprop ro.product.model | tr -d '\r')  (uptime: $("$ADB" shell uptime | tr -d '\r'))"
echo "=== LOAD ==="; "$ADB" shell uptime
echo "=== MEMORY ==="; "$ADB" shell cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable|SwapTotal|SwapFree"
echo "=== SWAP USED ==="; "$ADB" shell cat /proc/meminfo | awk '/SwapTotal/{t=$2}/SwapFree/{f=$2}END{print (t-f)" kB used"}'
echo "=== TOP (cpu) ==="; "$ADB" shell top -n 1 -b 2>/dev/null | sed -n '2,12p'