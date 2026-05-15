# claude-commands

Claude Code 全局命令：Sprint 驱动的研发工作流。

## 包含命令

| 命令 | 作用 |
|------|------|
| `/plan` | 规划下一个 Sprint，生成 Epic/Story/Task 写入 `SPRINT.md` |
| `/ship` | 完成任务后打勾 `SPRINT.md`，Story 完成则归档到 `PROJECT.md` |
| `/standup` | 读取 git 日志 + 任务状态，输出 15 行项目快照 |
| `/project-init` | 新项目一键初始化：生成 `CLAUDE.md` + `SPRINT.md` + `PROJECT.md` + `ROADMAP.md` |

## 安装

```bash
curl -o- https://raw.githubusercontent.com/lumetrix-dev/lib-claude-command/main/install.sh | bash
```

或者 clone 后本地安装（离线场景）：

```bash
git clone https://github.com/lumetrix-dev/lib-claude-command
cd claude-commands && bash install.sh
```

安装后重启 Claude Code，所有项目中直接使用 `/plan`、`/ship` 等命令。

## 工作流

```
新项目：/project-init
    ↓
规划：/plan
    ↓
开发 → commit
    ↓
完成：/ship
    ↓
同步：/standup
```

## 文件结构约定

命令依赖以下文件（`/project-init` 会自动生成）：

- `CLAUDE.md` — 项目上下文，Claude 每次对话自动加载
- `SPRINT.md` — 当前 Sprint 任务追踪
- `PROJECT.md` — 已完成任务归档（只增不改）
- `ROADMAP.md` — 长期规划，`/plan` 读取来拆 Epic

## 更新

```bash
cd claude-commands
git pull && ./install.sh
```
