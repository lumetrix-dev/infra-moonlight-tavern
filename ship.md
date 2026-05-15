完成任务后更新项目追踪。

## 步骤

1. **读取变更信息**
   - `git log --oneline -10` — 最近提交
   - `git diff --stat HEAD~5` — 变更文件概览
   - 如有未提交变更，运行 `git status` 和 `git diff --stat`

2. **读取 SPRINT.md**
   - 找到与本次变更对应的 Task（`- [ ] Txx ...`）
   - 判断对应 Story 的所有 Task 是否全部完成

3. **更新 SPRINT.md**
   - 将已完成的 Task 从 `- [ ]` 改为 `- [x]`
   - 如果一个 Story 的所有 Task 都打勾，在 Story 标题行末尾加 `✅`

4. **如果有 Story 完成（全部 Task ✅）**
   - 读取 PROJECT.md
   - 在「变更记录」表**顶部**插入新行：
     ```
     | YYYY-MM-DD | 任务编号 | 变更文件（逗号分隔，省略 app/） | 一句话中文摘要 |
     ```
   - SPRINT.md 中该 Story 的 Task 列表保留（历史可查），Story 标题保持 ✅

5. **判断是否需要更新 CLAUDE.md**
   - 引入新技术依赖、改变关键架构模式、修改开发约定 → 更新对应章节
   - 小改动不更新

6. **建议提交信息**（如有未提交变更）
   - 格式：`type(scope): 简短描述`
   - type: feat / fix / refactor / chore / docs

7. 报告本次更新了什么

## 注意

- 只打勾确实完成的 Task，不要臆测
- PROJECT.md 变更记录按时间倒序，新记录插到最上面
- 不要改变两个文件的表格/列表结构
