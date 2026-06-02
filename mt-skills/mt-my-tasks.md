---
name: mt-my-tasks
description: "[Moonlight Tavern] List incomplete tasks and show real-time PR status. [Work Repo side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Prerequisites

- `gh` CLI installed and authenticated
- Requires reading repos.yml from Moonlight Tavern and the corresponding project's SPRINT.md

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory.

### 1. Identify the current work repo's project name in Moonlight Tavern

Get the current repository's `org/repo` via git remote, then find the matching name in repos.yml:

```bash
# Get the GitHub org/repo of the current repository
git remote get-url origin | sed 's/.*:\(.*\)\.git/\1/'

# Find the corresponding project name in repos.yml
grep -A2 "$ORG_REPO" {moonlight-tavern-path}/repos.yml
```

If matching fails, notify the user and exit.

Set the variable `PROJECT_NAME` to the matched name.

### 2. Read the corresponding project's SPRINT.md

```bash
cat {moonlight-tavern-path}/projects/{PROJECT_NAME}/SPRINT.md
```

### 3. Extract all tasks from SPRINT.md

Parse the markdown hierarchy to extract:
- Epic titles (`## Ex · xxx`)
- Story titles (`### Sx.x xxx`)
- Subtasks (`- [x] Txx.x xxx \`owner: xxx\` \`PR: xxx\``)

### 4. Read repos.yml to get GitHub repo mappings

```bash
cat {moonlight-tavern-path}/repos.yml
```

### 5. Query real-time PR status for each task

For each task, find the corresponding GitHub repo in repos.yml (matching by owner), then:

```bash
gh pr list --search "[Txx.x] in:title" --repo {org}/{repo} --state all --json number,title,state,isDraft,mergedAt,url
```

### 6. Derive task status

| Condition | Status | Icon |
|-----------|--------|------|
| No matching PR | todo | ⚪ |
| PR isDraft | wip | 🟡 |
| PR open + ready | review | 🔵 |
| PR merged | done | ✅ |
| PR closed without merge | error | 🟥 |

### 7. Display results

Show all tasks organized by Epic → Story hierarchy:

```
📋 {project name} — Current Tasks

E1 · Core Framework
  S1.1 Navigation Setup
    T1.1 Configure Tab Navigation    ✅ done  PR: #5 (merged)
    T1.2 Add Home Screen            🟡 wip   PR: #8 (draft)

Summary: 0 todo · 1 in progress · 1 done

👉 There are incomplete tasks. Run `/mt-ship` to continue development.
```

### 8. Risk alerts

If any task has been open for more than 5 days with a PR still in draft or no PR opened:
```
⚠️ The following tasks have not progressed in over 5 days:
  T1.2 Add Home Screen (PR open for 7 days, still draft)
```

## Notes

- This command is read-only and does not modify any files
- Task status is derived in real-time from the PR lifecycle, not from manually maintained status fields
- Automatically matches the current git remote to the corresponding Moonlight Tavern project
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project