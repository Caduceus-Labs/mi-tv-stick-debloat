#!/usr/bin/env bash
# Re-enable every package this repo disables.
set -euo pipefail
source "$(cd "$(dirname "$0")" && pwd)/../lib.sh"

PKGS="com.miui.tv.analytics
com.xiaomi.android.tvsetup.partnercustomizer
android.autoinstalls.config.xiaomi.mibox3
com.google.android.tvrecommendations
com.google.android.videos
com.dsi.ant.service.socket
com.dsi.ant.plugins.antplus
com.mitv.download.service
com.mitv.tvhome.atv
com.mitv.tvhome.michannel
com.mitv.dream
com.xiaomi.mitv.updateservice"

"$ADB" connect "$STICK_IP:5555" >/dev/null 2>&1 || true

for p in $PKGS; do
  echo "--- enabling $p ---"
  "$ADB" shell pm enable "$p" || true
done
echo
echo "Done. Reboot the stick for a clean state."