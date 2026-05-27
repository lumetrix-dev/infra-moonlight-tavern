列出当前 work repo 在月光酒馆对应项目的未完成任务，并显示实时 PR 状态。

## 前置条件

- 已安装 `gh` CLI 并已登录
- 需要读取月光酒馆中的 repos.yml 和对应项目的 SPRINT.md

## 步骤

### 0. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户并保存到记忆。

### 1. 确定当前 work repo 在月光酒馆中的项目名

通过 git remote 获取当前仓库的 `org/repo`，然后在 repos.yml 中查找匹配的 name：

```bash
# 获取当前仓库的 GitHub org/repo
git remote get-url origin | sed 's/.*:\(.*\)\.git/\1/'

# 从 repos.yml 找对应的项目名
grep -A2 "$ORG_REPO" {月光酒馆路径}/repos.yml
```

如果匹配失败，提示用户并退出。

设定变量 `PROJECT_NAME` 为匹配到的 name。

### 2. 读取对应项目的 SPRINT.md

```bash
cat {月光酒馆路径}/projects/{PROJECT_NAME}/SPRINT.md
```

### 3. 从 SPRINT.md 中提取所有任务

解析 markdown 层级结构，提取：
- Epic 标题（`## Ex · xxx`）
- Story 标题（`### Sx.x xxx`）
- 子任务（`- [x] Txx.x xxx \`owner: xxx\` \`PR: xxx\``）

### 4. 读取 repos.yml 获取 GitHub repo 映射

```bash
cat {月光酒馆路径}/repos.yml
```

### 5. 对每个任务查询 PR 实时状态

对每个任务，从 repos.yml 找对应的 github repo（匹配 owner），然后：

```bash
gh pr list --search "[Txx.x] in:title" --repo {org}/{repo} --state all --json number,title,state,isDraft,mergedAt,url
```

### 6. 推导任务状态

| 条件 | 状态 | 图标 |
|------|------|------|
| 无匹配 PR | todo | ⚪ |
| PR isDraft | wip | 🟡 |
| PR open + ready | review | 🔵 |
| PR merged | done | ✅ |
| PR closed 未合并 | error | 🟥 |

### 7. 输出结果

按 Epic → Story 层级展示所有任务：

```
📋 {项目名} — 当前任务

E1 · 基础框架
  S1.1 导航搭建
    T1.1 配置 Tab 导航        ✅ done  PR: #5 (merged)
    T1.2 添加主页            🟡 wip   PR: #8 (draft)

汇总：0 待办 · 1 进行中 · 1 已完成

👉 还有未完成任务，执行 `/ship` 继续开发。
```

### 8. 风险提示

如果有任务超过 5 天且 PR 仍是 draft 或未开 PR：
```
⚠️ 以下任务超过 5 天未推进：
  T1.2 添加主页（已开 PR 7 天，仍为 draft）
```

## 注意

- 本命令是只读操作，不修改任何文件
- 任务状态由 PR 生命周期实时推导，不依赖手动维护的状态字段
- 自动匹配当前 git remote 对应的月光酒馆项目
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
