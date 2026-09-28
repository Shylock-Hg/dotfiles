# Agent 工作流

[English](workflow.md) | [中文](workflow.cn.md)

在自托管 Forgejo 实例上的一条评论，如何变成一次代码变更，同时又不把人类
账户交给自主 agent。三个部分协同完成：

| 组件 | 位置 | 职责 |
| --- | --- | --- |
| **Forgejo** | <https://forgejo.shylockhg.me> | 托管仓库、issue、pull request、评论以及自托管的 Actions runner。它是对话与代码的权威记录。 |
| **forge-bot** | <https://github.com/Shylock-Hg/forge-bot> | 与具体 forge 无关的网关，把一次 `@shylock-bot` 提及转换为一次编码 agent 运行。它以专用的 `agent` 账户（systemd *用户*服务）运行，监听 `127.0.0.1:8080`。 |
| **AaaU (Agent-as-User)** | <https://github.com/AgentaaU/AaaU> | PTY 桥接，在专用的 `agent` 系统用户下运行 agent。被授权的人类（`aaau-users` 组）使用 `aaau` 客户端接入，以启动、观察或交互一个 agent 会话。 |
| *人类* | `shylock` 账户，`aaau-users` 组成员 | 编写任务、审查结果，并可通过 AaaU 接入同一个 agent 账户。 |

关键隔离在于 **人类账户**（`shylock`）与 **agent 账户**（`agent`）之间。
Forgejo 与 forge-bot 绝不以人类身份运行；AaaU 正是让人类能够接入 agent
账户进行交互式工作的途径。接下来的小节将跟随一次提及，从 forge 一直走到
回复。

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

## 1. 触发：在 Forgejo 上提及

人类在 issue 或 pull request 上评论：

```text
@shylock-bot fix the failing test in utils/
```

触发字符串在 forge-bot 中配置（`mention = "@shylock-bot"`），并且只接受
策略允许名单中的用户与仓库。在此部署中
`[policy] allowed_users = ["shylock"]`，仓库列表为空，因此 `shylock` 可以在
它能看到的任意仓库上触发机器人。机器人自己写出的提及会被忽略以避免循环。
可以用 `@shylock-bot:codex …` 显式指定 agent；普通提及则使用配置的
`agent_sequence`。

## 2. 投递：优先 webhook，poller 作为回退

有两条投递路径，一次部署应只使用其中一条：

| 路径 | 要求 | 说明 |
| --- | --- | --- |
| **Webhook**（此处使用） | 由仓库所有者、组织所有者或实例管理员创建 Forgejo hook | 基于推送，接近实时。Forgejo 会为每次投递签名；forge-bot 在做任何事之前都会校验 `X-Forgejo-Signature` 的 HMAC-SHA256。端点为 `POST http://127.0.0.1:8080/webhooks/forgejo`。 |
| **Poller** | 只需对仓库的读权限 | forge-bot 轮询其 token 可见的每个仓库；新仓库会被自动发现。较慢，适用于机器人无法创建 hook（它只是协作者）或 Forgejo 拒绝投递到 loopback 的情况。 |

此部署中 `[poller] enabled = false`，因此生效路径是 webhook。该 hook 由
管理员（例如 `shylock`）注册，因为像 `shylock-bot` 这样的协作者 token 无法
创建 hook。关于 hook 作用域与 API 调用，参见 forge-bot 的
`doc/forgejo-webhook.md`。每个仓库必须只启用一条路径；同时运行两者会让同一
条评论被投递两次。

## 3. forge-bot 如何处理事件

该网关刻意保留一条硬边界：它只交给 agent 一个 **位置** 和一条 **消息**，
从不提供预先构建的上下文。

1. **校验** webhook 签名。
2. **解析** 载荷为 `ForgeMessage`（仓库、issue/PR 编号、评论文本、作者，…）。
   issue/PR 描述会被哈希，因此改变文本的编辑只会触发一次。
3. **鉴权** 作者与仓库是否符合 `[policy]`。
4. **提取** `AgentRequest { location, message }`：评论 URL（例如
   `https://forgejo.shylockhg.me/owner/repo/issues/123#issuecomment-456`）
   与提及文本。
5. **排队** 任务。每个会话（一个 issue 或 PR）同一时刻至多一次运行，而不同
   会话可并行运行。`[session] workers`（此处为 16）是并发 agent 运行的唯一
   全局上限。
6. **准备工作区。** 当 `[workspace] enabled = true` 且 `reuse = true` 时，
   forge-bot 会把仓库检出到
   `~/.local/state/forge-bot/workspaces/<owner>__<repo>-<number>`，并在下一次
   运行时拉取更新。
7. **选择 agent**，按序列并用该请求启动它。会话 id 由会话内容确定性地派生，
   因此同一条讨论串会恢复同一个会话（以及 prompt 缓存）。
8. **回复。** 机器人会立即发出一条简短确认（"on it"），并在不得不回退到另一个
   agent 时编辑同一条评论。实质性回复通常由 agent 自己发出。此处
   `[reply] result = false`，因此 forge-bot 不会重复 agent 的总结。

当一次运行正在进行时，同一讨论串中的后续消息会被合并进该次运行：运行中的
`pi-rpc` 进程会将它作为一次 `steer` 接收，讨论串会收到一条
"📎 Merged into the current run." 提示。一次性适配器（`codex`、一次性 `pi`、
`claude`）没有可写的实时 stdin，因此它们的后续消息会作为下一轮运行。

## 4. Agent 执行与容量回退

Agent 以自动批准方式运行，因此不会被交互式提示阻塞。默认顺序以 `codex`
开始；`pi-rpc`（一个长期存活的 `pi --mode rpc` 池）是默认的 Pi 后端，并会
持久化会话。报告用量/速率/配额限制或过载的 agent 会被标记为不可用
`cooldown_secs`（5 小时），任务会用 `agent_sequence` 中的下一个 agent 重试；
若一个都不剩，讨论串会收到 `No available agent` 以及每个 agent 被跳过的原因。
忙碌时正是这种情况：对排队提及的确认会指出回退，例如
`codex (capacity limit)`。

Agent 可以自由地做开发者会做的一切：通过被授予的 API/token 读取 forge、
检查并编辑检出内容、运行命令与测试、提交、推送分支、打开 pull request，并在
讨论串中回复。它只收到位置与消息，因此它会自行发现周围的上下文。

## 5. agent 账户与 AaaU 隔离

`agent` 账户就是安全边界；它没有登录 shell，其主目录（`/home/agent`，权限
`0700`）对主目录人类账户不可读。

* **forge-bot** 通过 systemd **用户**服务
  （`~/.config/systemd/user/forge-bot.service`）以 `agent` 身份运行。它直接以
  `agent` 身份启动 `pi`/`codex`/…。不会向人类账户提权。
* **AaaU**（`aaau-server.service`）同样以 `agent` 身份运行，并向
  `aaau-users` 组成员暴露一个 Unix socket（`/run/aaau/server.sock`）。人类用
  `aaau` 客户端连接，即可获得 agent 账户中的 PTY：

  ```bash
  aaau pi                    # 在 agent 账户中启动 pi
  aaau codex                 # codex 的快捷方式（标准绕过标志）
  aaau claude                # claude 的快捷方式
  aaau -n <session-id>       # 加入一个已存在的会话
  aaau -n <session-id> -r    # 只读观察
  ```

  这正是人类可以复现、观察或抢救自动化运行所用同一环境的方式。`agent`
  账户不是 `aaau-users` 的成员，因此 agent 无法反向连接人类的 socket，并且
  AaaU 在启动受管 agent 之前会从环境中清除 `AAAU_SESSION_ID` /
  `AAAU_EDITOR_SOCKET`。

AaaU 会保留审计日志（`audit-YYYY-MM-DD.logl`，保留五天），并且可以把
Codex/Claude 会话中的编辑器缓冲区转发回操作者的 Emacs（`aaau-editor`）。关于
完整协议与安全模型，参见 AaaU README。

## 6. 运维

| 事项 | 命令 / 位置 |
| --- | --- |
| Forgejo | `systemctl status forgejo.service`（系统） |
| Actions runner | `systemctl status forgejo-runner.service`（系统） |
| AaaU bridge | `systemctl status aaau-server.service`（系统） |
| forge-bot | `systemctl --user status forge-bot.service`、`journalctl --user -u forge-bot -f` |
| forge-bot 日志 | `~/.local/state/forge-bot/forge-bot.log` |
| forge-bot 状态 | `~/.local/state/forge-bot/state/{jobs,sessions,poller.json}` |
| 健康 / 状态 | `curl http://127.0.0.1:8080/healthz`、`http://127.0.0.1:8080/status`、`/status.json` |
| Agent 审计 | `/var/lib/aaau/audit-*.logl` |

`/status` 页面列出每个已知讨论串及其状态（running / queued / idle）、所涉及的
agent 及其最后一次结果，并可按评论或 issue URL 搜索。

CI 与提及流程相互独立，但运行在同一台主机上：自托管 runner 执行
`.github/workflows/test.yaml`（在 pull request 上执行 openSUSE 与 CachyOS
安装）和 `.github/workflows/docker.yaml`（在 `master` 上构建镜像）。容器任务
共享主机网络，因此可以访问 3000 端口上的 Forgejo 实例与 Actions 缓存。

## 7. 实例：一条 issue 上的提及

1. 用户打开 issue #123，任务为 "write a workflow document…"，并评论
   `@shylock-bot Do this`。
2. Forgejo 将该评论投递到 webhook；forge-bot 校验它、接受该触发，并为
   `owner/repo` issue 123 排入一个任务。
3. 它将 `owner/repo` 克隆到
   `~/.local/state/forge-bot/workspaces/owner__repo-123`。
4. 先尝试 `codex`，然后是 `agy`；两者都容量不足，因此任务落到 `pi-rpc`
   池。机器人的确认被编辑，以指出不可用的 agent。
5. 正在运行的 agent（即本文档）只收到位置
   `https://forgejo.shylockhg.me/owner/repo/issues/123#issuecomment-456`
   与消息 `Do this`，随后从仓库中收集其余上下文。
6. 结果是一个分支和一个针对 `master` 的 pull request；由人类审查。

## 参考资料

* forge-bot 仓库与文档：<https://github.com/Shylock-Hg/forge-bot>
  （`README.md`、`deploy.md`、`doc/forgejo-webhook.md`）
* AaaU 仓库与文档：<https://github.com/AgentaaU/AaaU>
  （`README.md`、`AGENTS.md`）
