# Xiaohongshu (rednote) in Waydroid on CachyOS

Recorded on 2026-11-17. Xiaohongshu is installed and its launch command completes,
but Android's crash buffer shows repeated native crashes in `libhoudini.so`.
Successful login and video playback have not been verified for this app.

## Observed installation

| Item | Value |
| :-- | :-- |
| Host | CachyOS x86-64, KDE Plasma on Wayland |
| Waydroid | 1.6.3, VANILLA system, MAINLINE vendor |
| Android | 13, API 33 |
| App / package | rednote / `com.xingin.xhs` |
| App version | 9.54.1, version code 9541801 |
| App SDK | Minimum 21, target 36 |
| Installed native ABI | `arm64-v8a` |
| Native bridge | `libhoudini.so` |
| fdsan policy | `warn_once` |

The Android images use these channels:

```text
https://ota.waydro.id/system/lineage/waydroid_x86_64/VANILLA.json
https://ota.waydro.id/vendor/waydroid_x86_64/MAINLINE.json
```

For initial Waydroid installation, networking, and Chinese input, see
[the existing setup guide](waydroid-soul.md). Its original ARM translation
instructions use `libndk`; the current environment inspected here uses Houdini.
Do not treat those two translator configurations as interchangeable.

## Android configuration

The inspected `/var/lib/waydroid/waydroid.cfg` contains this configuration under
`[properties]`. These are recorded environment settings, not a proven fix for
Xiaohongshu's crashes or login checks:

```ini
[properties]
ro.product.cpu.abilist = x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.product.cpu.abilist32 = x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64 = x86_64,arm64-v8a
ro.dalvik.vm.native.bridge = libhoudini.so
ro.enable.native.bridge.exec = 1
ro.vendor.enable.native.bridge.exec = 1
ro.vendor.enable.native.bridge.exec64 = 1
ro.ndk_translation.version = 0.2.3
ro.dalvik.vm.isa.arm = x86
ro.dalvik.vm.isa.arm64 = x86_64
debug.fdsan = warn_once
```

`ro.ndk_translation.version` is present in the configuration even though the
selected bridge is Houdini; its presence does not establish that libndk is active.
The same properties appear without spaces around `=` in the generated
`/var/lib/waydroid/waydroid_base.prop`. The container uses `suspend_action = freeze`.

Keep backups before changing shared Android properties. A translator change
affects every app in this container and requires a container restart. The
configuration above was inspected, not applied as part of this documentation.

## Install and launch

The repository provides an installer for both Xiaohongshu and Soul. After
initializing Waydroid, installing ARM translation, and starting the desktop
session, run from the repository root:

```bash
./waydroid/setup.sh
# Or install only Xiaohongshu:
./waydroid/setup.sh --app xiaohongshu
```

Xiaohongshu defaults to the publisher's [9.54.1 APK](https://redgray.xhscdn.com/ui/androidPublish/prod/xhs/channel/apk/9.54.1/9541801/v9541801-xhs-share_package_common_X64.apk),
linked by the [publisher's download flow](https://www.xiaohongshu.com/download)
on 2026-11-17 and served over HTTPS. This URL pins the download to 9.54.1.
Use `--xiaohongshu-url URL` to select another HTTPS publisher APK, or
`--xiaohongshu-apk PATH` to install a local publisher APK instead.
It skips already installed packages, validates
all selected APK archives before installation, prints their SHA256 hashes,
waits for new packages to appear, and refreshes KDE's cache when available.
Soul downloads from its official ARM64 endpoint unless `--soul-apk` is supplied.
Use `./waydroid/setup.sh --help` for all options. The installer does not change
the Android image, translator, firewall, login checks, or app data. It does not
upgrade existing apps. Archive checks detect damaged downloads, not publisher
signatures; obtain APKs from the publishers.

Run desktop commands as the logged-in Wayland user. Use distribution Python to
avoid selecting a Python installation without Waydroid's D-Bus modules:

```bash
/usr/bin/python3 /usr/bin/waydroid status

# For a fresh installation, supply an APK obtained from the app publisher.
# The original APK download URL and checksum were not recorded in this session.
/usr/bin/python3 /usr/bin/waydroid app install /path/to/rednote.apk

# Installation can complete asynchronously; confirm it in the app list.
/usr/bin/python3 /usr/bin/waydroid app list
/usr/bin/python3 /usr/bin/waydroid app launch com.xingin.xhs
```

The app was already installed when inspected. Installation is a reproduction
step; launching the existing installation and checking its metadata were tested.
A zero exit status from the launch command does not prove the UI stays running.

## Find the app in KDE

The generated desktop entry is
`~/.local/share/applications/waydroid.com.xingin.xhs.desktop`. Its observed fields
include:

```ini
[Desktop Entry]
Type=Application
Name=rednote
Exec=waydroid app launch com.xingin.xhs
Categories=X-WayDroid-App;
X-Purism-FormFactor=Workstation;Mobile;
Actions=app-settings;

[Desktop Action app-settings]
Name=App Settings
Exec=waydroid app intent android.settings.APPLICATION_DETAILS_SETTINGS package:com.xingin.xhs
```

The generated `Icon` points to
`~/.local/share/waydroid/data/icons/com.xingin.xhs.png` using an absolute path.
Keep the generated icon path when editing the entry; desktop files do not expand
`~` or `$HOME` in `Icon` values. Search KDE Applications for **rednote**.
The entry invokes `waydroid`, so its desktop PATH must select a working launcher
or distribution Python environment as described in the setup guide.

If a valid installed entry is missing from the menu, refresh KDE's cache:

```bash
desktop-file-validate "$HOME/.local/share/applications/waydroid.com.xingin.xhs.desktop"
kbuildsycoca6 --noincremental
```

## Verify configuration and diagnose crashes

The following read-only commands require Android administrator access.
`pkexec` opens a system authentication prompt; `sudo` is an alternative.
Desktop session commands above should remain unprivileged.

```bash
pkexec /usr/bin/python3 /usr/bin/waydroid shell -- sh -c '
  dumpsys package com.xingin.xhs |
    grep -E "versionCode=|versionName=|primaryCpuAbi=|secondaryCpuAbi="
  getprop ro.build.version.release
  getprop ro.build.version.sdk
  getprop ro.dalvik.vm.native.bridge
  getprop ro.product.cpu.abilist
  getprop debug.fdsan
'

# Inspect complete crash records: check that Cmdline names com.xingin.xhs.
pkexec /usr/bin/python3 /usr/bin/waydroid shell -- logcat -d -b crash -t 500
```

Observed crash records name `com.xingin.xhs`, a `Thread-3438` thread, and
`SEGV_MAPERR`; their native backtraces enter `/system/lib64/libhoudini.so`.
Some records report a process uptime of one second. This establishes a native
translation failure, but does not establish its underlying cause or a login
restriction bypass. No Xiaohongshu APK, native library, or codec cache was patched
in this session. Retest launch stability before diagnosing account login or video
playback. Keep account identifiers, credentials, screenshots, and full private
logs out of this repository.
