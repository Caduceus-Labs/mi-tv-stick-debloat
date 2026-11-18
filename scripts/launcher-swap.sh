#!/usr/bin/env bash
# Swap to Projectivy Launcher (install it from the stick's Play Store first).
# Sets Projectivy as default Home, verifies, then disables the stock launcher.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../lib.sh"

# Open the Play Store listing so the user can tap Install
"$ADB" connect "$STICK_IP:5555" >/dev/null 2>&1 || true
echo "Opening Projectivy's Play Store page on the TV (tap Install there, then re-run this script)..."
"$ADB" shell am start -a android.intent.action.VIEW -d "market://details?id=com.spocky.projengmenu" || true

if ! "$ADB" shell pm list packages | grep -q com.spocky.projengmenu; then
  echo "Projectivy not installed yet. Install it from the Play Store, then re-run." >&2
  exit 1
fi

echo "Setting Projectivy as default Home..."
"$ADB" shell cmd package set-home-activity com.spocky.projengmenu/.ui.home.MainActivity
"$ADB" shell cmd shortcut get-default-launcher
"$ADB" shell am start -n com.spocky.projengmenu/.ui.home.MainActivity >/dev/null 2>&1 || true
sleep 3

echo "Disabling stock launcher..."
"$ADB" shell pm disable-user --user 0 com.google.android.tvlauncher
echo "Default Home is now:"
"$ADB" shell cmd shortcut get-default-launcher
echo
echo "Done. Undo: set-home-activity back to tvlauncher/.MainActivity + pm enable com.google.android.tvlauncher"