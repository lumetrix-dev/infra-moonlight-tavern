Sprint 结束时聚合所有 work repo 的 PR 状态，更新 SPRINT.md，并在 Sprint 全部完成后归档到 PROJECT.md。

## 工作原理

遍历 SPRINT.md 中每个 `[ ]` / `[x]` 子任务的 `PR:` 标签：
- 如果 `PR: -`（未开 PR）→ ⚪ todo
- 通过 GitHub API 查询 PR 实际状态，覆盖静态标签
- 自动推导父级 Story/Epic 完成状态

状态映射：
```
PR 还没开           →  todo   ⚪
PR 是 draft         →  wip    🟡
PR 是 open + ready  →  review 🔵
PR 是 merged        →  done   ✅
PR 是 closed 未合并  →  error  🟥
```

## 前置条件

- 已安装 `gh` CLI 并已登录（`gh auth status`）
- 有 GitHub Token 或已通过 `gh` 认证
- 对每个 work repo 有读取权限

## 步骤

### 0. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户并保存到记忆。

### 1. 选择项目

列出 `{月光酒馆路径}/projects/` 下的目录，让用户选择要操作的项目：

```bash
ls {月光酒馆路径}/projects/
```

选定后设 `PROJECT_DIR={月光酒馆路径}/projects/{项目名}`。

### 2. 读取 SPRINT.md 和 repos.yml

```bash
cat {PROJECT_DIR}/SPRINT.md
```

### 3. 解析子任务列表

从 SPRINT.md 中提取所有子任务行（`- [ ]` / `- [x]` 开头的 task 行），提取：
- Task 编号（如 `T1.1`）
- Owner 标签（`owner: xxx`）
- PR 标签（`PR: xxx`）

### 4. 构建 owner → repo 映射

```bash
python3 -c "
import yaml
with open('{月光酒馆路径}/repos.yml') as f:
    data = yaml.safe_load(f)
for r in data['repos']:
    print(f\"{r['name']} -> {r['github']}\")
"
```

如果没有 python3 + pyyaml，使用 awk 或 node.js 解析。

### 5. 对每个子任务查询 PR 状态

对每个含有 owner 的子任务：

```bash
gh pr list --search "[T1.1] in:title" --repo {github_repo} --state all --json number,title,state,isDraft,mergedAt,url 2>/dev/null
```

#### 状态推导逻辑

| gh 输出条件 | 推导状态 | PR 标签更新 |
|------------|---------|-----------|
| 无匹配 PR | ⚪ todo | `PR: -` |
| isDraft == true | 🟡 wip | `PR: draft` |
| state == OPEN && isDraft == false | 🔵 review | `PR: #N` |
| mergedAt 不为 null | ✅ done | `PR: #N` |
| state == CLOSED && mergedAt == null | 🟥 error | `PR: #N` |

#### 多条 PR 匹配时的策略

同一个 task 可能在多个 repo 有 PR（如前端 + 后端协作）：
- 如果有任意一个 PR 是 merged → task 状态为 ✅ done
- 否则取最"前进"的状态：review > wip > todo
- 只显示最新的 PR 编号在 `PR:` 标签中

### 6. 更新 SPRINT.md

根据查询结果更新每个 task 行的 `PR:` 标签和 checkbox 状态：
- 状态为 ✅ merged → `- [x]`，`PR: #N`
- 状态为 🔵 review → `- [ ]`，`PR: #N`
- 状态为 🟡 wip → `- [ ]`，`PR: draft`
- 状态为 🟥 error → `- [ ]`，`PR: #N`（标注异常）
- 状态为 ⚪ todo → `- [ ]`，`PR: -`

#### 父级 Story 完成判断

当某个 Story（`### Sx.x`）下的所有子 task 都是 `[x]` + `PR: #N`（merged）：
- 在 Story 标题行末尾添加 `✅`
- 不需要额外操作

#### 父级 Epic 完成判断

当某个 Epic（`## Ex`）下的所有 Story 都 ✅：
- 在 Epic 标题行末尾添加 `✅`

### 7. Sprint 全部完成 → 归档到 PROJECT.md

当 SPRINT.md 中所有任务状态均为 ✅ done 时，询问用户是否归档：

1. 将 Sprint 内容（从 `# Sprint N` 到文件末尾）追加到 PROJECT.md 顶部
2. 更新 PROJECT.md 归档表格：
   ```
   | Sprint N | {时间} | {完成Epic数} | 100% | {摘要} |
   ```
3. 在 SPRINT.md 中添加标记：
   ```
   # Sprint N · {目标} — {时间}
   **状态：已关闭，等待 /plan 开启新 Sprint**
   ```

### 8. 提交并推送

```bash
cd {月光酒馆路径}
git add projects/{项目名}/SPRINT.md projects/{项目名}/PROJECT.md 2>/dev/null
git commit -m "chore: close sprint {N} for {项目名}"
git push
```

推送完成后提示用户：

```
✅ Sprint {N} 已归档并推送

👉 下一步：执行 `/plan` 开启下一个 Sprint，从 ROADMAP 中拆解新的 Task。

循环 /plan → /ship → /sp-close，直到 ROADMAP 中所有内容完成。
```

## 输出示例

```
🔍 开始聚合 PR 状态...

E1 · 补齐缺失页面
  S1.1 话题详情页 (L)
    T1.1 Banner + 话题信息布局 ✅ merged (#12)  owner: frontend-lumen-mobile
    T1.2 收藏 API              🔵 review (#23)  owner: demo-lumen-core
  S1.2 POI 详情页 (L)
    T1.3 POI 信息展示           ✅ merged (#14)  owner: frontend-lumen-mobile

📊 汇总：
  ✅ done:   4 / 7
  🔵 review: 2 / 7
  🟡 wip:    1 / 7
  ⚪ todo:   0 / 7
```

## 注意

- 幂等操作：多次运行不会产生副作用，只会覆盖更新 PR 状态
- 只查询 work repo 中的 PR，不修改 work repo 的任何文件
- 需要在有 `gh` CLI 的环境中执行
- 如果某个 repo 网络不可达，跳过并提示用户
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
- SPRINT.md 中的 PR 标签格式：`PR: -`（未开）、`PR: draft`（草稿）、`PR: #N`（已开 PR）
