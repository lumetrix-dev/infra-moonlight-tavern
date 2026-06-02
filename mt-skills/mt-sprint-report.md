---
name: mt-sprint-report
description: "[Moonlight Tavern] Read SPRINT.md, combine with live GitHub PR status, and generate a progress summary report. [Work Repo side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## v2.0 Changes

Task definitions have been migrated from standalone `tasks/*.md` files to a hierarchical structure in `SPRINT.md`. This command now parses the full task list from SPRINT.md and queries PR status.

## Prerequisites

- `gh` CLI installed and authenticated
- Access to SPRINT.md in the Moonlight Tavern repository

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory.

### 1. Select a project

List directories under `{moonlight-tavern-path}/projects/` and let the user choose which project to view:

```bash
ls {moonlight-tavern-path}/projects/
```

You can also specify the project directly via a command argument (e.g. `/sprint-report {project name}`).

### 2. Read SPRINT.md

```bash
cat {moonlight-tavern-path}/projects/{project-name}/SPRINT.md
```

### 3. Parse all tasks

Extract all subtasks from SPRINT.md (`- [ ]` / `- [x]` lines):
- Task number (Txx.x)
- Description
- Checkbox state
- owner
- PR label

### 4. Read repos.yml for repo mapping

```bash
cat {moonlight-tavern-path}/repos.yml
```

### 5. Query live PR status for each owner/repo

Group by owner and run one batch query per unique repo:

```bash
gh pr list --search "[Txx.x] in:title" --repo {org}/{repo} --state all --json number,title,state,isDraft,mergedAt,url
```

### 6. Derive status and generate report

#### Overall progress

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ done | N | X% |
| 🔵 review | N | X% |
| 🟡 wip | N | X% |
| ⚪ todo | N | X% |
| 🟥 error | N | X% |

#### Breakdown by Epic

Completion status for each Story under each Epic.

#### Breakdown by owner

Task count and completion status for each developer.

#### In-progress tasks

List all 🟡 wip and 🔵 review tasks:
```
T1.2 Favorites API 🔵 review → PR: #23 demo-lumen-core
```

#### Risk warnings

- Tasks still ⚪ todo after 3+ days
- Tasks still 🟡 wip after 5+ days
- Tasks in 🟥 error state (PR closed without merge)

### 7. Output in Markdown format

```markdown
## Sprint Report — {project name}

**Sprint**: {Sprint title}
**Report time**: {current time}

### Overall Progress
✅ done: N | 🔵 review: N | 🟡 wip: N | ⚪ todo: N | 🟥 error: N
**Completion rate: X%**

### Epic Details
...

### By Member
...

### In-Progress Tasks
...

### ⚠️ Risk Items
...
```

## Notes

- This command is read-only and does not modify any files
- Network access is required to query GitHub PR status
- If a repo is unreachable, skip it and show a warning
- "Moonlight Tavern", "Tavern", and "Moonlight" all refer to the `infra-moonlight-tavern` project