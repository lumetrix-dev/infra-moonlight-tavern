# mt-worklog — 非代码工作（调研/DevOps）追踪流程设计

日期：2026-08-12 · 状态：已批准

## 背景与问题

Moonlight Tavern 的状态机制完全依赖 PR 生命周期（⚪todo → 🟡wip → 🔵review → ✅done → 🟥error）。
调研、DevOps 等没有具体代码产出的任务没有 PR，状态会永远停在 todo，无法追踪。

## 目标

- 用一套独立机制追踪非代码工作，进度在 Moonlight Tavern 看板实时可见
- **零改动**现有状态机、`aggregate-data.mjs`、看板 `index.html`
- 完全复用 PR 生命周期驱动状态

## 核心决策

| 维度 | 决定 |
|------|------|
| 状态信号 | **文档即交付物**——每个非代码任务产出 1 份文档，合并该文档的 PR = done |
| 项目组织 | **独立项目**——`projects/mt-worklog/` 自有 SPRINT.md，所有非代码任务集中于此 |
| 文档结构 | **按主题目录**——`research/<topic>/` 与 `devops/<topic>/` |
| 执行方式 | **Claude 主导**——新增 `/mt-research` skill 引导调研→成文→PR |
| 开 PR 时机 | **建目录即开 draft PR**——wip 从第一分钟起全程可见 |
| 类型处理 | **一个 skill 两类**——调研→findings+decision；DevOps→runbook/plan |

## 架构

```
infra-moonlight-tavern/               ← PM 侧（Tavern）
  repos.yml                           ← 注册 mt-worklog
  projects/mt-worklog/
    meta.yaml                         ← 项目元数据
    ROADMAP.md                        ← 长期计划（调研/DevOps 阶段）
    SPRINT.md                         ← 当前 Sprint（非代码任务集中地）
    PROJECT.md                        ← 归档
  mt-skills/mt-research.md            ← 新增 skill（核心交付物）

mt-worklog/                           ← 产物仓库（Work Repo 侧，lumetrix-dev/mt-worklog）
  research/<topic>/
    findings.md                       ← 调研过程/发现（边调研边 commit）
    decision.md                       ← 结论/建议（收尾产出）
  devops/<topic>/
    plan.md / runbook.md              ← 计划/操作手册
```

## 数据流（复用现有管道）

1. `/mt-plan` → 为 mt-worklog 项目规划 Sprint，任务带 `owner: mt-worklog`
2. `/mt-research`（mt-worklog 仓库内）→ 建主题目录 + 开 draft PR `[TXX.X]`
3. Claude 调研，commit 更新 `findings.md` → 产出 `decision.md`
4. PR 标 ready（🔵 review）→ merge（✅ done）
5. `/mt-sp-close` 聚合 PR 状态 → 归档

聚合脚本按 `owner` → `repos.yml` 查 repo → `gh pr list` 匹配 `[TXX.X]`。
mt-worklog 与其他仓库走同一条路，无需改动。

## /mt-research skill 行为

运行于 `mt-worklog` 仓库（Work Repo side）：

### 1. 选任务
- 读 Tavern `projects/mt-worklog/SPRINT.md`，列出未完成任务
- 用户选择 `Txx.x`

### 2. 建主题目录
- 根据 Story/任务判断类型：
  - 调研 → `research/<topic>/`：`findings.md` + `decision.md` + 待答问题清单
  - DevOps → `devops/<topic>/`：`plan.md` / `runbook.md`
- `<topic>` 用 kebab-case slug

### 3. 开 draft PR
- 分支 + `[TXX.X]` 标题 + PR body（含待答问题）
- 看板立即显示 🟡 wip

### 4. 调研→成文
- Claude 边调研边 commit `findings.md`（记录过程、证据、链接）
- 收尾产出 `decision.md`（结论、建议、取舍）
- DevOps 任务在 PR body 记录验证证据（日志/截图/链接）

### 5. Review → Merge
- PR 标 ready → 🔵 review
- merge → ✅ done

## 改动文件清单

| 位置 | 动作 |
|------|------|
| Tavern `repos.yml` | 注册 `mt-worklog`（github: lumetrix-dev/mt-worklog） |
| Tavern `projects/mt-worklog/` | 新建 `meta.yaml` + `ROADMAP.md` + `SPRINT.md` + `PROJECT.md` |
| Tavern `mt-skills/mt-research.md` | 新增 skill |
| Tavern `mt-skills/install.sh` | `SKILLS` 数组加 `mt-research` |
| Tavern `.mt-version` | 2.3.1 → 2.3.2 |
| `mt-worklog/CLAUDE.md` + `README.md` | 对齐独立项目模式（去掉"任务分散在其他项目"描述） |

## 零改动

- 状态机（PR 生命周期→状态映射）
- `aggregate-data.mjs`
- 看板 `index.html`
- `mt-ship` / `mt-sp-close` / `mt-my-tasks` / `mt-plan`

## 注意事项

- `owner: mt-worklog` 必须在 `repos.yml` 中注册，否则 /mt-plan 校验报错
- PR 标题必须含 `[TXX.X]` 才能被自动关联
- 不要用空 placeholder commit——文档本身是交付物
- 文档 PR 的 review 应是实质性审阅（真的读、挑战结论），不是走过场
