---
name: mt-ship
description: "[Moonlight Tavern] Create an aggregated draft PR for one or more tasks (supports merging multiple TXX.X tasks into a single PR). [Work Repo side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Workflow

```
/ship
  → Read Moonlight Tavern SPRINT.md, list available tasks
  → User selects one or more tasks (T1.1 T1.2)
  → Create git branch
  → Open draft PR, title prefixed with [T1.1][T1.2]
  → Body contains four sections: Tasks / Changes / Verification / References
  → PR status automatically becomes wip 🟡 (derived in real time by my-tasks / sp-close)
```

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory.

### 1. Select tasks

Read the SPRINT.md for the corresponding project in Moonlight Tavern and list all subtasks (TXX.X) with `- [ ]` status that match the owner:

```bash
cat {moonlight-tavern-path}/projects/{project-name}/SPRINT.md
```

Extract the parent Story (`### Sx.x`) information. Let the user choose:
- **Single task**: enter a single TXX.X
- **Aggregated tasks**: enter multiple TXX.X (e.g. `T1.1 T1.2 T1.3`); all tasks must belong to the same Story

Determine the project name for the current work repo:
- `git remote get-url origin` → get org/repo
- Look up the matching name in `{moonlight-tavern-path}/repos.yml`

### 2. Create branch

```bash
# Single task
git checkout -b feat/T{XX.X}-{short-description}

# Aggregated tasks (use the first task number)
git checkout -b feat/T{XX.X}-{short-description}
```

### 3. Create aggregated PR

```bash
# Commit (or use an empty commit as a placeholder)
git commit --allow-empty -m "feat: {task description}"

# Push and open draft PR
git push -u origin $(git branch --show-current)

gh pr create --draft \
  --title "[T1.1][T1.2] {aggregated title}" \
  --body "## Tasks

| Task | Description  |
|------|-------------|
| T1.1 | {task description}  |
| T1.2 | {task description}  |

## Changes

{describe what changed}

## Verification

{verification steps}

## References

- Moonlight Tavern: {moonlight-tavern-path}/projects/{project-name}/SPRINT.md"
```

PR title format:
- **Aggregated tasks**: `[T1.1][T1.2] {Story title or feature description}`
- **Single task**: `[T1.1] task description`

### 4. Output result

```
✅ Aggregated PR created

Tasks:  T1.1, T1.2, T1.3
Branch: feat/T1.1-{description}
PR:     https://github.com/{org}/{repo}/pull/{N} (draft 🟡)

👉 Next steps:
  - Complete development on the branch, commit and push code
  - Run `/mt-my-tasks` anytime to check task progress and PR status
  - Run `/mt-ship` again to start the next batch of tasks
```

## Notes

- /mt-ship runs inside the work repo and does not modify any files in Moonlight Tavern
- PR title must include `[TXX.X]` (multiple tasks use `[T1.1][T1.2]` format)
- Task status is derived in real time from the PR lifecycle — no need to manually maintain PR tags in SPRINT.md
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project