# claude-commands

Claude Code 全局命令：月光酒馆驱动的 Sprint 研发工作流。

所有命令基于 [infra-moonlight-tavern](https://github.com/523753042/infra-moonlight-tavern)（月光酒馆）中央 PM 仓库，任务状态由 PR 生命周期实时推导。

## 包含命令

### 月光酒馆 — Sprint 工作流

| 命令 | 作用 |
|------|------|
| `/project-init` | 新项目初始化：在月光酒馆创建项目目录 + meta.yaml + ROADMAP/SPRINT/PROJECT，注册 repos.yml，生成 work repo 的 CLAUDE.md |
| `/plan` | 规划下一个 Sprint：从 ROADMAP 拆解 Epic/Story/Task，写入 SPRINT.md |
| `/roadmap` | 规划或更新 ROADMAP.md：基于产品文档和设计稿 brainstorm |
| `/sp-close` | Sprint 结束时聚合所有 PR 状态，更新 SPRINT.md 并归档到 PROJECT.md |

### 月光酒馆 — 状态查询

| 命令 | 作用 |
|------|------|
| `/my-tasks` | 列出当前 work repo 在月光酒馆对应项目的未完成任务 + 实时 PR 状态 |
| `/sprint-report` | 读取 SPRINT.md，结合 GitHub PR 实时状态，生成进度摘要报告 |

### Work Repo 侧

| 命令 | 作用 |
|------|------|
| `/ship` | 为一个或多个任务创建聚合 draft PR（title 以 `[TXX.X]` 开头） |

## 架构

```
moonlight-tavern/          ← 中央 PM 仓库（月光酒馆）
  repos.yml                注册所有 work repo
  projects/{name}/
    meta.yaml              项目元信息
    ROADMAP.md             长期路线图
    SPRINT.md              当前 Sprint（PR 生命周期驱动状态）
    PROJECT.md             已完成 Sprint 归档

work-repo/                 ← 实际开发仓库
  CLAUDE.md                项目上下文 + 指向月光酒馆
```

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

## 文件结构约定

### Sprint 工作流（项目本地）

命令依赖以下文件（`/project-init` 会自动生成）：

- `CLAUDE.md` — 项目上下文，Claude 每次对话自动加载
- `SPRINT.md` — 当前 Sprint 任务追踪（Task 行含看板 ID）
- `PROJECT.md` — 已完成任务归档（只增不改）
- `ROADMAP.md` — 长期规划，`/plan` 读取来拆 Epic

### 月光酒馆（中央 PM 仓库）

```
infra-moonlight-tavern/
├── repos.yml
├── projects/
│   └── {项目名}/
│       ├── meta.yaml
│       ├── ROADMAP.md
│       ├── SPRINT.md
│       └── PROJECT.md
└── sprints/
```

## 更新

重新执行安装命令即可覆盖更新：

```bash
curl -o- https://raw.githubusercontent.com/523753042/lib-claude-command/main/install.sh | bash
```
