# mt-worklog 非代码工作追踪 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让无代码的调研/DevOps 工作通过 mt-worklog 仓库 + 现有 PR 状态机被追踪，看板实时可见。

**Architecture:** mt-worklog 注册为 Tavern 的独立项目，`projects/mt-worklog/` 自有 SPRINT.md。每个任务产出 1 份文档（`research/<topic>/findings.md+decision.md` 或 `devops/<topic>/runbook.md`），合并文档 PR = done。新增 `/mt-research` skill 引导 Claude 执行。状态机、aggregate-data.mjs、index.html 零改动。

**Tech Stack:** Markdown skills (mt-skills)、YAML (repos.yml/meta.yaml)、bash (install.sh)

## Global Constraints

- `owner: mt-worklog` 必须注册在 `repos.yml`（github: lumetrix-dev/mt-worklog），否则 /mt-plan 校验报错
- PR 标题必须含 `[TXX.X]` 才能被自动关联
- 文档 PR 不用空 placeholder commit——文档本身是交付物
- mt-research skill frontmatter 遵循现有约定：`[Moonlight Tavern] {描述}. [Work Repo side]`
- 本地 commit，由用户手动 push（当前 remote 无写权限）
- 本次改动所有文件：`repos.yml`、`projects/mt-worklog/*`、`mt-skills/mt-research.md`、`mt-skills/install.sh`、`mt-skills/.mt-version`、`../mt-worklog/CLAUDE.md`、`../mt-worklog/README.md`

---

### Task 1: 注册 mt-worklog 到 repos.yml

**Files:**
- Modify: `repos.yml`（追加条目）

**Interfaces:**
- Consumes: 现有 repos.yml 格式（`- name: / github: / description:`）
- Produces: `repos` 列表新增 `mt-worklog` 条目

- [ ] **Step 1: 追加 mt-worklog 条目**

在 `repos.yml` 的 `repos:` 列表末尾追加：

```yaml
```

- [ ] **Step 2: 验证 YAML 有效且 owner 可解析**

Run: `python3 -c "import yaml;print([r['name'] for r in yaml.safe_load(open('repos.yml'))['repos']])"`
Expected: 输出包含 `'mt-worklog'`，无解析错误

- [ ] **Step 3: 提交（本地）**

```bash
git add repos.yml
git commit -m "chore: register mt-worklog in repos.yml"
```

---

### Task 2: 创建 projects/mt-worklog/ 四个文件

**Files:**
- Create: `projects/mt-worklog/meta.yaml`
- Create: `projects/mt-worklog/ROADMAP.md`
- Create: `projects/mt-worklog/SPRINT.md`
- Create: `projects/mt-worklog/PROJECT.md`

**Interfaces:**
- Consumes: 参考 `projects/dynsto-page-library/meta.yaml` 与 ROADMAP/PROJECT.md 格式
- Produces: 看板可渲染的完整项目目录（Sprint 视图触发条件 = SPRINT.md 存在）

- [ ] **Step 1: 创建 meta.yaml**

```yaml
name: mt-worklog
description: "无代码调研/DevOps 工作追踪"
color: "#10B981"
members: [Zizek-Lumetrix]
```

- [ ] **Step 2: 创建 ROADMAP.md**

```markdown
# mt-worklog — Roadmap

## Current Status

追踪无代码调研/DevOps 工作：每个任务产出 1 份文档，通过 PR 生命周期驱动状态，与代码任务共用同一套派生逻辑。

## Current Phase

### Phase 1 · 体系建立 (In Progress)

- [ ] **P1.1 首个 Sprint** — 通过 `/mt-plan` 为 mt-worklog 规划第一个 Sprint，任务全部 `owner: mt-worklog`
- [ ] **P1.2 首个调研任务** — 用 `/mt-research` 完成第一个调研任务并合并 PR

## Upcoming Phases

### Phase 2 · (To be planned)

[TBD]
```

- [ ] **Step 3: 创建 SPRINT.md（占位）**

```markdown
# Sprint 1 · To be planned

Run `/mt-plan` to plan the next Sprint.
```

- [ ] **Step 4: 创建 PROJECT.md**

```markdown
# mt-worklog — Project Archive

## Sprint Archive

| Sprint | Period | Epics | Completion | Summary |
|--------|--------|-------|------------|---------|
```

- [ ] **Step 5: 验证目录结构与现有项目一致**

Run: `ls projects/mt-worklog/`
Expected: `meta.yaml ROADMAP.md SPRINT.md PROJECT.md` 四个文件

- [ ] **Step 6: 提交（本地）**

```bash
git add projects/mt-worklog/
git commit -m "chore: init mt-worklog project directory"
```

---

### Task 3: 新增 /mt-research skill

**Files:**
- Create: `mt-skills/mt-research.md`

**Interfaces:**
- Consumes: SPRINT.md 任务格式、repos.yml owner 校验、mt-ship 的 PR 约定
- Produces: `/mt-research` 命令——运行于 mt-worklog 仓库，建主题目录 + 开 draft PR + 引导调研成文

- [ ] **Step 1: 编写 mt-research.md**

```markdown
---
name: mt-research
description: "[Moonlight Tavern] Guide no-code research/DevOps work — create topic directory, drive research to findings/decision, open draft PR. [Work Repo side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Moonlight Tavern v2.0 Architecture

mt-worklog is a special work repo holding only Markdown deliverables for tasks with no code output. Task status is driven by the PR lifecycle, identical to code repos.

```
moonlight-tavern/projects/mt-worklog/
  SPRINT.md      ← tasks with owner: mt-worklog, PR: -
moonlight-tavern/repos.yml  ← owner validation (name: mt-worklog)
```

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory (type: reference).

### 1. Select a task

Read `{moonlight-tavern-path}/projects/mt-worklog/SPRINT.md`, list all `- [ ]` subtasks (`owner: mt-worklog`), let the user pick a `Txx.x`:

```bash
cat {moonlight-tavern-path}/projects/mt-worklog/SPRINT.md
```

Determine topic type from the Story/Epic context:
- Research → `research/<topic>/` with `findings.md` + `decision.md`
- DevOps → `devops/<topic>/` with `runbook.md` (or `plan.md`)

`<topic>` is a kebab-case slug, e.g. `brand-feature-gating` or `ci-migration`.

### 2. Create branch + topic directory

```bash
git checkout -b feat/T{XX.X}-{topic-slug}
mkdir -p research/{topic-slug}   # or devops/{topic-slug}
```

Create the topic skeleton with the task's question and open sub-questions:
- Research: `findings.md` (start with task question + "## Open Questions"), `decision.md` (placeholder: "TBD — concluded after findings")
- DevOps: `runbook.md` (start with goal + "## Prerequisites")

### 3. Open draft PR immediately

```bash
git add research/{topic-slug}   # or devops/{topic-slug}
git commit -m "feat: start {topic} — T{XX.X}"
git push -u origin $(git branch --show-current)

gh pr create --draft \
  --title "[T{XX.X}] {task title}" \
  --body "## Task\n\nT{XX.X} · {story}\n\n## Question\n\n{task description}\n\n## Status\n\n🟡 Research in progress — findings being written."
```

Board now shows 🟡 wip for this task.

### 4. Drive research / write the deliverable

For Research tasks, iterate:
- Investigate the question, commit incremental notes to `findings.md` (evidence, links, tradeoffs)
- When a conclusion forms, write `decision.md` (recommendation, rationale, alternatives considered)
- Commit and push each meaningful step

For DevOps tasks:
- Write the runbook/plan content in `runbook.md` as actual steps
- Record verification evidence (logs / screenshots / links) in the PR body, not just the doc

**Never use an empty placeholder commit** — the document itself is the deliverable.

### 5. Finalize PR for review

When the deliverable is complete:
- Ensure `decision.md` (research) or `runbook.md` (devops) has real content
- Update PR body Status section → "🔵 Ready for review"
- Convert PR from draft to ready: `gh pr ready` (or ask user to do it in UI)

### 6. Output result

```
✅ Research PR ready for review

Task:   T{XX.X}
Branch: feat/T{XX.X}-{topic}
PR:     https://github.com/lumetrix-dev/mt-worklog/pull/{N} (ready 🔵)

👉 Next steps:
  - Review the document (substantive read, challenge conclusions)
  - Merge the PR → task becomes ✅ done on the board
  - Run /mt-my-tasks anytime to check status
```

## Notes

- /mt-research runs inside the mt-worklog repo; it does not modify Moonlight Tavern files
- PR title must strictly follow `[TXX.X]` — single task: `[T2.2] desc`
- Task status is derived from the PR lifecycle — never manually edit `[x]` in SPRINT.md
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project
```

- [ ] **Step 2: 验证 frontmatter 与文件位置**

Run: `head -3 mt-skills/mt-research.md`
Expected: frontmatter 以 `---` 开头，含 `name: mt-research`

- [ ] **Step 3: 提交（本地）**

```bash
git add mt-skills/mt-research.md
git commit -m "feat(mt-skills): add mt-research skill for no-code work"
```

---

### Task 4: install.sh 注册 skill + bump 版本

**Files:**
- Modify: `mt-skills/install.sh`（SKILLS 数组）
- Modify: `mt-skills/.mt-version`（2.3.6 → 2.3.7）

**Interfaces:**
- Consumes: install.sh 的 `SKILLS=(...)` 数组（第 12 行附近）
- Produces: `/mt-research` 可被安装脚本拉取到 `~/.agents/skills/`

- [ ] **Step 1: SKILLS 数组追加 mt-research**

在 `install.sh` 的 `SKILLS=(mt-plan mt-ship mt-project-init mt-my-tasks mt-sprint-report mt-roadmap mt-sp-close mt-update)` 末尾追加 `mt-research`：

```bash
SKILLS=(mt-plan mt-ship mt-project-init mt-my-tasks mt-sprint-report mt-roadmap mt-sp-close mt-update mt-research)
```

- [ ] **Step 2: bump .mt-version**

将 `mt-skills/.mt-version` 内容从 `2.3.6` 改为 `2.3.7`。

- [ ] **Step 3: 验证**

Run: `grep -c "mt-research" mt-skills/install.sh && cat mt-skills/.mt-version`
Expected: `1`（数组中出现一次）与 `2.3.7`

- [ ] **Step 4: 提交（本地）**

```bash
git add mt-skills/install.sh mt-skills/.mt-version
git commit -m "chore(mt-skills): register mt-research skill, bump to 2.3.7"
```

---

### Task 5: 对齐 mt-worklog 仓库的 CLAUDE.md + README.md

**Files:**
- Modify: `../mt-worklog/CLAUDE.md`（`/Users/sylvain/Documents/workspace/mt-worklog/CLAUDE.md`）
- Modify: `../mt-worklog/README.md`（`/Users/sylvain/Documents/workspace/mt-worklog/README.md`）

**Interfaces:**
- Consumes: 现有 mt-worklog/CLAUDE.md 与 README.md 内容（需检查并重写）
- Produces: mt-worklog 仓库自身的 Agent 上下文 + 结构说明，对齐独立项目模式

- [ ] **Step 1: 阅读当前文件确认待改点**

Run: `cat /Users/sylvain/Documents/workspace/mt-worklog/CLAUDE.md /Users/sylvain/Documents/workspace/mt-worklog/README.md`
Expected: 确认两处需改——CLAUDE.md 的"任务分散在其他项目 SPRINT"描述、README.md 的目录结构

- [ ] **Step 2: 重写 CLAUDE.md**

将 `## Project Management` 段改为独立项目模式——mt-worklog 有**自己的** `projects/mt-worklog/SPRINT.md`，任务 `owner: mt-worklog` 全部集中于此；删去 "no `owner:` tasks of its own Sprint" 一句。文档结构改为：

```
research/{topic}/
  findings.md
  decision.md
devops/{topic}/
  runbook.md
```

skills 表格补 `/mt-research` 行。Prerequisites 里的安装命令 URL 改为 `infra-moonlight-tavern/main/mt-skills/install.sh`。

- [ ] **Step 3: 重写 README.md**

目录结构改为 `research/<topic>/` + `devops/<topic>/` 两套；使用方式说明改为"在 mt-worklog 仓库里运行 `/mt-research` 选择 TXX.X 任务"。

- [ ] **Step 4: 验证**

Run: `grep -c "mt-research" /Users/sylvain/Documents/workspace/mt-worklog/CLAUDE.md`
Expected: 出现 `mt-research`（≥1 次）；`grep -c "scattered across" /Users/sylvain/Documents/workspace/mt-worklog/CLAUDE.md` → 输出 `0`

- [ ] **Step 5: 提交（mt-worklog 仓库，本地）**

```bash
cd /Users/sylvain/Documents/workspace/mt-worklog
git add CLAUDE.md README.md
git commit -m "chore: align with independent-project mode — mt-research skill, topic dirs"
```

---

## Self-Review

**Spec coverage:**
- 注册 repos.yml → Task 1 ✅
- 建 projects/mt-worklog/ → Task 2 ✅
- mt-research skill → Task 3 ✅
- install.sh + 版本 bump → Task 4 ✅
- mt-worklog 仓库 CLAUDE.md/README.md 对齐 → Task 5 ✅
- 零改动状态机/aggregate/index.html → 计划未列出这些文件 ✅

**Placeholder scan:** 无 TBD/TODO 占位（ROADMAP.md 的 `[TBD]` 是 spec 明确要求的 Phase 2 占位，属预期）。

**Type consistency:** `owner: mt-worklog`、`repos.yml` name、`projects/mt-worklog/` 目录名三处一致；PR 标题 `[TXX.X]` 约定与现有 mt-ship 一致。
