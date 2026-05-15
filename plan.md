规划下一个 Sprint。

## 步骤

1. **读取当前状态**
   - `SPRINT.md` — 当前 Sprint 是否还有未完成的 Epic/Story/Task
   - `ROADMAP.md` — 下一个 Phase 的详细规划
   - `PROJECT.md` — 已完成的变更历史（了解进度）
   - `CLAUDE.md` — 当前阶段和技术约定

2. **评估当前 Sprint**
   - 统计 SPRINT.md 中 `- [x]` 与 `- [ ]` 的数量
   - 判断是否需要延续当前 Sprint 或开启新 Sprint

3. **提出下一个 Sprint 的 Epic/Story/Task 拆解**

   每个 Epic 对应 ROADMAP 中的一个 Phase 目标，每个 Story 是用户/系统可感知的结果（1-3天），每个 Task 是具体实现步骤（几小时）。

   格式如下，严格遵守：
   ```markdown
   ## Ex · Epic 标题
   > 目标：一句话说清楚为谁解决什么问题

   ### Sx.x Story 标题
   - [ ] Txx 任务描述 `涉及文件`
   - [ ] Txx 任务描述 `涉及文件`

   **验收**：可测试的完成条件（1-2条）
   ```

   Task 编号续 PROJECT.md 现有最大编号。

4. **等待用户确认**

   展示计划后询问：
   - 是否调整 Epic/Story 范围？
   - 是否有遗漏的依赖关系？
   - Sprint 时间范围是否合适？

5. **确认后执行**

   a. 将新 Sprint 内容写入 `SPRINT.md`，替换或追加（视情况）
   b. 更新 `CLAUDE.md` 的「当前状态」节，反映新 Sprint 目标
   c. 在 PROJECT.md 待办任务表中补录新 Epic 级任务（保持历史完整）

## 输出格式示例

```
Sprint 2026-05-XX ～ 2026-05-XX

E1 · [Epic 名]（来自 ROADMAP Phase X.X）
  S1.1 · [Story]（M）
    T27 · [Task]
    T28 · [Task]
  S1.2 · [Story]（S）
    T29 · [Task]

预计总工作量：约 X 天（3人团队）
```
