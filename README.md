# claude-commands

Claude Code 全局命令：Sprint 驱动的研发工作流 + 看板任务管理。

包含两个命令组，Group 1 执行时会自动同步到看板。

## 包含命令

### Group 1 — Sprint 工作流（在当前项目目录执行）

| 命令 | 作用 |
|------|------|
| `/project-init` | 新项目一键初始化：生成 `CLAUDE.md` + `SPRINT.md` + `PROJECT.md` + `ROADMAP.md`，并同步创建看板项目目录 |
| `/plan` | 规划下一个 Sprint，生成 Epic/Story/Task 写入 `SPRINT.md`，**自动在看板中为每个 Task 创建任务** |
| `/ship` | 完成任务后打勾 `SPRINT.md`，Story 完成则归档到 `PROJECT.md`，**自动同步看板任务状态为 done** |
| `/standup` | 读取 git 日志 + 任务状态，输出 15 行项目快照 |

### Group 2 — 看板任务管理（管理 infra-moonlight-tavern 看板）

| 命令 | 作用 |
|------|------|
| `/my-tasks` | 查看当前用户在看板中的未完成任务 |
| `/new-task` | 在看板中创建新任务（生成 `tasks/task-xxx.md` + git commit） |
| `/update-task` | 更新看板任务的状态、优先级、负责人等字段 |
| `/sprint-report` | 按 Sprint 生成进度报告（按项目/成员细分） |

## 两组命令的集成

Group 1 和 Group 2 管理的是同一套任务数据，无需重复操作：

```
/project-init  → 生成项目文件 + 在看板创建项目目录
     ↓
/plan          → 规划 Sprint + 自动为每个 Task 创建看板任务
     ↓
开发 → commit
     ↓
/ship          → 更新 SPRINT.md + 自动同步看板任务为 done
     ↓
/standup       → 生成项目状态快照
```

**看板任务 ID 格式：** `{项目目录名}-{编号}`（如 `my-project-001`），显示在 SPRINT.md 的 Task 行末尾。

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

### 看板项目（独立仓库）

```
infra-moonlight-tavern/
├── projects/
│   └── {项目名}/
│       └── tasks/
│           ├── task-001.md
│           └── task-002.md
└── sprints/
    └── sprint-2026-05.md
```

## 更新

重新执行安装命令即可覆盖更新：

```bash
curl -o- https://raw.githubusercontent.com/523753042/lib-claude-command/main/install.sh | bash
```
