# Security

This file records the security-relevant properties of the repository and the
result of the periodic security review. The latest review was performed on
2026-09-28 against `master` at `9d746b5`.

## Reporting a vulnerability

Please report exploitable problems privately — for example through a Forgejo
security advisory or by contacting [@shylock](https://forgejo.shylockhg.me/shylock)
directly. Do not open a public issue for an unfixed vulnerability.

## How secrets are stored

This is a public dotfiles repository, so no plaintext credential should ever be
committed. Personal keys and credentials are kept out of the tree or stored
encrypted:

* `*.gpg.b64` files are PGP-encrypted and then base64-encoded. The review
  decoded every one of them and confirmed they contain PGP `pubkey enc`
  packets for the 4096-bit RSA key `E63EE5A890228C2A`; no plaintext secret is
  present.
* `.dockerignore` excludes `certs/*.gpg.b64`, `shylock/**/*.gpg.b64` and the
  runner `token`/`uuid` files from the build context, so CI images do not bake
  them in.
* The Forgejo runner registration token is injected by systemd as a credential
  (`LoadCredential`) and is not written to `config.yaml` or the process
  arguments.
* `gitleaks` was run over the full history (567 commits) and reported no
  plaintext leaks.

The private half of the GPG key is **not** in this repository and must stay
that way. Encrypted material is only as strong as that key's passphrase.

## Findings

| # | Severity | Finding | Location | Status |
| - | -------- | ------- | -------- | ------ |
| 1 | High | A Shadowsocks password was hardcoded in a public repository. | `docker/compose/shadowsocks.yml` | Fixed — read from `SHADOWSOCKS_PASSWORD`; **rotate the old value**. |
| 2 | High | Samba follows symlinks that escape the share (`wide links = yes`, `allow insecure wide links = yes`) while shares are guest-readable. | `samba/smb.conf` | Reported — see below. |
| 3 | Medium | Docker daemon is configured with a long list of unvetted third-party registry mirrors, any of which can serve altered images. | `docker/daemon.json` | Reported. |
| 4 | Medium | Installers pipe remote scripts into a shell (`curl … \| sh`). | `setup.sh`, `rust/setup-rust.sh` | Accepted — use official HTTPS endpoints; pin/checksum where possible. |
| 5 | Medium | An unsigned Windows installer is downloaded and executed. | `wine/setup.sh` | Reported. |
| 6 | Medium | The Forgejo runner exposes a `self-hosted:host` label and host networking; jobs run directly on the workstation. | `forgejo-runner/config.yaml` | Accepted — remove the label if untrusted workflows are ever enabled. |
| 7 | Medium | The GitLab runner mounts the host Docker socket and uses host networking. | `gitlab-runner/docker-compose.yml` | Accepted — Docker socket access is root-equivalent. |
| 8 | Low | nginx served TLS without an explicit protocol/cipher policy and without HSTS. | `nginx/forgejo.conf` | Fixed. |
| 9 | Low | `gitlab/docker-compose.yml` mounts `../certs/server.crt` and `server.key`, which do not exist in the tree. | `gitlab/docker-compose.yml` | Reported. |

### Detail and recommendations

**2. Samba wide links.** `samba/setup.sh` creates symlinks inside
`/srv/samba/public` that point at directories under `/home/shylock`, and
`smb.conf` enables `wide links` (and `allow insecure wide links`) so Samba will
follow them. Combined with `guest ok = yes`, any client that can reach the host
can read anything reachable through those links. Because the individual
`Documents`, `Pictures`, `Music` and `Videos` shares already point at the real
paths, the suggested fix is to drop the symlinked `[public]` share (or replace
the symlinks with bind mounts) and remove both `wide links = yes` and
`allow insecure wide links = yes`.

**3. Docker registry mirrors.** Most entries in `docker/daemon.json` are
community-run proxies. A malicious or compromised mirror can return a
different image under a trusted name. Restrict the list to mirrors that are
owned/operated by a trusted party, or remove the overrides and pull directly
from Docker Hub.

**5. Unsigned Windows binaries.** `wine/setup.sh` downloads and runs a
vendor installer without verifying a signature. Where a checksum is published,
verify it; otherwise download manually from the vendor.

**9. GitLab nginx certificates.** The compose file expects
`certs/server.crt`/`certs/server.key` while `certs/setup.sh` installs
`shylockhg.me.*`. Align the filenames or mount the real certificate.

## Positive controls already in place

* The image-publishing workflow (`.github/workflows/docker.yaml`) runs only on
  `push` to `master` and `workflow_dispatch`, never on `pull_request`, so
  registry credentials are not exposed to untrusted revisions.
* The test workflow runs untrusted pull-request code inside a container rather
  than on the host.
* `forgejo-runner/setup.sh` enforces root, validates inputs and installs the
  token with mode `0600`, owned by root.
* `forgejo/dump.sh` uses `set -euo pipefail` and a trap to always restart the
  service and clean up its temporary directory.
* `.gitignore` covers the personal secrets that would otherwise land in the
  tree.
