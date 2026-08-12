---
name: mt-research
description: "[Moonlight Tavern] Guide no-code research/DevOps work — create topic directory, drive research to findings/decision, open draft PR. [Work Repo side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Moonlight Tavern v2.0 Architecture

mt-worklog is a special work repo holding only Markdown deliverables for tasks with no code output. Task status is driven by the PR lifecycle, identical to code repos.

```
moonlight-tavern/projects/mt-worklog/
  SPRINT.md      ← tasks with owner: mt-worklog, PR: -
moonlight-tavern/repos.yml  ← owner validation (name: mt-worklog)
```

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save it to memory (type: reference).

### 1. Select a task

Read `{moonlight-tavern-path}/projects/mt-worklog/SPRINT.md`, list all `- [ ]` subtasks (`owner: mt-worklog`), let the user pick a `Txx.x`:

```bash
cat {moonlight-tavern-path}/projects/mt-worklog/SPRINT.md
```

Determine topic type from the Story/Epic context:
- Research → `research/<topic>/` with `findings.md` + `decision.md`
- DevOps → `devops/<topic>/` with `runbook.md` (or `plan.md`)

`<topic>` is a kebab-case slug, e.g. `brand-feature-gating` or `ci-migration`.

### 2. Create branch + topic directory

```bash
git checkout -b feat/T{XX.X}-{topic-slug}
mkdir -p research/{topic-slug}   # or devops/{topic-slug}
```

Create the topic skeleton with the task's question and open sub-questions:
- Research: `findings.md` (start with task question + "## Open Questions"), `decision.md` (placeholder: "TBD — concluded after findings")
- DevOps: `runbook.md` (start with goal + "## Prerequisites")

### 3. Open draft PR immediately

```bash
git add research/{topic-slug}   # or devops/{topic-slug}
git commit -m "feat: start {topic} — T{XX.X}"
git push -u origin $(git branch --show-current)

gh pr create --draft \
  --title "[T{XX.X}] {task title}" \
  --body "## Task\n\nT{XX.X} · {story}\n\n## Question\n\n{task description}\n\n## Status\n\n🟡 Research in progress — findings being written."
```

Board now shows 🟡 wip for this task.

### 4. Drive research / write the deliverable

For Research tasks, iterate:
- Investigate the question, commit incremental notes to `findings.md` (evidence, links, tradeoffs)
- When a conclusion forms, write `decision.md` (recommendation, rationale, alternatives considered)
- Commit and push each meaningful step

For DevOps tasks:
- Write the runbook/plan content in `runbook.md` as actual steps
- Record verification evidence (logs / screenshots / links) in the PR body, not just the doc

**Never use an empty placeholder commit** — the document itself is the deliverable.

### 5. Finalize PR for review

When the deliverable is complete:
- Ensure `decision.md` (research) or `runbook.md` (devops) has real content
- Update PR body Status section → "🔵 Ready for review"
- Convert PR from draft to ready: `gh pr ready` (or ask user to do it in UI)

### 6. Output result

```
✅ Research PR ready for review

Task:   T{XX.X}
Branch: feat/T{XX.X}-{topic}
PR:     https://github.com/lumetrix-dev/mt-worklog/pull/{N} (ready 🔵)

👉 Next steps:
  - Review the document (substantive read, challenge conclusions)
  - Merge the PR → task becomes ✅ done on the board
  - Run /mt-my-tasks anytime to check status
```

## Notes

- /mt-research runs inside the mt-worklog repo; it does not modify Moonlight Tavern files
- PR title must strictly follow `[TXX.X]` — single task: `[T2.2] desc`
- Task status is derived from the PR lifecycle — never manually edit `[x]` in SPRINT.md
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project
