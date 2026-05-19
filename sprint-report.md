# /sprint-report

读取指定 sprint 的所有任务，生成进度摘要报告。

## 注意事项

- 看板项目名：**infra-moonlight-tavern**
- 用户可能不在该目录下执行此命令，需先确认项目在本地的路径并保存到记忆

## 步骤

1. **确认项目路径（首次运行）**：从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，主动询问用户该项目在本地的完整路径，然后保存到记忆中。

2. 询问用户要查看哪个 sprint（列出 `{project-root}/sprints/` 下的文件，默认最新）。

3. 读取 `{project-root}` 中所有项目的所有任务文件（`projects/*/tasks/*.md`），筛选出 sprint 字段匹配的任务。

4. 生成报告，包含：
   - **整体进度**：各状态任务数量（pending / in_progress / review / done）及百分比
   - **按项目细分**：每个项目各状态任务数
   - **按成员细分**：每个 assignee 的任务数和完成情况
   - **进行中的任务列表**：列出所有 in_progress 和 review 的任务（id + title + assignee）
   - **风险提示**：超过 3 天未更新 updated 字段的 in_progress 任务

5. 以 Markdown 格式输出报告。
