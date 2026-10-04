#! /usr/bin/env bash

if (( EUID == 0 )); then
    SUDO=()
else
    SUDO=(sudo)
fi

# Use upstream repositories in CI: regional mirrors can publish repomd.xml
# before its referenced metadata has synchronized, causing refresh HTTP 404s.
if [[ ${IN_CI:-false} == true ]]; then
    MIRRORS=(
        'UPSTREAM:OSS|https://download.opensuse.org/tumbleweed/repo/oss'
        'UPSTREAM:NON-OSS|https://download.opensuse.org/tumbleweed/repo/non-oss'
        'UPSTREAM:UPDATE|https://download.opensuse.org/update/tumbleweed'
    )
else
    MIRRORS=(
        'BFSU:OSS|https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/oss'
        'BFSU:NON-OSS|https://mirrors.bfsu.edu.cn/opensuse/tumbleweed/repo/non-oss'
        'BFSU:UPDATE|https://mirrors.bfsu.edu.cn/opensuse/update/tumbleweed'
    )
fi
readonly MIRRORS

# Remove the previous mirror configuration when upgrading an existing image.
# A missing alias is expected here, so tolerate failures.
for repo in USTC:OSS USTC:NON-OSS USTC:UPDATE \
    BFSU:OSS BFSU:NON-OSS BFSU:UPDATE \
    UPSTREAM:OSS UPSTREAM:NON-OSS UPSTREAM:UPDATE; do
    "${SUDO[@]}" zypper rr "$repo" || true
done

# The selected UPDATE mirror replaces repo-update, so drop the redundant default update
# repository. Disable each alias separately because zypper mr stops at the
# first alias that does not exist. Missing aliases are expected for these
# cleanup/disable operations.
for repo in repo-non-oss repo-oss repo-oss-debug repo-oss-source update-tumbleweed repo-update; do
    "${SUDO[@]}" zypper mr -d "$repo" || true
done

# Add every required mirror. -C keeps the addition local and fast: probing the
# URI here (-c) downloads repodata immediately and one slow mirror aborts the
# whole run with a Curl timeout. Fail the setup if a required mirror cannot be
# added.
for mirror in "${MIRRORS[@]}"; do
    alias=${mirror%%|*}
    uri=${mirror#*|}
    if ! "${SUDO[@]}" zypper ar -fCg "$uri" "$alias"; then
        echo "Failed to add required repository ${alias} (${uri})" >&2
        exit 1
    fi
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
