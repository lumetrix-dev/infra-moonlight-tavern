[Moonlight Tavern] At Sprint end, aggregate PR status across all work repos, update SPRINT.md, and archive to PROJECT.md once the Sprint is fully complete. [Moonlight Tavern side]

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## How it works

Iterate over every `[ ]` / `[x]` subtask's `PR:` tag in SPRINT.md:
- If `PR: -` (no PR opened) → ⚪ todo
- Query the actual PR status via the GitHub API, overriding the static tag
- Automatically derive parent Story/Epic completion status

Status mapping:
```
No PR opened         →  todo   ⚪
PR is draft          →  wip    🟡
PR is open + ready   →  review 🔵
PR is merged         →  done   ✅
PR is closed unmerged →  error  🟥
```

## Prerequisites

- `gh` CLI installed and authenticated (`gh auth status`)
- GitHub Token available or already authenticated via `gh`
- Read access to each work repo

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory.

### 1. Select project

List the directories under `{moonlight-tavern-path}/projects/` and let the user choose which project to operate on:

```bash
ls {moonlight-tavern-path}/projects/
```

After selection, set `PROJECT_DIR={moonlight-tavern-path}/projects/{project-name}`.

### 2. Read SPRINT.md and repos.yml

```bash
cat {PROJECT_DIR}/SPRINT.md
```

### 3. Parse subtask list

Extract all subtask lines from SPRINT.md (lines beginning with `- [ ]` / `- [x]`), capturing:
- Task number (e.g. `T1.1`)
- Owner tag (`owner: xxx`)
- PR tag (`PR: xxx`)

### 4. Build owner → repo mapping

```bash
python3 -c "
import yaml
with open('{moonlight-tavern-path}/repos.yml') as f:
    data = yaml.safe_load(f)
for r in data['repos']:
    print(f\"{r['name']} -> {r['github']}\")
"
```

If python3 + pyyaml is unavailable, parse using awk or node.js.

### 5. Query PR status for each subtask

For each subtask that has an owner:

```bash
gh pr list --search "[T1.1] in:title" --repo {github_repo} --state all --json number,title,state,isDraft,mergedAt,url 2>/dev/null
```

#### Status derivation logic

| gh output condition | Derived status | PR tag update |
|---------------------|---------------|---------------|
| No matching PR | ⚪ todo | `PR: -` |
| isDraft == true | 🟡 wip | `PR: draft` |
| state == OPEN && isDraft == false | 🔵 review | `PR: #N` |
| mergedAt is not null | ✅ done | `PR: #N` |
| state == CLOSED && mergedAt == null | 🟥 error | `PR: #N` |

#### Strategy when multiple PRs match

The same task may have PRs in multiple repos (e.g. frontend + backend collaboration):
- If any PR is merged → task status is ✅ done
- Otherwise, take the most "advanced" status: review > wip > todo
- Show only the most recent PR number in the `PR:` tag

### 6. Update SPRINT.md

Update the `PR:` tag and checkbox state for each task line based on query results:
- Status ✅ merged → `- [x]`, `PR: #N`
- Status 🔵 review → `- [ ]`, `PR: #N`
- Status 🟡 wip → `- [ ]`, `PR: draft`
- Status 🟥 error → `- [ ]`, `PR: #N` (mark as anomaly)
- Status ⚪ todo → `- [ ]`, `PR: -`

#### Parent Story completion check

When all subtasks under a Story (`### Sx.x`) are `[x]` + `PR: #N` (merged):
- Append `✅` to the end of the Story title line
- No additional action required

#### Parent Epic completion check

When all Stories under an Epic (`## Ex`) are ✅:
- Append `✅` to the end of the Epic title line

### 7. Sprint fully complete → archive to PROJECT.md

When all tasks in SPRINT.md have status ✅ done, ask the user whether to archive:

1. Append the Sprint content (from `# Sprint N` to end of file) to the top of PROJECT.md
2. Update the PROJECT.md archive table:
   ```
   | Sprint N | {date} | {epics completed} | 100% | {summary} |
   ```
3. Clear SPRINT.md and write placeholder content:
   ```
   # Sprint {N+1} · To be planned
   
   Run `/mt-plan` to plan the next Sprint.
   ```

### 8. Commit and push

```bash
cd {moonlight-tavern-path}
git add projects/{project-name}/SPRINT.md projects/{project-name}/PROJECT.md 2>/dev/null
git commit -m "chore: close sprint {N} for {project-name}"
git push
```

After pushing, prompt the user:

```
✅ Sprint {N} archived and pushed

👉 Next step: run `/plan` to start the next Sprint and break down new Tasks from the ROADMAP.

Loop: /plan → /ship → /sp-close, until all items in the ROADMAP are complete.
```

## Output example

```
🔍 Aggregating PR status...

E1 · Fill in missing pages
  S1.1 Topic detail page (L)
    T1.1 Banner + topic info layout  ✅ merged (#12)  owner: frontend-lumen-mobile
    T1.2 Favorites API               🔵 review (#23)  owner: demo-lumen-core
  S1.2 POI detail page (L)
    T1.3 POI info display            ✅ merged (#14)  owner: frontend-lumen-mobile

📊 Summary:
  ✅ done:   4 / 7
  🔵 review: 2 / 7
  🟡 wip:    1 / 7
  ⚪ todo:   0 / 7
```

## Notes

- Idempotent operation: running multiple times has no side effects, only overwrites and updates PR status
- Only queries PRs in work repos; does not modify any files in work repos
- Must be run in an environment with the `gh` CLI available
- If a repo is unreachable over the network, skip it and notify the user
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project
- PR tag format in SPRINT.md: `PR: -` (not opened), `PR: draft` (draft), `PR: #N` (PR opened)
