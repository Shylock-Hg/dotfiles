# Forgejo + Actions Runner (dedicated `forgejo` user/group)

systemd units that run the Forgejo server and the Forgejo Actions runner under
their own dedicated `forgejo` system user and group (no root, no shared `git`
account).

## Files

| File                     | Purpose / installs to                          |
| ------------------------ | ---------------------------------------------- |
| `install.sh`             | Configures user, dirs, units and config files  |
| `forgejo.sysusers`       | `/usr/lib/sysusers.d/forgejo.conf`             |
| `forgejo.tmpfiles`       | `/usr/lib/tmpfiles.d/forgejo.conf`             |
| `forgejo.service`        | `/etc/systemd/system/forgejo.service`          |
| `forgejo-runner.service` | `/etc/systemd/system/forgejo-runner.service`   |

## Prerequisites

Place the `forgejo` and `forgejo-runner` binaries in `BIN_DIR`
(default `/usr/local/bin`). The installer does **not** download or copy them.

```bash
sudo install -m 0755 forgejo         /usr/local/bin/forgejo
sudo install -m 0755 forgejo-runner  /usr/local/bin/forgejo-runner
```

## Install

```bash
sudo ./install.sh
```

The script performs, in order:

1. checks that both binaries already exist
2. creates the dedicated `forgejo` user/group and data directories
3. installs the systemd units
4. generates `/etc/forgejo/app.ini` with fresh `SECRET_KEY` / `INTERNAL_TOKEN`
5. generates `/etc/forgejo/runner/config.yml`
6. registers the runner (if a URL + token were supplied)

It does **not** enable or start the services — do that when you are ready:

```bash
sudo systemctl enable --now forgejo.service forgejo-runner.service
```

### Options

Everything is configurable through environment variables, e.g.:

```bash
sudo FORGEJO_URL=https://git.example.com \
     RUNNER_TOKEN=<REGISTRATION_TOKEN> \
     FORGEJO_DOMAIN=git.example.com \
     ./install.sh
```

| Variable                       | Default                            |
| ------------------------------ | ---------------------------------- |
| `BIN_DIR`                      | `/usr/local/bin`                   |
| `FORGEJO_HOME`                 | `/var/lib/forgejo`                 |
| `RUNNER_HOME`                  | `/var/lib/forgejo-runner`          |
| `CONFIG_DIR`                   | `/etc/forgejo`                     |
| `FORGEJO_DOMAIN`               | `$(hostname)`                      |
| `FORGEJO_HTTP_PORT`            | `3000`                             |
| `FORGEJO_SSH_PORT`             | `222`                              |
| `FORGEJO_URL` / `RUNNER_TOKEN` | *(empty → skip registration)*      |
| `RUNNER_NAME`                  | `$(hostname)`                      |
| `RUNNER_LABELS`                | `docker:docker://node:20-bookworm` |

If `FORGEJO_URL` / `RUNNER_TOKEN` are omitted, register later with:

```bash
sudo -u forgejo -H bash -c 'cd /var/lib/forgejo-runner && \
  forgejo-runner register \
    --config /etc/forgejo/runner/config.yml \
    --instance https://git.example.com \
    --token <REGISTRATION_TOKEN> \
    --name "$(hostname)" \
    --labels docker:docker://node:20-bookworm'
```

## Notes

- Both services run as `User=forgejo` / `Group=forgejo`.
- `/etc/forgejo` is root-owned and group-readable by `forgejo` only.
- State lives in `/var/lib/forgejo` (server) and `/var/lib/forgejo-runner`
  (runner); both are writable only by the `forgejo` user.
- The server unit uses `ProtectSystem=strict` + `ReadWritePaths`; adjust those
  paths if your `app.ini` stores repositories/LFS/logs elsewhere.
- Privileged ports (<1024) need `AmbientCapabilities=CAP_NET_BIND_SERVICE`
  (commented in `forgejo.service`).
- The runner unit has `ConditionFileNotEmpty=/var/lib/forgejo-runner/.runner`,
  so it stays cleanly inactive until the runner is registered.
- The runner needs a container backend. Preferred: **rootless Podman** as the
  `forgejo` user. Alternative: add `SupplementaryGroups=docker` and allow the
  Docker socket (commented in `forgejo-runner.service`).
