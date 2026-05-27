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

## 安装和更新

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

## 使用流程

完整的 Sprint 研发工作流，从零到交付：

### 1. 安装命令

在终端执行安装脚本，将所有命令注册到 Claude Code：

```bash
curl -o- https://raw.githubusercontent.com/523753042/lib-claude-command/main/install.sh | bash
```

安装后重启 Claude Code，所有项目中即可直接使用 `/plan`、`/ship` 等命令。

### 2. 准备月光酒馆仓库

如果还没有月光酒馆中央 PM 仓库，克隆到本地，每个人的地址可能不同：

```bash
git clone https://github.com/523753042/infra-moonlight-tavern.git
```

或者新建一个空文件夹，后续 `/project-init` 会自动初始化结构。文件结构见上方 **文件结构** 一节。

### 3. 初始化项目或拉取已有项目

**新项目**：在本地新建一个 work repo，初始化 git 并配置好远程仓库，然后执行：

```
/project-init
```

Agent 会引导你完成：
- 在月光酒馆中创建项目目录 + `meta.yaml`
- 生成 `ROADMAP.md`、`SPRINT.md`、`PROJECT.md`
- 注册 `repos.yml`
- 在当前 work repo 生成 `CLAUDE.md`

**已有项目**：如果已经有现成的 work repo，直接 clone 到本地即可：

```bash
git clone <work-repo-url>
cd <work-repo>
```

无需额外初始化，直接进入下一步。

### 4. 规划路线图

```
/roadmap
```

建议这一步把产品文档（PRD）和设计稿一并提供给 Agent，让 Agent 基于完整上下文 brainstorm 并写入 `ROADMAP.md`。

### 5. 规划当前 Sprint

```
/plan
```

Agent 会从 `ROADMAP.md` 拆解出 Epic → Story → Task，写入 `SPRINT.md`，完成当前 Sprint 的规划。

### 6. 开始开发

```
/ship
```

Agent 会自动：
- 读取 `SPRINT.md` 列出可选任务
- 根据你的选择创建 git 分支
- 自动开 draft PR（title 包含任务编号 `[TXX.X]`）
- PR body 包含任务 / 变更 / 验证 / 关联四段

`/ship` 可反复执行，每轮完成一批任务后继续下一批。

### 7. 查看进度

随时执行 `/my-tasks` 查看当前任务进度和 PR 实时状态。Agent 会引导你继续通过 `/ship` 推进剩余工作。

### 8. 归档并进入下一轮

当前 `SPRINT.md` 中所有任务完成后，手动执行：

```
/sp-close
```

Agent 会聚合所有 PR 状态，更新 `SPRINT.md` 并归档到 `PROJECT.md`，然后引导你执行 `/plan` 进入下一个 Sprint。

循环 **步骤 5 → 8**，直到 `ROADMAP.md` 中所有内容完成。

### 9. 中途需求变更

如果开发中途任务内容有调整，直接告诉 Agent 需求有变更。把更新后的 PRD 给 Agent，Agent 会同步更新 `SPRINT.md` 和 `ROADMAP.md`。

---

## 更新

重新执行安装命令即可覆盖更新：

```bash
curl -o- https://raw.githubusercontent.com/523753042/lib-claude-command/main/install.sh | bash
```
