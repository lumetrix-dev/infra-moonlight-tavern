# Moonlight Tavern (infra-moonlight-tavern)

Lightweight multi-repo project management. PR = status. Git = database. Zero backend.

## Key Files

| Path | Purpose |
|------|---------|
| `repos.yml` | Registered work repos (name must match `projects/` folder) |
| `projects/{name}/SPRINT.md` | Current Sprint — Epic → Story → Task hierarchy |
| `projects/{name}/ROADMAP.md` | Long-term roadmap |
| `projects/{name}/PROJECT.md` | Completed Sprint archive |
| `frontend/scripts/aggregate-data.mjs` | Parses SPRINT.md + fetches PR statuses → `data.json` |
| `frontend/index.html` | SPA dashboard (vanilla JS, no build) |
| `mt-skills/` | Claude Code slash commands + installer |

## SPRINT.md Format

```markdown
# Sprint 2 · Goal — 2026-05-26 ～ 2026-06-08

## E1 · Epic Title
> Goal: one sentence

### S1.1 Story Title (M)
- [x] T1.1 Task description `owner: <repo-name>` `PR: #5`
- [ ] T1.2 Task description `owner: <repo-name>` `PR: -`

**Acceptance**: testable criteria
```

- Task numbering: `T{sprint}.{seq}` — e.g. T1.1, T2.3
- `owner:` must match a name in `repos.yml`
- `PR: -` = not started; status is derived live from the PR lifecycle, never set manually

## Status Derivation

| PR State | Status | Icon |
|----------|--------|------|
| No PR | todo | ⚪ |
| Draft | wip | 🟡 |
| Open + ready | review | 🔵 |
| Merged | done | ✅ |
| Closed unmerged | error | 🟥 |

## Commands

| Command | Side | Purpose |
|---------|------|---------|
| `/mt-plan` | Tavern | Plan Sprint → write SPRINT.md |
| `/mt-roadmap` | Tavern | Plan or update ROADMAP.md |
| `/mt-sp-close` | Tavern | Aggregate PR statuses + archive at Sprint end |
| `/mt-project-init` | Work Repo | Initialize project + register in repos.yml |
| `/mt-ship` | Work Repo | Open draft PR with `[TXX.X]` title |
| `/mt-my-tasks` | Work Repo | List tasks + live PR status |
| `/mt-sprint-report` | Work Repo | Generate Sprint progress report |
| `/mt-update` | Work Repo | Check for command updates |

## Conventions

- **Do not** edit `frontend/data.json` — CI-generated, overwritten on every deploy
- **Do not** add framework dependencies to `index.html` — keep zero build
- PR titles must contain `[TXX.X]` to be auto-linked to tasks
- After editing SPRINT.md, commit and push; CI rebuilds the dashboard within 5 minutes

## Versioning

Before pushing functional changes, check if `mt-skills/.mt-version` needs a patch bump (e.g. `2.0.0` → `2.0.1`).
