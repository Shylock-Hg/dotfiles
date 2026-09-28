# Agent 工作流

[English](workflow.md) | [中文](workflow.cn.md)

在自托管 Forgejo 实例上的一条评论，如何变成一次代码变更，同时又不把人类
账户交给自主 agent。三个部分协同完成：

| 组件 | 位置 | 职责 |
| --- | --- | --- |
| **Forgejo** | <https://forgejo.shylockhg.me> | 代码托管平台：仓库、issue、pull request、评论与 CI。它是对话与代码的权威记录。 |
| **forge-bot** | <https://github.com/Shylock-Hg/forge-bot> | 与具体 forge 无关的网关，把一次机器人提及转换为一次编码 agent 运行。 |
| **AaaU (Agent-as-User)** | <https://github.com/AgentaaU/AaaU> | 接入专用 agent 账户的 PTY 桥接，让被授权的人类可以启动、观察或加入一个 agent 会话。 |
| *人类* | `shylock` 账户 | 编写任务、审查结果，并可经 AaaU 接入同一个 agent 账户。 |

关键隔离在于 **人类账户** 与 **agent 账户** 之间。Forgejo、forge-bot 与
agent 都以 agent 账户运行；人类不会交出自己的账户。AaaU 正是让被授权的人类
接入该账户进行交互式工作的桥梁。

```text
        @shylock-bot <task>  on an issue / PR
                   │
                   ▼
        ┌──────────────────────┐
        │       Forgejo        │  issues / PRs / CI
        └──────────┬───────────┘
                   │ mention
                   ▼
        ┌──────────────────────┐
        │      forge-bot       │  verify → authorize
        │                      │  queue → start agent
        └──────────┬───────────┘
                   │ location + message
                   ▼
        ┌──────────────────────┐        ┌──────────────────────┐
        │    agent account     │◀──────▶│        AaaU          │
        │  coding agent runs   │  PTY   │  human joins session │
        └──────────┬───────────┘        └──────────────────────┘
                   │
                   ▼  commit / push / reply
              (Forgejo thread)
```

## 架构

系统分为三层：

1. **对话层。** Forgejo 托管讨论串。在 issue 或 pull request 上提及机器人是
   唯一的触发方式，讨论串也是汇报与审查结果的地方。
2. **网关层。** forge-bot 接收提及、校验并鉴权，按会话串行化运行，并启动
   agent。它刻意只交给 agent 一个 **位置** 和一条 **消息**，从不提供预先
   构建的上下文。
3. **执行与访问层。** Agent 以专用的 agent 账户、自动批准方式运行，因此可以
   读取仓库、编辑、运行命令与测试并推送。AaaU 向人类暴露进入同一账户的 PTY。

系统有两条贯穿始终的性质：

- **隔离。** agent 账户与人类账户相互独立，人类的凭据从不交给 agent。
- **最小交接。** agent 从位置与消息中得知要做什么，然后自行发现周围的上下文。

## 用法

### 触发一次运行

在 issue 或 pull request 上评论：

```text
@shylock-bot fix the failing test in utils/
```

只接受允许名单中的用户与仓库，机器人自己写出的提及会被忽略以避免循环。要
指定某个 agent，可以点名：

```text
@shylock-bot:codex fix the failing test in utils/
```

普通提及会使用默认的 agent 序列。

### 跟进一次运行

在同一条讨论串中回复。如果已有运行在进行，消息会被合并进当前运行，从而可以
实时引导 agent；否则会作为下一轮排队。每个 issue 或 pull request 同一时刻
至多一次运行，而不同讨论串可并行进行。

### 与 agent 交互式协作

被授权的人类使用 `aaau` 客户端接入 agent 账户：

```bash
aaau pi                    # 在 agent 账户中启动 pi
aaau codex                 # 在 agent 账户中启动 codex
aaau -n <session-id>       # 加入一个已存在的会话
aaau -n <session-id> -r    # 只读观察
```

这正是人类复现、观察或抢救自动化运行所用同一环境的方式。只有被授权组的成员
才能接入，且 agent 无法反向连接人类。

## 工作流

一次提及在系统中的流转如下：

1. 人类在 issue 或 pull request 上评论 `@shylock-bot <task>`。
2. Forgejo 将评论投递给 forge-bot —— 尽可能走 webhook，回退时使用轮询。
3. forge-bot 校验并鉴权该提及，记录位置与消息，并为该会话排队任务。
4. 仓库被检出到按会话划分的工作区，随后选择并以自动批准方式启动一个 agent。
5. agent 读取 forge、编辑检出内容、运行命令与测试、提交、推送分支、打开
   pull request，并在讨论串中回复。它的工作方式与开发者完全一致。
6. 人类审查 pull request，然后合并或在同一条讨论串中提出修改——这会开始下一轮。

如果 agent 报告用量、速率或配额限制，运行会用序列中的下一个 agent 重试；若
一个都不可用，讨论串会被告知原因。机器人会在任务排队后立即确认每条提及。

## 运维

状态页面列出每个已知讨论串及其状态（running / queued / idle）、所涉及的 agent
及其最后一次结果。监控可用的健康与状态端点，日志记录每次运行。具体服务与路径
取决于部署方式。

## 参考资料

* 网页版本：<https://shylock-hg-bot.github.io/>
* [纯文本版本](workflow.cn.txt)
* forge-bot：<https://github.com/Shylock-Hg/forge-bot>
* AaaU：<https://github.com/AgentaaU/AaaU>
