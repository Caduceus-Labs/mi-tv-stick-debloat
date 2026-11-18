#!/usr/bin/env bash
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../lib.sh"

echo "Connecting to $STICK_IP:5555 ..."
"$ADB" connect "$STICK_IP:5555" || true
"$ADB" devices -l
echo
echo "If the device shows 'unauthorized', accept the 'Allow USB debugging?' prompt on the TV"
echo "(tick 'Always allow from this computer')."