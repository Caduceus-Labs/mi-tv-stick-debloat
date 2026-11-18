#!/usr/bin/env bash
# Batch 2: PatchWall, OTA updater, unused preloads.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../lib.sh"

PKGS="com.google.android.videos
com.dsi.ant.service.socket
com.dsi.ant.plugins.antplus
com.mitv.download.service
com.mitv.tvhome.atv
com.mitv.tvhome.michannel
com.mitv.dream
com.xiaomi.mitv.updateservice"

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
echo "Verifying:"
"$ADB" shell pm list packages -d | grep -E "videos|dsi.ant|download.service|tvhome|mitv.dream|mitv.updateservice" || true
echo
echo "Done. REBOOT the stick to stop any already-running processes."