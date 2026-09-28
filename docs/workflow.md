# Agent workflow

[English](workflow.md) | [中文](workflow.cn.md)

How a comment on the self-hosted Forgejo instance becomes a code change,
without giving an autonomous agent the human's account. Three pieces fit
together:

| Component | Where | Role |
| --- | --- | --- |
| **Forgejo** | <https://forgejo.shylockhg.me> (configuration in this repo: `forgejo/dump.sh`, `forgejo-runner/`, `nginx/forgejo.conf`, `dnsmasq/`, `certs/`) | Hosts the repositories, issues, pull requests, comments and the self-hosted Actions runner. It is the conversation and the code of record. |
| **forge-bot** | <https://github.com/Shylock-Hg/forge-bot> | Forge-agnostic gateway that turns an `@shylock-bot` mention into a coding-agent run. Runs as the dedicated `agent` account (systemd *user* service) and listens on `127.0.0.1:8080`. |
| **AaaU (Agent-as-User)** | <https://github.com/AgentaaU/AaaU> | PTY bridge that runs an agent under the dedicated `agent` system user. Authorized humans (group `aaau-users`) attach with the `aaau` client to start, watch or interact with an agent session. |
| *Human* | `shylock` account, member of `aaau-users` | Writes the task, reviews the result, and can attach to the same agent account through AaaU. |

The important separation is between the **human account** (`shylock`) and the
**agent account** (`agent`). Forgejo and forge-bot never run as the human;
AaaU is what lets the human reach the agent account for interactive work. The
next sections follow one mention from the forge to the reply.

```text
        @shylock-bot <task>  on an issue / PR
                   │
                   ▼
        ┌──────────────────────┐
        │       Forgejo        │  webhook (HMAC-SHA256)
        │  issues / PRs / CI   │──────────────┐
        └──────────────────────┘              │   (fallback: poller)
                   ▲                          ▼
                   │              ┌──────────────────────┐
                   │              │      forge-bot       │
                   │              │ verify → authorize   │
                   │   reply      │ queue → checkout     │
                   │              │ select agent         │
                   │              └──────────┬───────────┘
                   │                         │ AgentRequest{location, message}
                   │                         ▼
                   │              ┌──────────────────────┐
                   │              │  agent account       │
                   │              │  pi-rpc / codex /    │
                   └──────────────│  agy / claude / ...  │
                       commit/push└──────────┬───────────┘
                                             │
                                  ┌──────────▼───────────┐
                                  │  aaau-server (PTY)   │
                                  │  human: aaau pi ...  │
                                  └──────────────────────┘
```

## 1. Trigger: a mention on Forgejo

A human comments on an issue or pull request:

```text
@shylock-bot fix the failing test in utils/
```

The trigger string is configured in forge-bot (`mention = "@shylock-bot"`) and
only users and repositories on the policy allow-list are accepted. In this
deployment `[policy] allowed_users = ["shylock"]` and the repository list is
empty, so `shylock` may trigger the bot on any repository it can see. Mentions
written by the bot itself are ignored to avoid loops. An explicit agent can be
chosen with `@shylock-bot:codex …`; a plain mention uses the configured
`agent_sequence`.

## 2. Delivery: webhook first, poller as fallback

There are two delivery paths and a deployment should use exactly one:

| Path | Requirement | Notes |
| --- | --- | --- |
| **Webhook** (used here) | A Forgejo hook created by a repository owner, org owner or instance admin | Push-based and near real-time. Forgejo signs each delivery; forge-bot verifies the `X-Forgejo-Signature` HMAC-SHA256 before doing anything. The endpoint is `POST http://127.0.0.1:8080/webhooks/forgejo`. |
| **Poller** | Only read access to the repositories | forge-bot polls every repository visible to its token; new repositories are discovered automatically. Slower, and used when the bot cannot create a hook (it is only a collaborator) or when Forgejo refuses to deliver to loopback. |

`[poller] enabled = false` in this deployment, so the active path is the
webhook. The hook is registered by an administrator (for example `shylock`),
because a collaborator token such as `shylock-bot` cannot create one. See
forge-bot's `doc/forgejo-webhook.md` for hook scopes and the API calls. Only one
path must be active per repository; running both delivers the same comment
twice.

## 3. What forge-bot does with the event

The gateway deliberately keeps a hard boundary: it hands the agent a **location
and a message**, never pre-built context.

1. **Verify** the webhook signature.
2. **Parse** the payload into a `ForgeMessage` (repository, issue/PR number,
   comment body, author, …). An issue/PR description is hashed so an edit that
   changes the text triggers once.
3. **Authorize** the author and repository against `[policy]`.
4. **Extract** `AgentRequest { location, message }`: the comment URL (for
   example `https://forgejo.shylockhg.me/shylock/dotfiles/issues/231#issuecomment-10832`)
   and the mention text.
5. **Queue** the job. There is at most one run per conversation (one issue or
   PR) at a time, while different conversations run in parallel. `[session] workers`
   (16 here) is the single global cap on concurrent agent runs.
6. **Prepare a workspace.** With `[workspace] enabled = true` and
   `reuse = true`, forge-bot checks out the repository under
   `~/.local/state/forge-bot/workspaces/<owner>__<repo>-<number>` and fetches
   updates on the next run.
7. **Select an agent** from the sequence and spawn it with the request. A
   deterministic session id is derived from the conversation, so the same
   thread resumes the same conversation (and prompt cache).
8. **Reply.** The bot immediately posts a short acknowledgement ("on it") and
   edits that same comment if it has to fall back to another agent. The agent
   itself normally posts the substantive reply. `[reply] result = false` here,
   so forge-bot does not duplicate the agent's summary.

A same-thread follow-up while a run is in flight is merged into that run: the
live `pi-rpc` process receives it as a `steer`, and the thread gets a
"📎 Merged into the current run." notice. One-shot adapters (`codex`, one-shot
`pi`, `claude`) have no live stdin, so their follow-ups run as the next turn.

## 4. Agent execution and capacity fallback

Agents run with auto-approve so they are not blocked on interactive prompts.
The default order starts with `codex`; `pi-rpc` (a long-lived `pi --mode rpc`
pool) is the default Pi backend and persists sessions. An agent that reports a
usage/rate/quota limit or an overload is marked unavailable for
`cooldown_secs` (5 h) and the job is retried on the next agent in
`agent_sequence`; if none is left, the thread is told `No available agent` with
the reason each one was skipped. This is exactly what happens on a busy day:
the acknowledgement for a queued mention names the fallback, for example
`codex (capacity limit)`.

The agent is free to do everything a developer would: read the forge through
the API/token it was given, inspect and edit the checkout, run commands and
tests, commit, push a branch, open a pull request, and reply on the thread. It
receives only the location and message, so it discovers the surrounding context
itself.

## 5. The agent account and AaaU isolation

The `agent` account is the security boundary; it has no login shell and its
home (`/home/agent`, mode `0700`) is unreadable by the human account.

* **forge-bot** runs as `agent` through a systemd **user** service
  (`~/.config/systemd/user/forge-bot.service`). It spawns `pi`/`codex`/… as
  `agent` directly. There is no privilege escalation to the human account.
* **AaaU** (`aaau-server.service`) also runs as `agent` and exposes a Unix
  socket (`/run/aaau/server.sock`) to members of the `aaau-users` group. A
  human connects with the `aaau` client and gets a PTY in the agent account:

  ```bash
  aaau pi                    # start pi in the agent account
  aaau codex                 # shortcut for codex (standard bypass flag)
  aaau claude                # shortcut for claude
  aaau -n <session-id>       # join an existing session
  aaau -n <session-id> -r    # observe read-only
  ```

  This is how a human can reproduce, watch or rescue the same environment the
  automated runs use. The `agent` account is not a member of `aaau-users`, so
  the agent cannot connect back to the human socket, and AaaU scrubs
  `AAAU_SESSION_ID` / `AAAU_EDITOR_SOCKET` out of the environment before
  starting a managed agent.

AaaU keeps audit logs (`audit-YYYY-MM-DD.logl`, retained five days) and can
forward an editor buffer from a Codex/Claude session back to the operator's
Emacs (`aaau-editor`). See the AaaU README for the full protocol and security
model.

## 6. Installation in dotfiles

This repository is the machine's provisioning entry point:

| Path | Purpose |
| --- | --- |
| `aaau/setup.sh` | Downloads the latest AaaU Linux release and installs `aaau`, `aaau-server` and `aaau-editor` to `/usr/local/bin`. Called by the top-level `setup.sh` outside CI. |
| `forgejo/` | `dump.sh` dumps the whole Forgejo instance (stop → `forgejo dump` → start) to `~/Data/forgejo.tar.zst`. |
| `forgejo-runner/` | `config.yaml` + `setup.sh` install the self-hosted Actions runner and inject its registration token as a systemd credential (`LoadCredential`), so the token never lands in config or process args. |
| `nginx/`, `dnsmasq/`, `certs/` | Public HTTPS front end (`forgejo.shylockhg.me`), DNS and the certificates. |
| `setup.sh` | Orchestrates the above; AaaU and the secret decryption steps are skipped with `IN_CI`. |

## 7. Operations

| Thing | Command / location |
| --- | --- |
| Forgejo | `systemctl status forgejo.service` (system) |
| Actions runner | `systemctl status forgejo-runner.service` (system) |
| AaaU bridge | `systemctl status aaau-server.service` (system) |
| forge-bot | `systemctl --user status forge-bot.service`, `journalctl --user -u forge-bot -f` |
| forge-bot log | `~/.local/state/forge-bot/forge-bot.log` |
| forge-bot state | `~/.local/state/forge-bot/state/{jobs,sessions,poller.json}` |
| Health / status | `curl http://127.0.0.1:8080/healthz`, `http://127.0.0.1:8080/status`, `/status.json` |
| Agent audit | `/var/lib/aaau/audit-*.logl` |

The `/status` page lists every known thread with its state (running / queued /
idle), the agent involved and its last result, and can be searched by comment or
issue URL.

CI is separate from the mention flow but runs on the same host: the self-hosted
runner executes `.github/workflows/test.yaml` (openSUSE and CachyOS setup on
pull requests) and `.github/workflows/docker.yaml` (image builds on `master`).
Container jobs share the host network so they can reach the Forgejo instance on
port 3000 and the Actions cache.

## 8. Worked example: this repository's issue #231

1. `shylock` opened issue #231 with the task "write a workflow document…" and
   commented `@shylock-bot Do this` (comment 10832).
2. Forgejo delivered the comment to the webhook; forge-bot verified it,
   accepted the trigger, and queued a job for `shylock/dotfiles` issue 231.
3. It cloned `shylock/dotfiles` into
   `~/.local/state/forge-bot/workspaces/shylock__dotfiles-231`.
4. `codex` was tried first, then `agy`; both were out of capacity, so the
   job fell through to the `pi-rpc` pool. The bot's acknowledgement was edited
   to name the unavailable agents.
5. The running agent (this document) received only the location
   `https://forgejo.shylockhg.me/shylock/dotfiles/issues/231#issuecomment-10832`
   and the message `Do this`, then gathered the rest of the context from the
   repository.
6. The result is a branch and a pull request against `master`; the human
   reviews it. `shylock` is requested as reviewer.

## Reference

* [中文版 (Chinese version)](workflow.cn.md)
* forge-bot repo and docs: <https://github.com/Shylock-Hg/forge-bot>
  (`README.md`, `deploy.md`, `doc/forgejo-webhook.md`)
* AaaU repo and docs: <https://github.com/AgentaaU/AaaU>
  (`README.md`, `AGENTS.md`)
* This repository's setup: `setup.sh`, `aaau/setup.sh`, `forgejo/`,
  `forgejo-runner/`, `nginx/`
