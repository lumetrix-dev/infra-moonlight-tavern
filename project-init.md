为一个新的 work repo 初始化月光酒馆的项目追踪（CLAUDE.md + ROADMAP.md + SPRINT.md + PROJECT.md）。

## 月光酒馆 v2.0 架构

```
moonlight-tavern/          ← 中央 PM 仓库
  repos.yml                注册所有 work repo
  projects/{name}/
    meta.yaml              项目元信息
    ROADWAY.md             长期路线图
    SPRINT.md              当前 Sprint（PR 生命周期驱动状态）
    PROJECT.md             已完成 Sprint 归档

work-repo/                 ← 实际开发仓库
  CLAUDE.md                项目上下文 + 指向月光酒馆
```

## 步骤

### 1. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户：
> 「月光酒馆（infra-moonlight-tavern）在本地的完整路径是？」

保存到记忆（类型：reference）。

### 2. 收集项目信息

询问用户以下信息并确认：
1. **项目名**（用作 `projects/{name}/` 的文件夹名，建议英文短横线命名，如 `demo-lumen-core`）
2. **GitHub repo**（格式：`org/repo-name`）
3. **项目描述**（一句话，如"后端 + AI Pipeline"）

### 3. 探索当前项目（work repo）

了解当前项目结构用于生成 CLAUDE.md：

```bash
ls -la
cat pyproject.toml 2>/dev/null || cat package.json 2>/dev/null || cat go.mod 2>/dev/null || echo "未找到包管理文件"
ls app/ src/ lib/ 2>/dev/null | head -40
git log --oneline -5 2>/dev/null || echo "无 git 历史"
```

### 4. 在月光酒馆中创建项目目录和文件

**4.1 创建目录**
```bash
mkdir -p {月光酒馆路径}/projects/{项目名}
```

**4.2 创建 meta.yaml**
```yaml
name: {项目名}
github: {org/repo-name}
description: "{项目描述}"
color: "#6366F1"
```

颜色可让用户从预设中选择（`#4F46E5` `#6366F1` `#059669` `#D97706` `#DC2626`），默认 `#6366F1`。

**4.3 创建 ROADMAP.md**

```markdown
# {项目名} — 路线图

## 当前阶段

### Phase 1 · 基础能力（进行中）

- [ ] [目标 1：一句话描述第一个 milestone]

## 后续阶段

### Phase 2 · （待规划）

[待定]
```

**4.4 创建 SPRINT.md**

```markdown
# Sprint 1 · {Sprint 目标} — {开始日期} ～ {结束日期}

## E1 · {第一个 Epic}

### S1.1 {Story 标题} (L)

- [ ] T1.1 {任务描述} `owner: {项目名}` `PR: -`

**验收**：可测试的完成条件
```

- Task 编号从 T1.1 开始
- 每个子任务必须带 `owner:` 和 `PR:` 标签
- `owner:` 的值必须等于项目名（对应 repos.yml 中的 name）
- `PR:` 在未开 PR 时为 `-`，其余状态由 PR 生命周期自动推导（**无需手动更新**）

**4.5 创建 PROJECT.md**

```markdown
# {项目名} — 项目归档

## Sprint 归档

| Sprint | 时间 | Epic 数 | 完成率 | 摘要 |
|--------|------|---------|--------|------|
```

### 5. 注册 work repo 到 repos.yml

读取 `{月光酒馆路径}/repos.yml`，在 `repos:` 列表末尾追加：

```yaml
  - name: {项目名}
    github: {org/repo-name}
    description: "{项目描述}"
```

提交并推送变更：

```bash
cd {月光酒馆路径}
git add repos.yml projects/{项目名}/
git commit -m "chore: register {项目名} in repos.yml"
# 不自动 push，提示用户手动 push
```

### 6. 在当前项目（work repo）生成 CLAUDE.md

```markdown
# {项目名} — Agent Context

## 是什么
{项目描述}

## 当前状态
**Sprint 1：[本 Sprint 目标一句话]**

## 项目管理
月光酒馆看板：`infra-moonlight-tavern`（本地路径见 memory）
**任务状态由 PR 生命周期实时推导**，my-tasks / sp-close 会自动查询 GitHub PR 状态
完成需求后**不需要**手动修改月光酒馆的 SPRINT.md

## 技术栈
{从 pyproject.toml / package.json 等自动填充}

## 关键文件
{列出主要目录和入口文件}

## 开发约定
{项目特有约定，如无则写"待补充"}

## 项目管理命令
| 命令 | 用途 | 操作位置 |
|------|------|---------|
| `/plan` | 规划下一个 Sprint | 月光酒馆 projects/{项目名}/SPRINT.md |
| `/ship` | 开 draft PR（title 以 [TXX.X] 开头） | 当前 work repo |
| `/sp-close` | Sprint 结束时聚合所有 PR 状态并归档 | 月光酒馆 |
```

### 7. 输出总结

```
✅ {项目名} 初始化完成

月光酒馆侧（`infra-moonlight-tavern`）：
  - projects/{项目名}/meta.yaml
  - projects/{项目名}/ROADMAP.md
  - projects/{项目名}/SPRINT.md
  - projects/{项目名}/PROJECT.md
  - repos.yml ← 已注册

当前项目侧：
  - CLAUDE.md

可用命令：
  - /plan     规划下一个 Sprint（月光酒馆侧）
  - /ship     开 draft PR 开始任务
  - /sp-close   Sprint 结束时聚合 PR 状态

记得手动 push 月光酒馆的变更：
  cd {月光酒馆路径} && git push
```

## 注意

- 月光酒馆路径仅在首次执行 `/project-init` 时询问，后续命令从记忆自动读取
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
- 不要修改已经存在的文件内容（除非用户明确要求）
- task 编号格式为 T{sprint序号}.{task序号}，如 T1.1、T1.2、T2.1
- owner 值必须与 repos.yml 中的 name 一致
- **任务状态由 PR 生命周期自动推导**：完成需求后 /ship 开 PR，PR merged 后 my-tasks / sp-close 会自动反映最新状态，**无需手动更新月光酒馆的 SPRINT.md**
