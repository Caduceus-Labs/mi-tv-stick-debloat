# mi-tv-stick-debloat

Debloat + tune a laggy **Xiaomi Mi TV Stick** (`MiTV-AESP0`, codename `aquaman`, 1 GB RAM, Android 9) over **ADB — no root**. Measured before/after included.

## Why this exists

On a 1 GB stick, *"sometimes laggy"* is almost never the firmware version. It's:

1. **RAM exhaustion → swap thrash** on slow eMMC (the freeze-on-scroll feeling), and
2. **Background wakeups** — OEM telemetry bursts, PatchWall, preloads, stock launcher.

Rolling back firmware alone doesn't fix it. This repo disables the offenders **reversibly** and locks the rollback so OTA can't re-bloat you.

### Measured result (reference device)

| Metric | Baseline | After | Change |
|---|---|---|---|
| Load (4 cores) | 8.0 | **2.78** | ↓ 65% |
| Swap used (eMMC thrash) | 315 MB | **142 MB** | ↓ 55% |
| MemAvailable | 202 MB | **239 MB** | ↑ 37 MB |
| Free RAM | 65 MB | 76 MB | ↑ |
| `com.miui.tv.analytics` | 202% CPU spikes | gone | — |

## 1. Install adb (macOS, no brew)

```bash
cd /tmp && curl -sL -o pt.zip https://dl.google.com/android/repository/platform-tools-latest-darwin.zip \
 && unzip -oq pt.zip -d ~ && ~/platform-tools/adb version
```

## 2. Enable ADB on the stick

- Settings → **Device Preferences → About** → tap **Build** 7× → *"You are now a developer!"*
- **Developer options → USB debugging → ON**
  - There is **no** separate "wireless/network debugging" entry on the Mi TV Stick. Turning on USB debugging makes `adbd` listen on **5555 over WiFi**.
- **Reboot the stick** — `adbd` usually only binds 5555 on boot.

## 3. Configure + connect

```bash
cp .env.example .env      # then set STICK_IP
./scripts/connect.sh      # first connection shows "Allow USB debugging?" on the TV — tick "Always allow" and accept
```

`failed to authenticate` / `unauthorized` = the allow-prompt is waiting on the TV. Accept it with the remote.

## 4. Diagnose

```bash
./scripts/diagnose.sh     # load / RAM / swap / top CPU
```

Read it like: low `MemFree` + `SwapFree` dropping + `kswapd0`/`ksmd` high = swap thrash. A one-off CPU spike (e.g. `com.miui.tv.analytics` at 200%+) **is** the "sometimes".

## 5. Debloat (reversible — backs up first)

```bash
./scripts/debloat-telemetry.sh   # batch 1: Xiaomi telemetry, partner customizer, auto-install config, launcher recs
./scripts/debloat-bloat.sh       # batch 2: PatchWall, OTA updater, Play Movies, ANT+, Mi downloader, Mi Dream
```

Each script backs up the package list to `~/tvstick_backup_<timestamp>/` before touching anything.

**`pm disable-user` does not kill an already-running process — reboot after applying** to realize the RAM win.

## 6. Undo

```bash
./scripts/undo.sh   # re-enables every package this repo disables
```

## Package table (reference device)

### Safe to disable (no feature loss)
| Package | What it is |
|---|---|
| `com.miui.tv.analytics` | Xiaomi BI telemetry (CPU spikes) |
| `com.xiaomi.android.tvsetup.partnercustomizer` | Setup bloat (*persistent* — stays resident regardless) |
| `android.autoinstalls.config.xiaomi.mibox3` | Re-installs preloads on boot |
| `com.google.android.tvrecommendations` | Stock-launcher recommendation rows |
| `com.mitv.tvhome.atv` / `com.mitv.tvhome.michannel` | PatchWall home + content rows |
| `com.xiaomi.mitv.updateservice` | OTA updater ← **disable to lock a firmware rollback** |
| `com.google.android.videos` | Google Play Movies |
| `com.dsi.ant.service.socket` / `com.dsi.ant.plugins.antplus` | ANT+ fitness (useless on TV) |
| `com.mitv.download.service` | Mi download service |
| `com.mitv.dream` | Mi screensaver (Google Backdrop stays active) |
| `com.mitv.videoplayer` | Mi video player (only if no local playback) |

### Keep (disabling breaks something)
`com.google.android.gms`, `com.android.vending` (Play Store), `com.google.android.tv`, `com.google.android.apps.mediashell` (Cast), `com.mitv.milinkservice` (Mi cast), `com.google.android.inputmethod.latin`, setup wizards.

### Never touch
`mitv.service` (core), `com.xiaomi.mitv.res` (framework resources), `partnercustomizer` (persistent — can't kill without root anyway).

## Optional: lighter launcher
Replacing `com.google.android.tvlauncher` (Projectivy / FLauncher) frees ~52 MB + its 70% CPU bursts. Install the new launcher, set it as Home, then disable the old one.

## Pitfalls
- `pm disable-user` ≠ kill. Running processes persist until **reboot**.
- **Persistent** system apps (`dumpsys package <pkg> | grep -i persistent`) can't be force-stopped without root — they respawn. Harmless if idle; don't chase them.
- Thermal zones (`/sys/class/thermal/*`) are **root-only** on user builds — you can't read temps. Watch `scaling_max_freq` instead; recommend a HDMI extension + good 5 V/1 A+ adapter as a physical fix.
- `adb connect` may hang on a stale IP — verify with ARP first; DHCP moves it.
- Prefer `disable-user` over `pm uninstall --user 0` (uninstall is only restorable via `pm install-existing`).
- Keep the device IP in `.env` (gitignored) — never commit it.

## AI usage

This repo was created with AI assistance (**Hermes Agent**, by Nous Research) during a live debugging session on a real Mi TV Stick. The human author directed the work, reviewed every change, and ran it on the device; the AI handled the ADB diagnosis, package classification, and script authoring. The before/after numbers in the table above are **real on-device measurements**, not estimates.

Treat the package table as a starting point, not gospel — run `pm list packages` to confirm what's on *your* stick before disabling anything, and use `./scripts/undo.sh` if something misbehaves. All changes are reversible.