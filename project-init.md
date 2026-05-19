为新项目初始化 sprint 工作流（CLAUDE.md + SPRINT.md + PROJECT.md + ROADMAP.md）。

## 步骤

### 1. 探索当前项目

运行以下命令了解项目结构：

```bash
ls -la
cat pyproject.toml 2>/dev/null || cat package.json 2>/dev/null || cat go.mod 2>/dev/null || echo "未找到包管理文件"
ls app/ src/ lib/ 2>/dev/null | head -40
git log --oneline -5 2>/dev/null || echo "无 git 历史"
```

检查是否已存在以下文件（存在则询问用户是否覆盖）：
- `CLAUDE.md`
- `SPRINT.md`
- `PROJECT.md`
- `ROADMAP.md`

### 2. 向用户确认关键信息

展示探索结果后，询问：

1. **项目是什么**（一句话，如果 README 里有则自动提取）
2. **当前阶段目标**（第一个 Sprint 要做什么）
3. **团队规模**（影响 Sprint 容量估算）

### 3. 生成 CLAUDE.md

根据探索结果和用户输入生成，**必须包含以下章节**：

```markdown
# [项目名] — Agent Context

## 是什么
[一句话描述：面向谁、解决什么问题]

## 当前状态
**Sprint [日期]：[本 Sprint 目标一句话]**

## 技术栈
| 层 | 技术 |
|----|------|
[从 pyproject.toml / package.json 等自动填充]

## 关键文件
[列出主要目录和入口文件]

## 开发约定
[列出项目特有的约定，如无则写"待补充"]

## 常用命令
[从 package.json scripts 或 Makefile 提取，如无则写启动命令]

## 项目追踪文件
| 文件 | 作用 |
|------|------|
| `SPRINT.md` | 当前 Sprint 的 Epic/Story/Task，用 `- [x]` 追踪进度 |
| `PROJECT.md` | 已完成任务的变更历史，只增不改 |

## 自定义命令
| 命令 | 用途 |
|------|------|
| `/ship` | 完成任务后打勾 SPRINT.md，Story 完成则写入 PROJECT.md |
| `/plan` | 规划下一个 Sprint，生成 Epic/Story/Task 结构写入 SPRINT.md |
| `/standup` | 生成项目状态快照 |
```

### 4. 生成 SPRINT.md

```markdown
# [项目名] — Sprint [开始日期] ～ [结束日期]

> [本 Sprint 目标一句话]

## 总览

| Epic | 主题 | 估算 | 状态 |
|------|------|------|------|
| E1 | [用户输入的第一个 Epic] | - | ⬜ |

---

## E1 · [Epic 标题]

> 目标：[一句话]

### S1.1 [Story 标题]

- [ ] T1 [任务描述]

**验收**：[可测试的完成条件]
```

### 5. 生成 PROJECT.md

```markdown
# [项目名] — 项目追踪

## 变更记录

| 日期 | 任务 | 变更文件 | 摘要 |
|------|------|----------|------|

## 待办任务

| # | 任务 | 优先级 | 状态 | 说明 |
|---|------|--------|------|------|
| 1 | [Sprint 1 主要目标] | P0 | ⬜ | Sprint [日期] |
```

### 6. 生成 ROADMAP.md

```markdown
# [项目名] — 路线图

## 当前阶段

### Phase 1 · [阶段名]（进行中）

- [ ] [主要目标]

## 后续阶段

### Phase 2 · [阶段名]（待规划）

[待定]
```

### 7. 确认并写入

展示所有生成内容，询问用户确认后写入文件。

写入完成后输出：

```
✅ 工作流初始化完成

已生成：
- CLAUDE.md     项目上下文（每次对话自动加载）
- SPRINT.md     当前 Sprint 任务追踪
- PROJECT.md    变更历史归档
- ROADMAP.md    长期规划

可用命令：
- /plan     规划下一个 Sprint
- /ship     完成任务后更新追踪
- /standup  生成项目状态快照

建议下一步：运行 /plan 来细化当前 Sprint 的 Task 拆解。
```

### 8. 同步看板项目

Project-init 执行到这一步表示用户确认了所有文件。此时自动同步到看板项目：

1. **确认看板路径**：从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户该看板项目在本地的完整路径，然后保存到记忆中。

2. **创建项目目录**：获取当前项目目录名（`basename $(pwd)`），在看板项目中确保 `projects/{当前目录名}/tasks/` 和 `projects/{当前目录名}/sprints/` 目录存在，不存在则创建。

3. **创建看板 sprint 文件**：在看板 `sprints/` 目录下检查是否已有当前 Sprint 对应的 sprint 文件，没有则创建一个与 SPRINT.md 对应的 sprint 记录。

4. **告知同步结果**：「已同步看板项目，后续 /plan 和 /ship 将自动创建/更新看板任务。」

## 注意

- 如果某个文件已存在且内容完整，跳过不覆盖，只告知用户
- CLAUDE.md 是最重要的文件，宁可多问一句也不要填错技术栈
- Task 编号从 T1 开始（PROJECT.md 无历史时）
- 看板路径只在首次执行 project-init 时需要询问，后续 Group 1 命令会自动从记忆中读取
