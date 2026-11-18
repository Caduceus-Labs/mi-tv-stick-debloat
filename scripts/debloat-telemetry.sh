#!/usr/bin/env bash
# Batch 1: Xiaomi telemetry + setup bloat + launcher recommendations.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../lib.sh"

PKGS="com.miui.tv.analytics
com.xiaomi.android.tvsetup.partnercustomizer
android.autoinstalls.config.xiaomi.mibox3
com.google.android.tvrecommendations"

"$ADB" connect "$STICK_IP:5555" >/dev/null 2>&1 || true

BK="$HOME/tvstick_backup_$(date +%Y%m%d_%H%M)"
mkdir -p "$BK"
"$ADB" shell pm list packages       > "$BK/all_packages.txt"
"$ADB" shell pm list packages -d    > "$BK/disabled_before.txt"
echo "Backup written to $BK"

for p in $PKGS; do
  echo "--- $p ---"
  "$ADB" shell pm disable-user --user 0 "$p"
done
echo
echo "Verifying (all should appear):"
"$ADB" shell pm list packages -d | grep -E "miui.tv.analytics|partnercustomizer|autoinstalls|tvrecommendations" || true
echo
echo "Done. REBOOT the stick to stop any already-running processes."