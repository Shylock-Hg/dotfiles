#! /usr/bin/env bash

if (( EUID == 0 )); then
    SUDO=()
else
    SUDO=(sudo)
fi

# Required openSUSE mirrors, as "alias|URI". Every entry must be configured
# before package installation can proceed.
readonly MIRRORS=(
    'BFSU:OSS|https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/oss'
    'BFSU:NON-OSS|https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/non-oss'
    'BFSU:UPDATE|https://mirrors.bfsu.edu.cn/opensuse/update/tumbleweed'
)

readonly ADD_ATTEMPTS=5

# Remove the previous mirror configuration when upgrading an existing image.
# A missing alias is expected here, so tolerate failures.
"${SUDO[@]}" zypper rr USTC:OSS USTC:NON-OSS USTC:UPDATE || true
for mirror in "${MIRRORS[@]}"; do
    "${SUDO[@]}" zypper rr "${mirror%%|*}" || true
done

# BFSU:UPDATE replaces repo-update, so drop the redundant default update
# repository. Disable each alias separately because zypper mr stops at the
# first alias that does not exist. Missing aliases are expected for these
# cleanup/disable operations.
for repo in repo-non-oss repo-oss repo-oss-debug repo-oss-source update-tumbleweed repo-update; do
    "${SUDO[@]}" zypper mr -d "$repo" || true
done

# Add every required mirror. -C keeps the addition local and fast: probing the
# URI here (-c) downloads repodata immediately, and one slow mirror used to
# abort the whole run with a Curl timeout before the installer's retrying
# refresh could recover it. Retry the local addition and fail the whole setup
# if a required mirror cannot be added.
for mirror in "${MIRRORS[@]}"; do
    alias=${mirror%%|*}
    uri=${mirror#*|}
    attempt=1
    while true; do
        if "${SUDO[@]}" zypper ar -fCg "$uri" "$alias"; then
            break
        fi
        if (( attempt >= ADD_ATTEMPTS )); then
            echo "Failed to add required repository ${alias} (${uri}) after ${ADD_ATTEMPTS} attempts" >&2
            exit 1
        fi
        echo "Failed to add required repository ${alias} (attempt ${attempt}/${ADD_ATTEMPTS}); retrying" >&2
        sleep $(( attempt * 5 ))
        attempt=$(( attempt + 1 ))
    done
done

# Verify every required alias is configured and enabled before package
# installation, so a later successful command cannot mask an earlier failure.
for mirror in "${MIRRORS[@]}"; do
    alias=${mirror%%|*}
    if ! info=$("${SUDO[@]}" zypper --no-refresh lr "$alias" 2>&1); then
        echo "Required repository ${alias} is not configured" >&2
        exit 1
    fi
    if ! grep -Eq '^Enabled[[:space:]]*:[[:space:]]*Yes' <<<"$info"; then
        echo "Required repository ${alias} is not enabled" >&2
        exit 1
    fi
done
