# /my-tasks

列出当前用户（或指定成员）在 `infra-moonlight-tavern` 看板中的所有未完成任务。

## 注意事项

- 看板项目名：**infra-moonlight-tavern**（「月光酒馆」「酒馆」「月光」均指该项目）
- 用户可能不在该目录下执行此命令，需先确认项目在本地的路径并保存到记忆

## 步骤

0. **确认项目路径（首次运行）**：从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，主动询问用户该项目在本地的完整路径，然后保存到记忆中。

1. 获取 assignee：优先使用命令参数（如 `/my-tasks zhang.san`），其次询问用户，最后尝试读取 git config 的 user.email 前缀。

2. 读取 `{project-root}` 中所有任务文件（`projects/*/tasks/*.md`），筛选出：
   - assignee 匹配
   - status 不为 `done`

3. 按优先级排序（high → medium → low），再按 updated 日期排序（旧的优先）。

4. 输出任务列表，每条包含：`[{status}] {id} - {title}（{priority}，Sprint: {sprint}）`

5. 如果有任务 status 为 `pending` 超过 5 天（对比 created 日期），提示用户考虑推进或取消。
