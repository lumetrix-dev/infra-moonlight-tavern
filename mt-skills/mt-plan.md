---
name: mt-plan
description: "[Moonlight Tavern] Plan the next Sprint. [Moonlight Tavern side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Moonlight Tavern v2.0 Architecture

Moonlight Tavern is the central PM repository. `/mt-plan` always operates on project files within Moonlight Tavern and never touches work repos.

```
moonlight-tavern/projects/{project name}/
  ROADMAP.md     ← Long-term roadmap
  SPRINT.md      ← Current Sprint (status driven by PR lifecycle)
  PROJECT.md     ← Archived completed Sprints
moonlight-tavern/repos.yml  ← Work repo registry (used to validate owner values)
```

## Steps

All write operations are performed within the corresponding project in Moonlight Tavern. No work repos are touched.

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory (type: reference).

### 1. Select project and start Brainstorming

List directories under `{moonlight-tavern-path}/projects/` and let the user select a project.

Once selected, do not read any files yet. First align with the user on what this Sprint should deliver:

- What is the goal of this Sprint?
- Which feature modules are involved?
- What are the priorities and dependencies?

### 2. Read context

After Brainstorming has produced initial conclusions, read files to gather constraints:

```bash
cat {PROJECT_DIR}/ROADMAP.md        # Current Phase goals and long-term plan
cat {PROJECT_DIR}/SPRINT.md 2>/dev/null || echo "No current Sprint"  # Check if incomplete tasks from last Sprint should carry over
cat {moonlight-tavern-path}/repos.yml           # Valid owner list
```

Extract the valid owner list:

```bash
awk -F': ' '/^  - name:/ {print $2}' {moonlight-tavern-path}/repos.yml
```

### 3. Evaluate current Sprint status

- Count `- [x]` and `- [ ]` items in SPRINT.md
- If there are incomplete subtasks, ask the user:
  - Continue the current Sprint (only add new tasks)
  - Start a new Sprint (incomplete tasks are automatically carried over)

### 4. Propose Task breakdown (parent + child structure, each child task must have an owner)

#### Format requirements

```
# Sprint N · {goal} — {start date} – {end date}

## Ex · Epic title
> Goal: one sentence

### Sx.x Story title (XL/L/M/S)
- [ ] Tx.x Task description `owner: {project name}` `PR: -`

**Acceptance criteria**: testable completion conditions (1-2 items)
```

#### Rules
- **Sprint number**: defined by `N` in the title `# Sprint N · ...`, e.g. Sprint 1 → N=1
- **Epic number**: `E1` `E2` ... (continues across Sprints, does not reset)
- **Story number**: `S{sprint number}.{sequence}`, e.g. Sprint 1 Stories are S1.1, S1.2
- **Task number**: `T{sprint number}.{sequence}`, e.g. Sprint 1 Tasks are T1.1, T1.2
- Each child task must include `owner:` and `PR:` tags
- `owner:` must appear in the name list in repos.yml (otherwise report an error and show valid owners)
- Story size annotation: `(XL)` `(L)` `(M)` `(S)`

#### owner validation

For each task's `owner:` value, look it up in the name list in repos.yml:
- Found → valid
- Not found → error: "Invalid owner: {xxx}, valid values: `{valid list}`"

Perform validation during the proposal stage — do not wait until after user confirmation to report errors.

### 5. User confirmation

After displaying the full plan, ask:
- Any adjustments to Epic/Story scope?
- Any missing dependencies?
- **Sprint start and end dates**: Agent automatically estimates a default time range based on Task workload, displays it for user confirmation or adjustment
- Is the Task breakdown reasonable?

### 6. Write to SPRINT.md after confirmation

Write the complete Sprint content to `{PROJECT_DIR}/SPRINT.md`.

If SPRINT.md already exists and the current Sprint is incomplete:
- Ask whether to overwrite (old content will be appended to the bottom of PROJECT.md)
- Or append a new SPRINT section

### 7. Commit and push

After confirmation, commit and push to the remote repository:

```bash
cd {moonlight-tavern-path}
git add projects/{project name}/SPRINT.md
git commit -m "chore: plan sprint {N} for {project name}"
git push
```

The entire process does not touch any work repos.

After pushing, notify the user:

```
✅ Sprint {N} plan committed and pushed

👉 Next: run `/mt-ship` in the work repo to start development — the Agent will automatically open a draft PR and link it to the task.
```

## Output Format Example

## Output Format Example

```
Sprint 2 · Search Feature — 2026-05-26 – 2026-06-01

E1 · Search (from ROADMAP Phase 2)
  S2.1 Global Search Entry (M)
    T2.1 Search box component `owner: frontend-lumen-mobile` `PR: -`
    T2.2 Search API  `owner: demo-lumen-core` `PR: -`
  S2.2 Search Results Page (L)
    T2.3 Results list `owner: frontend-lumen-mobile` `PR: -`
    T2.4 Search term highlighting `owner: frontend-lumen-mobile` `PR: -`

Estimated total workload: ~5 days (2-person team)
```

## Notes

- /mt-plan always operates on the Moonlight Tavern project, not work repos
- All owners must be pre-registered in repos.yml, otherwise an error is reported
- Task numbers follow the format T{sprint}.{sequence}
- Do not modify any files in work repos
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project