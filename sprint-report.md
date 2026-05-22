读取月光酒馆中指定项目的 SPRINT.md，结合 GitHub PR 实时状态，生成进度摘要报告。

## v2.0 变化

任务定义从独立的 `tasks/*.md` 文件迁移到 `SPRINT.md` 层级结构。本命令改为从 SPRINT.md 中解析全量任务并查询 PR 状态。

## 前置条件

- 已安装 `gh` CLI 并已登录
- 需要读取月光酒馆中的 SPRINT.md 文件

## 步骤

### 0. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户并保存到记忆。

### 1. 选择项目

列出 `{月光酒馆路径}/projects/` 下的目录，让用户选择要查看的项目：

```bash
ls {月光酒馆路径}/projects/
```

也可以直接通过命令参数指定（如 `/sprint-report {项目名}`）。

### 2. 读取 SPRINT.md

```bash
cat {月光酒馆路径}/projects/{项目名}/SPRINT.md
```

### 3. 解析全量任务

从 SPRINT.md 中提取所有子任务（`- [ ]` / `- [x]` 行）：
- Task 编号（Txx.x）
- 描述
- checkbox 状态
- owner
- PR 标签

### 4. 读取 repos.yml 获取 repo 映射

```bash
cat {月光酒馆路径}/repos.yml
```

### 5. 对每个 owner/repo 查询 PR 实时状态

按 owner 分组，对每个唯一 repo 执行一次批量查询：

```bash
gh pr list --search "[Txx.x] in:title" --repo {org}/{repo} --state all --json number,title,state,isDraft,mergedAt,url
```

### 6. 推导状态并生成报告

#### 整体进度

| 状态 | 数量 | 占比 |
|------|------|------|
| ✅ done | N | X% |
| 🔵 review | N | X% |
| 🟡 wip | N | X% |
| ⚪ todo | N | X% |
| 🟥 error | N | X% |

#### 按 Epic 细分

每个 Epic 下 Story 的完成情况。

#### 按 owner 细分

每个开发者的任务数和完成情况。

#### 进行中的任务

列出所有 🟡 wip 和 🔵 review 的任务：
```
T1.2 收藏API 🔵 review → PR: #23 demo-lumen-core
```

#### 风险提示

- 超过 3 天仍为 ⚪ todo 的任务
- 超过 5 天仍为 🟡 wip 的任务
- 🟥 error 状态的任务（PR closed 未合并）

### 7. 以 Markdown 格式输出

```markdown
## Sprint 报告 — {项目名}

**Sprint**：{Sprint 标题}
**报告时间**：{当前时间}

### 整体进度
✅ done: N | 🔵 review: N | 🟡 wip: N | ⚪ todo: N | 🟥 error: N
**完成率：X%**

### Epic 详情
...

### 按成员
...

### 进行中的任务
...

### ⚠️ 风险项
...
```

## 注意

- 本命令是只读操作，不修改任何文件
- 需要网络连接以查询 GitHub PR 状态
- 如果某个 repo 不可达，跳过并提示
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
