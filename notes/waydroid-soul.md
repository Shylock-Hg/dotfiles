# Waydroid, Soul, and Chinese input on CachyOS

Tested on 2026-11-15 with CachyOS x86-64, an AMD GPU, a Wayland session,
Waydroid 1.6.3, Android 13 (LineageOS 20 VANILLA), and Fcitx5 Android 0.1.3.
The repository's Arch/CachyOS package setup already installs `waydroid`.
These are manual workstation configuration steps; they are not run by `setup.sh`.
Run user commands from the logged-in Wayland desktop, not a root shell.

## Packages, mirrors, and the running kernel

```bash
echo "$XDG_SESSION_TYPE"  # wayland
uname -r
ls /usr/lib/modules
sudo pacman -Syu --needed waydroid
```

If the kernel was upgraded, reboot before starting Android. During this setup,
the running kernel was `7.3.1-1-cachyos`, but installed modules were for
`7.3.4-1-cachyos`. Waydroid's network script failed with an nftables
`No such file or directory` error because needed modules could not load.
Booting the installed kernel resolved it.

The first Arch mirror, NJU, had an expired TLS certificate. WSYU had the fastest
successful database response among the configured Arch mirrors and was moved
to the first line of `/etc/pacman.d/mirrorlist`:

```text
Server = https://mirrors.wsyu.edu.cn/archlinux/$repo/os/$arch
```

USTC remained the CachyOS mirror in the separate files:

```text
# /etc/pacman.d/cachyos-mirrorlist
Server = https://mirrors.ustc.edu.cn/cachyos/repo/$arch/$repo
# /etc/pacman.d/cachyos-v4-mirrorlist
Server = https://mirrors.ustc.edu.cn/cachyos/repo/$arch_v4/$repo
```

Back up a mirrorlist before editing it. Mirror health changes; these are the
observed settings, not a permanent speed ranking. Refresh packages with a full
upgrade rather than installing against a partially refreshed rolling system.

## Use the distribution Python

`/usr/bin/waydroid` uses `#!/usr/bin/env python3`. This workstation puts
`~/.local/py/bin` before `/usr/bin`, so invoking it directly selected a custom
Python without the distribution's D-Bus bindings (`No module named 'dbus'`).
Use `/usr/bin/python3 /usr/bin/waydroid`, or install this user launcher:

```bash
mkdir -p "$HOME/.local/bin"
cat > "$HOME/.local/bin/waydroid" <<'EOF'
#!/bin/sh
exec /usr/bin/python3 /usr/bin/waydroid "$@"
EOF
chmod +x "$HOME/.local/bin/waydroid"
command -v waydroid  # should resolve to ~/.local/bin/waydroid
/usr/bin/python3 -c 'import dbus, gi, gbinder'
```

The desktop launchers use `waydroid` too, so ensure `~/.local/bin` is in the
desktop session's PATH. Keep systemd's container service on the system PATH.

## Initialize Android and ARM translation

```bash
sudo env PATH=/usr/bin:/usr/sbin /usr/bin/python3 /usr/bin/waydroid init -s VANILLA
```

The official channels used were:

```text
System: https://ota.waydro.id/system/lineage/waydroid_x86_64/VANILLA.json
Vendor: https://ota.waydro.id/vendor/waydroid_x86_64/MAINLINE.json
```

Soul's official 64-bit APK contains only `arm64-v8a` native libraries. On this
AMD x86-64 host, install `libndk` translation using the community installer
[linked by Waydroid](https://docs.waydro.id/faq/community-projects-we-like).
Review the downloaded installer before running it with administrator privileges:

```bash
git clone https://github.com/casualsnek/waydroid_script /tmp/waydroid-extras
/usr/bin/python3 -m venv /tmp/waydroid-extras/venv
/tmp/waydroid-extras/venv/bin/pip install -r /tmp/waydroid-extras/requirements.txt
# Read main.py, stuff/ndk.py, stuff/general.py, and tools/container.py first.
sudo env PATH=/usr/bin:/usr/sbin /tmp/waydroid-extras/venv/bin/python \
    /tmp/waydroid-extras/main.py -a 13 install libndk
```

This setup used the Android 13 translation archive at commit
`68734c52556d3d7a6db34c603dd9276915c29f2f` of
`supremegamers/vendor_google_proprietary_ndk_translation-prebuilt`.
The installer wrote libraries under `/var/lib/waydroid/overlay` and properties
in `/var/lib/waydroid/waydroid.cfg`, including:

```ini
[properties]
ro.product.cpu.abilist = x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
ro.product.cpu.abilist32 = x86,armeabi-v7a,armeabi
ro.product.cpu.abilist64 = x86_64,arm64-v8a
ro.dalvik.vm.native.bridge = libndk_translation.so
ro.enable.native.bridge.exec = 1
ro.vendor.enable.native.bridge.exec = 1
ro.vendor.enable.native.bridge.exec64 = 1
ro.ndk_translation.version = 0.2.3
ro.dalvik.vm.isa.arm = x86
ro.dalvik.vm.isa.arm64 = x86_64
```

These record the resulting configuration; use the installer to apply its
libraries, permissions, and properties together.

## Manage the container with systemd

```bash
sudo systemctl enable --now waydroid-container.service
systemctl status waydroid-container.service
waydroid session start
```

The container is a system service. The graphical session runs as the desktop
user; keep `waydroid session start` running in its terminal. Start apps from a
second terminal or the application menu. Enabling the container service does
not automatically start a graphical session at login.

## Allow networking through UFW

With UFW's default incoming and routed policies set to deny, Android started
but had no IPv4 address (`IP address: UNKNOWN`). For the default `waydroid0`
bridge and `192.168.240.0/24` subnet, these persistent rules fixed it:

```bash
sudo ufw allow in on waydroid0 to any port 67 proto udp
sudo ufw allow in on waydroid0 to any port 53
sudo ufw route allow in on waydroid0 from 192.168.240.0/24
waydroid session stop
waydroid session start
```

The rules allow DHCP and DNS to the host, and routed traffic originating from
Android's subnet. They do not change the firewall's default policies.
Check the actual bridge/subnet if using a custom Waydroid network.
After restarting, this container received `192.168.240.112`; that address is a
DHCP lease, not a static configuration.

```bash
waydroid status
sudo /usr/bin/python3 /usr/bin/waydroid shell -- ip -4 addr show eth0
sudo /usr/bin/python3 /usr/bin/waydroid shell -- ping -c 1 -W 3 1.1.1.1
```

Internet ping and DNS resolution worked. The host's proxy resolved Soul's
website to a synthetic address whose ICMP traffic was filtered; a failed
website ping alone did not indicate failed app connectivity.

## Download and run Soul

With an initialized, running Waydroid session and ARM translation already set
up, run `./waydroid/setup.sh --app soul` from the repository root. The installer
downloads and validates the official ARM64 APK, waits for the package to appear,
and refreshes KDE's cache. Already installed packages are skipped. Supply
`--soul-apk /path/to/soul.apk` to use a local publisher APK instead. To install
both apps from their default publisher URLs, use `./waydroid/setup.sh`.
See `./waydroid/setup.sh --help` for options. Installation does not establish
that an app can log in or play media in this Android environment.

The [official website](https://www.soulapp.cn/) links this APK. The initial
plain request returned HTTP 403; the Android user agent and referrer worked:

```bash
curl -fL --connect-timeout 20 --max-time 180 \
    -A 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/130.0.0.0 Mobile Safari/537.36' \
    -e https://www.soulapp.cn/ \
    https://china-img.soulapp.cn/apk/channel/soul_channel_soul64.apk \
    -o /tmp/soul-official-arm64.apk
waydroid app install /tmp/soul-official-arm64.apk
waydroid app launch cn.soulapp.android
```

The downloaded APK's ZIP integrity check passed. Soul's main activity was
confirmed in the foreground. Downloads in `/tmp` disappear after a reboot;
installed Android apps and `/var/lib/waydroid` persist.

## Chinese input inside Android

Desktop Fcitx5 was running, but Android only had `com.android.inputmethod.latin`
installed. Installing and selecting Fcitx5 **inside Android** resolved Chinese
input. The native x86-64 release avoids ARM translation for the keyboard.

Download from the [official Fcitx5 Android releases](https://github.com/fcitx5-android/fcitx5-android/releases).
The tested release and published SHA-256 were:

```bash
curl -fL --connect-timeout 15 --max-time 180 \
    https://github.com/fcitx5-android/fcitx5-android/releases/download/0.1.3/org.fcitx.fcitx5.android-0.1.3-0-g048f581c-x86_64-release.apk \
    -o /tmp/fcitx5-android.apk
printf '%s\n' 'aaeb569fc3e9e8ec532b0ea33be39ce77b143c8add824d172f17356ddc3b9ed2  /tmp/fcitx5-android.apk' \
    | sha256sum -c -
waydroid app install /tmp/fcitx5-android.apk
```

If GitHub's browser download is slow, the same asset can be fetched through
`https://api.github.com/repos/fcitx5-android/fcitx5-android/releases/assets/490266211`
with `curl -fL -H 'Accept: application/octet-stream'`; verify the same hash.

From the repository root, install the checked-in configuration into the new
keyboard's external files directory. Back up `config` and `profile` first if
the keyboard was already configured; these templates replace those settings.

```bash
sudo /usr/bin/python3 /usr/bin/waydroid shell -- am force-stop org.fcitx.fcitx5.android
sudo /usr/bin/python3 /usr/bin/waydroid shell -- mkdir -p \
    /sdcard/Android/data/org.fcitx.fcitx5.android/files/config
sudo /usr/bin/python3 /usr/bin/waydroid shell -- sh -c \
    'cat > /sdcard/Android/data/org.fcitx.fcitx5.android/files/config/profile' \
    < waydroid/fcitx5/profile
sudo /usr/bin/python3 /usr/bin/waydroid shell -- sh -c \
    'cat > /sdcard/Android/data/org.fcitx.fcitx5.android/files/config/config' \
    < waydroid/fcitx5/config
sudo /usr/bin/python3 /usr/bin/waydroid shell -- ime enable \
    org.fcitx.fcitx5.android/.input.FcitxInputMethodService
sudo /usr/bin/python3 /usr/bin/waydroid shell -- ime set \
    org.fcitx.fcitx5.android/.input.FcitxInputMethodService
sudo /usr/bin/python3 /usr/bin/waydroid shell -- am start -n \
    org.fcitx.fcitx5.android/.ui.main.MainActivity
```

The profile enables English and Pinyin, with Pinyin active by default. Fcitx5
shows a floating candidate window when typing on a physical keyboard.
Force-stopping the keyboard can reset Android to the Latin IME, so always
reselect Fcitx5 with `ime set` after a configuration restart.

For a local test without sending a Soul message:

```bash
sudo /usr/bin/python3 /usr/bin/waydroid shell -- am start -n \
    org.fcitx.fcitx5.android/.ui.main.ClipboardEditActivity
```

Type `nihao`: the first candidate should be `你好`. Press Space to select it,
or use the candidate number keys. Cancel the test editor, then return to Soul.
This physical-keyboard composition and candidate selection were verified during
setup. Android's selected input method can be checked with:

```bash
sudo /usr/bin/python3 /usr/bin/waydroid shell -- settings get secure default_input_method
```
