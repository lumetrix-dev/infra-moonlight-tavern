规划下一个 Sprint（月光酒馆侧操作）。

## 月光酒馆 v2.0 架构

月光酒馆是中央 PM 仓库，/plan 始终操作月光酒馆下的项目文件，不触碰 work repo。

```
moonlight-tavern/projects/{项目名}/
  ROADMAP.md     ← 长期路线图
  SPRINT.md      ← 当前 Sprint（PR 生命周期驱动状态）
  PROJECT.md     ← 已完成 Sprint 归档
moonlight-tavern/repos.yml  ← work repo 注册表（用于验证 owner 合法性）
```

## 步骤

所有写入操作均在月光酒馆下对应项目中完成，不动任何 work repo。

### 0. 确认月光酒馆路径

从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，询问用户并保存到记忆（类型：reference）。

### 1. 选择项目并唤起 Brainstorming

列出 `{月光酒馆路径}/projects/` 下的目录，让用户选择项目。

选定后，先不做文件读取。直接和用户对齐本 Sprint 要交付什么：

- 本 Sprint 的目标是什么？
- 涉及哪些功能模块？
- 优先级和依赖关系？

### 2. 读取上下文

Brainstorming 有初步结论后，再读取文件获取约束：

```bash
cat {PROJECT_DIR}/ROADMAP.md        # 当前 Phase 目标和长期规划
cat {PROJECT_DIR}/SPRINT.md 2>/dev/null || echo "无当前 Sprint"  # 上次未完成 task 是否延续
cat {月光酒馆路径}/repos.yml           # 合法的 owner 列表
```

提取有效 owner 列表：

```bash
awk -F': ' '/^  - name:/ {print $2}' {月光酒馆路径}/repos.yml
```

### 3. 评估当前 Sprint 状态

- 统计 SPRINT.md 中 `- [x]` 与 `- [ ]` 的数量
- 如果还有未完成子任务，询问用户：
  - 延续当前 Sprint（只补新任务）
  - 开启新 Sprint（当前未完成的自动 carry over）

### 4. 提议 Task 拆解（父+子结构，每个子 task 必带 owner）

#### 格式要求

```
# Sprint N · {目标} — {开始日期} ～ {结束日期}

## Ex · Epic 标题
> 目标：一句话

### Sx.x Story 标题 (XL/L/M/S)
- [ ] Tx.x 任务描述 `owner: {项目名}` `PR: -`

**验收**：可测试的完成条件（1-2条）
```

#### 规则
- **Epic 编号**：`E1` `E2` ...
- **Story 编号**：`S{epic编号}.{序号}`，如 S1.1
- **Task 编号**：`T{sprint编号}.{序号}`，如 T1.1、T1.2
- 每个子 task 必须带 `owner:` 和 `PR:` 标签
- `owner:` 必须出现在 repos.yml 的 name 列表中（否则报错并提示有效 owner）
- Story 标注工作量：`(XL)` `(L)` `(M)` `(S)`

#### owner 验证

对每个 task 的 `owner:` 值，在 repos.yml 的 name 列表中查找：
- 存在 → 合法
- 不存在 → 报错：「无效 owner: {xxx}，有效值：`{有效列表}`」

在提案阶段就完成验证，不要等用户确认后才报错。

### 5. 用户确认

展示完整计划后询问：
- 是否调整 Epic/Story 范围？
- 是否有遗漏的依赖关系？
- Sprint 时间范围是否合适？
- Task 拆分是否合理？

### 6. 确认后写入 SPRINT.md

将完整 Sprint 内容写入 `{PROJECT_DIR}/SPRINT.md`。

如果已有 SPRINT.md 且当前 Sprint 未完成：
- 询问是否覆盖（会将旧内容追加到 PROJECT.md 底部）
- 或者新建一个 SPRINT 段落追加

### 7. 提交并推送

确认后提交并推送到远程仓库：

```bash
cd {月光酒馆路径}
git add projects/{项目名}/SPRINT.md
git commit -m "chore: plan sprint {N} for {项目名}"
git push
```

整个流程不触碰任何 work repo。

推送完成后提示用户：

```
✅ Sprint {N} 规划已提交并推送

👉 下一步：在 work repo 中执行 `/ship` 开始开发，Agent 会自动开 draft PR 并关联任务。
```

## 输出格式示例

## 输出格式示例

```
Sprint 2 · 搜索功能 — 2026-05-26 ～ 2026-06-01

E1 · 搜索（来自 ROADMAP Phase 2）
  S2.1 全局搜索入口 (M)
    T2.1 搜索框组件 `owner: frontend-lumen-mobile` `PR: -`
    T2.2 搜索 API  `owner: demo-lumen-core` `PR: -`
  S2.2 搜索结果页 (L)
    T2.3 结果列表 `owner: frontend-lumen-mobile` `PR: -`
    T2.4 搜索词高亮 `owner: frontend-lumen-mobile` `PR: -`

预计总工作量：约 5 天（2 人团队）
```

## 注意

- /plan 始终操作月光酒馆项目，不操作 work repo
- 所有 owner 必须预先在 repos.yml 中注册，否则报错
- task 编号为 T{sprint}.{序号} 格式
- 不要修改 work repo 的任何文件
- 「月光酒馆」「酒馆」「月光」均指 `infra-moonlight-tavern` 项目
