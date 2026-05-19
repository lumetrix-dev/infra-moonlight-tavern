# /update-task

更新 `infra-moonlight-tavern` 看板中已有任务的字段。

## 注意事项

- 看板项目名：**infra-moonlight-tavern**
- 用户可能不在该目录下执行此命令，需先确认项目在本地的路径并保存到记忆

## 步骤

0. **确认项目路径（首次运行）**：从记忆中读取 `infra-moonlight-tavern` 的本地路径。如果没有记录，主动询问用户该项目在本地的完整路径，然后保存到记忆中。

1. 询问用户要更新哪个任务（可输入任务 ID 如 `lumen-core-001`，或从列表选择）。

2. 读取对应任务文件内容，展示当前值。

3. 询问要修改哪些字段：
   - status（pending / in_progress / review / done）
   - priority（high / medium / low）
   - assignee
   - sprint
   - tags

4. 仅修改用户指定的字段。自动将 `updated` 字段更新为今天日期（YYYY-MM-DD）。

5. 写回文件，保持 Markdown 正文不变。

6. 切换到 `{project-root}` 目录执行 git commit 和 push：
```bash
cd {project-root} && git add projects/{project}/tasks/{file} && git commit -m "chore: update task {id} status to {new_status}" && git push origin main
```

7. 告知用户更新完成。
