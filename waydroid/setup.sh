#!/usr/bin/env bash
# Install publisher APKs into an existing user Waydroid session.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: waydroid/setup.sh [OPTIONS]

Install Xiaohongshu and Soul; skip packages that are already installed.
Waydroid must already be initialized, have ARM translation, and have a running
desktop session. Run as your desktop user, without sudo.

  --app both|xiaohongshu|soul  Select apps (default: both)
  --xiaohongshu-apk PATH      Local publisher APK
  --xiaohongshu-url URL       Override Xiaohongshu's official 9.54.1 APK URL
  --soul-apk PATH             Local publisher APK instead of downloading
  --soul-url URL              Override Soul's official ARM64 APK URL
  -h, --help                 Show this help

Examples:
  ./waydroid/setup.sh
  ./waydroid/setup.sh --app soul

Existing apps are not upgraded or launched. Account login and Android system
configuration are unchanged. WAYDROID_BIN can override /usr/bin/waydroid;
that Python entry point is always run with /usr/bin/python3.
EOF
}

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
need_value() { [[ $# -ge 2 && -n $2 && $2 != --* ]] || fail "$1 needs a value"; }

selection=both
xiaohongshu_apk=
xiaohongshu_url=
soul_apk=
soul_url=https://china-img.soulapp.cn/apk/channel/soul_channel_soul64.apk
while (($#)); do
    case $1 in
        --app) need_value "$@"; selection=$2; shift 2 ;;
        --xiaohongshu-apk) need_value "$@"; xiaohongshu_apk=$2; shift 2 ;;
        --xiaohongshu-url) need_value "$@"; xiaohongshu_url=$2; shift 2 ;;
        --soul-apk) need_value "$@"; soul_apk=$2; shift 2 ;;
        --soul-url) need_value "$@"; soul_url=$2; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) fail "Unknown option: $1 (see --help)" ;;
    esac
done
case $selection in both|xiaohongshu|soul) ;; *) fail 'Invalid --app selection' ;; esac
[[ -z $xiaohongshu_apk || -z $xiaohongshu_url ]] || fail 'Choose one Xiaohongshu APK source'
# Apply the default after checking explicit sources so local APKs take precedence.
if [[ -z $xiaohongshu_apk && -z $xiaohongshu_url ]]; then
    xiaohongshu_url=https://redgray.xhscdn.com/ui/androidPublish/prod/xhs/channel/apk/9.54.1/9541801/v9541801-xhs-share_package_common_X64.apk
fi
(( EUID != 0 )) || fail 'Run as the logged-in desktop user, without sudo'
waydroid_bin=${WAYDROID_BIN:-/usr/bin/waydroid}
[[ -r $waydroid_bin && -x /usr/bin/python3 ]] || fail 'Install Waydroid and distribution Python first'
waydroid() { /usr/bin/python3 "$waydroid_bin" "$@"; }
status=$(waydroid status)
[[ $status =~ Session:[[:space:]]*RUNNING ]] || fail 'Start Waydroid from your Wayland desktop first: /usr/bin/python3 /usr/bin/waydroid session start'
installed=$(waydroid app list)
has_package() { [[ $installed == *"packageName: $1"$'\n'* || $installed == *"packageName: $1" ]]; }

apps=()
packages=()
sources=()
urls=()
queue_app() {
    if has_package "$2"; then
        printf '%s is already installed; skipping.\n' "$1"
        return
    fi
    [[ -n $3 || -n $4 ]] || fail 'Provide --xiaohongshu-apk PATH or --xiaohongshu-url URL from https://www.xiaohongshu.com/download'
    if [[ -n $3 ]]; then
        [[ -f $3 && -r $3 ]] || fail "Cannot read APK: $3"
    else
        [[ $4 == https://* ]] || fail 'APK downloads must use HTTPS'
        command -v curl >/dev/null || fail 'Install curl to download APKs'
    fi
    apps+=("$1"); packages+=("$2"); sources+=("$3"); urls+=("$4")
}
if [[ $selection != soul ]]; then
    queue_app Xiaohongshu com.xingin.xhs "$xiaohongshu_apk" "$xiaohongshu_url"
fi
if [[ $selection != xiaohongshu ]]; then
    queue_app Soul cn.soulapp.android "$soul_apk" "$soul_url"
fi

if ((${#apps[@]})); then
    work_dir=$(mktemp -d "${TMPDIR:-/tmp}/waydroid-apps.XXXXXXXX")
    trap 'rm -rf -- "$work_dir"' EXIT
    # Prepare and validate all selected APKs before installing any of them.
    for i in "${!apps[@]}"; do
        if [[ -z ${sources[i]} ]]; then
            sources[i]=$work_dir/${packages[i]}.apk
            referrer=https://www.xiaohongshu.com/
            [[ ${packages[i]} != cn.soulapp.android ]] || referrer=https://www.soulapp.cn/
            curl --fail --location --retry 2 --connect-timeout 20 --max-time 600 \
                --proto '=https' --proto-redir '=https' \
                --user-agent 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/130.0.0.0 Mobile Safari/537.36' \
                --referer "$referrer" --output "${sources[i]}" "${urls[i]}"
        fi
        /usr/bin/python3 - "${sources[i]}" <<'PY'
import hashlib
from pathlib import Path
import sys
import zipfile

path = Path(sys.argv[1])
try:
    with zipfile.ZipFile(path) as apk:
        if not {'AndroidManifest.xml', 'classes.dex'}.issubset(apk.namelist()):
            raise ValueError('Missing Android manifest or DEX code')
        bad = apk.testzip()
        if bad:
            raise ValueError(f'Corrupt APK member: {bad}')
    with path.open('rb') as source:
        checksum = hashlib.file_digest(source, 'sha256').hexdigest()
    print(f'Validated APK: {path.name}; SHA256: {checksum}')
except (OSError, ValueError, zipfile.BadZipFile) as error:
    sys.exit(f'Invalid APK {path}: {error}')
PY
    done
    for i in "${!apps[@]}"; do
        printf 'Installing %s...\n' "${apps[i]}"
        waydroid app install "${sources[i]}"
        found=false
        for ((attempt=0; attempt<30; attempt++)); do
            installed=$(waydroid app list)
            if has_package "${packages[i]}"; then found=true; break; fi
            sleep 1
        done
        [[ $found == true ]] || fail "${apps[i]} did not appear in Waydroid's app list; check Android's package installer logs"
        printf 'Installed %s (%s).\n' "${apps[i]}" "${packages[i]}"
    done
fi

if command -v kbuildsycoca6 >/dev/null; then
    kbuildsycoca6 --noincremental
fi
printf 'Done. Search KDE Applications for rednote or Soul.\n'
