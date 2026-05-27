# claude-commands

Claude Code 全局命令：月光酒馆驱动的 Sprint 研发工作流。

所有命令基于 [infra-moonlight-tavern](https://github.com/523753042/infra-moonlight-tavern)（月光酒馆）中央 PM 仓库，任务状态由 PR 生命周期实时推导。

## 包含命令

### 月光酒馆侧

在 `infra-moonlight-tavern` 仓库中运行，直接操作 Sprint 规划与归档。

| 命令 | 作用 |
|------|------|
| `/roadmap` | 规划或更新 ROADMAP.md：基于产品文档和设计稿 brainstorm |
| `/plan` | 规划下一个 Sprint：从 ROADMAP 拆解 Epic/Story/Task，写入 SPRINT.md |
| `/sp-close` | Sprint 结束时聚合所有 PR 状态，更新 SPRINT.md 并归档到 PROJECT.md |

### Work Repo 侧

在具体开发仓库中运行，关联月光酒馆完成日常研发工作。

| 命令 | 作用 |
|------|------|
| `/project-init` | 新项目初始化：在月光酒馆创建项目目录 + meta.yaml + ROADMAP/SPRINT/PROJECT，注册 repos.yml，生成当前 work repo 的 CLAUDE.md |
| `/my-tasks` | 列出当前 work repo 的未完成任务 + 实时 PR 状态 |
| `/sprint-report` | 读取 SPRINT.md，结合 GitHub PR 实时状态，生成进度摘要报告 |
| `/ship` | 为一个或多个任务创建聚合 draft PR（title 以 `[TXX.X]` 开头） |

## 架构

**任务状态由 PR 生命周期实时推导**，无需手动维护：

| PR 状态 | 任务状态 | 图标 |
|---------|---------|------|
| 未开 PR | todo | ⚪ |
| PR isDraft | wip | 🟡 |
| PR open + ready | review | 🔵 |
| PR merged | done | ✅ |
| PR closed 未合并 | error | 🟥 |

## 安装

```bash
curl -o- https://raw.githubusercontent.com/523753042/lib-claude-command/main/install.sh | bash
```

或者 clone 后本地安装（离线场景）：

```bash
git clone https://github.com/523753042/lib-claude-command
cd lib-claude-command && bash install.sh
```

安装后重启 Claude Code，所有项目中直接使用 `/plan`、`/ship` 等命令。

## 文件结构

命令依赖以下文件（`/project-init` 会自动生成）：

**月光酒馆（中央 PM 仓库）**
```
infra-moonlight-tavern/
├── repos.yml                注册所有 work repo
├── projects/
│   └── {项目名}/
│       ├── meta.yaml        项目元信息
│       ├── ROADMAP.md       长期路线图
│       ├── SPRINT.md        当前 Sprint（PR 生命周期驱动状态）
│       └── PROJECT.md       已完成 Sprint 归档
```

**Work Repo（实际开发仓库）**
```
work-repo/
└── CLAUDE.md                项目上下文 + 指向月光酒馆
```

## 更新

重新执行安装命令即可覆盖更新：

```bash
curl -o- https://raw.githubusercontent.com/523753042/lib-claude-command/main/install.sh | bash
```
