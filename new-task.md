# /new-task

看板项目 `infra-moonlight-tavern` 的新任务创建。

## 注意事项

- 看板项目名：**infra-moonlight-tavern**
- 用户可能不在该目录下执行此命令，需先确认项目在本地的路径并保存到记忆

## 步骤

1. **确认项目路径（首次运行）**：从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，主动询问用户该项目在本地的完整路径，然后保存到记忆中。

2. 询问用户以下信息（如未在命令参数中提供）：
   - 所属项目（列出 `{project-root}/projects/` 下的目录让用户选择）
   - 任务标题
   - 优先级（high / medium / low，默认 medium）
   - 负责人（assignee，默认当前用户名）
   - 所属 sprint（列出 `{project-root}/sprints/` 下的文件让用户选择，默认最新）

3. 确定任务 ID：读取对应项目 `{project-root}/projects/{project}/tasks/` 目录，找出最大编号，+1。格式：`{project}-{number:03d}`（如 `lumen-core-002`）。

4. 生成任务文件内容：

```
---
id: {id}
title: {title}
status: pending
priority: {priority}
assignee: {assignee}
project: {project}
sprint: {sprint}
created: {today YYYY-MM-DD}
updated: {today YYYY-MM-DD}
tags: []
---

## 目标
（由用户填写）

## 验收标准
- [ ] 
```

5. 将文件写入 `{project-root}/projects/{project}/tasks/task-{number:03d}.md`。

6. 切换到 `{project-root}` 目录执行 git commit 和 push：
```bash
cd {project-root} && git add projects/{project}/tasks/task-{number:03d}.md && git commit -m "feat: add task {id} - {title}" && git push origin main
```

7. 告知用户文件已创建，看板将在下次刷新后更新。
