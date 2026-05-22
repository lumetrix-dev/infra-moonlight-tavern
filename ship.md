为一个或多个任务创建聚合 draft PR（支持多个 TXX.X 合并到一个 PR）。

## 工作流

```
/ship
  → 读取月光酒馆 SPRINT.md，列出可选任务
  → 用户选择一个或多个任务（T1.1 T1.2）
  → 创建 git 分支
  → 开 draft PR，title 以 [T1.1][T1.2] 开头
  → body 包含：任务 / 变更 / 验证 / 关联 四段
  → PR 状态自动变为 wip 🟡（由 my-tasks / sp-close 实时推导）
```

## 步骤

### 0. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户并保存到记忆。

### 1. 选择任务

读取月光酒馆对应项目的 SPRINT.md，列出所有 `- [ ]` 状态、owner 匹配的子任务（TXX.X）：

```bash
cat {月光酒馆路径}/projects/{项目名}/SPRINT.md
```

提取所属 Story（`### Sx.x`）的信息。让用户选择：
- **单个任务**：直接输入 TXX.X
- **聚合任务**：输入多个 TXX.X（如 `T1.1 T1.2 T1.3`），这些任务必须在同一个 Story 下

判断当前 work repo 对应的项目名：
- `git remote get-url origin` → 获取 org/repo
- 在 `{月光酒馆路径}/repos.yml` 中查找匹配的 name

### 2. 创建分支

```bash
# 单个任务
git checkout -b feat/T{XX.X}-{简短描述}

# 聚合任务（取第一个 task 编号）
git checkout -b feat/T{XX.X}-{简短描述}
```

### 3. 创建聚合 PR

```bash
# 提交（或用空 commit 占位）
git commit --allow-empty -m "feat: {任务描述}"

# push 并开 draft PR
git push -u origin $(git branch --show-current)

gh pr create --draft \
  --title "[T1.1][T1.2] {聚合标题}" \
  --body "## 任务

| Task | 描述 | 状态 |
|------|------|------|
| T1.1 | {任务描述} | 🟡 |
| T1.2 | {任务描述} | 🟡 |

## 变更

{描述变更内容}

## 验证

{验证步骤}

## 关联

- 月光酒馆：{月光酒馆路径}/projects/{项目名}/SPRINT.md"
```

PR title 格式：
- **聚合任务**：`[T1.1][T1.2] {Story 标题或功能描述}`
- **单个任务**：`[T1.1] 任务描述`

### 4. 输出结果

```
✅ 聚合 PR 已创建

任务：T1.1, T1.2, T1.3
分支：feat/T1.1-{描述}
PR：  https://github.com/{org}/{repo}/pull/{N}（draft 🟡）

下一步：
  - 在分支上完成开发，提交代码
  - my-tasks 或 sp-close 会自动通过 PR 标题推导任务状态
```

## 注意

- /ship 在 work repo 中执行，不修改月光酒馆的任何文件
- PR 标题必须包含 `[TXX.X]`（多个 task 用 `[T1.1][T1.2]` 格式）
- 任务状态由 PR 生命周期实时推导，无需手动维护 SPRINT.md 中的 PR 标签
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
