[Moonlight Tavern] Initialize Moonlight Tavern project tracking for a new work repo (CLAUDE.md + ROADMAP.md + SPRINT.md + PROJECT.md). [Work Repo side]

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Moonlight Tavern v2.0 Architecture

```
moonlight-tavern/          ← Central PM repository
  repos.yml                Registers all work repos
  projects/{name}/
    meta.yaml              Project metadata
    ROADMAP.md             Long-term roadmap
    SPRINT.md              Current Sprint (status driven by PR lifecycle)
    PROJECT.md             Completed Sprint archive

work-repo/                 ← Actual development repository
  CLAUDE.md                Project context + pointer to Moonlight Tavern
```

## Steps

### 0. Verify prerequisites

Before proceeding, verify the following are available:

**Superpowers plugin** — provides brainstorming, planning, debugging, and TDD skills:
```bash
# Check if superpowers is installed (look for skill files)
ls ~/.claude/plugins/ 2>/dev/null | grep superpowers
```
If not found, prompt the user:
> "The Superpowers plugin is required for this workflow. Please install it first: in Claude Code, run `/plugins` and search for **superpowers**."

**GitHub CLI (`gh`)** — required for PR status queries and automation:
```bash
gh --version
```
If not found, prompt the user:
> "`gh` (GitHub CLI) is required. Install it from https://cli.github.com, then run `gh auth login`."

Only continue once both are confirmed (or the user explicitly chooses to skip).

### 1. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user:
> "What is the full local path to Moonlight Tavern (infra-moonlight-tavern)?"

Save to memory (type: reference).

### 2. Collect project information

Ask the user for the following information and confirm:
1. **Project name** (used as the folder name under `projects/{name}/`, recommended kebab-case in English, e.g. `demo-lumen-core`)
2. **GitHub repo** (format: `org/repo-name`)
3. **Project description** (one sentence, e.g. "Backend + AI Pipeline")

### 3. Explore the current project (work repo)

Understand the current project structure in order to generate CLAUDE.md:

```bash
ls -la
cat pyproject.toml 2>/dev/null || cat package.json 2>/dev/null || cat go.mod 2>/dev/null || echo "No package manager file found"
ls app/ src/ lib/ 2>/dev/null | head -40
git log --oneline -5 2>/dev/null || echo "No git history"
```

If the current directory has not been initialized with git, help the user do so. **Default branch is `main`, remote also uses `main`**:

```bash
git init -b main
git remote add origin <remote repository URL provided by user>
```

### 4. Create project directory and files in Moonlight Tavern

**4.1 Create directory**
```bash
mkdir -p {moonlight-tavern-path}/projects/{project-name}
```

**4.2 Create meta.yaml**
```yaml
name: {project-name}
description: "{project-description}"
color: "#6366F1"
members: [{current git user}]
```

Let the user choose a color from presets (`#4F46E5` `#6366F1` `#059669` `#D97706` `#DC2626`), default is `#6366F1`.

**4.3 Create ROADMAP.md**

```markdown
# {project-name} — Roadmap

## Current Phase

### Phase 1 · Foundation (In Progress)

- [ ] [Goal 1: one-sentence description of the first milestone]

## Upcoming Phases

### Phase 2 · (To be planned)

[TBD]
```

**4.4 Create SPRINT.md**

```markdown
# Sprint 1 · {Sprint Goal} — {start date} – {end date}

## E1 · {First Epic}

### S1.1 {Story Title} (L)

- [ ] T1.1 {task description} `owner: {project-name}` `PR: -`

**Acceptance**: Testable completion criteria
```

- Task numbering starts from T1.1
- Each subtask must include `owner:` and `PR:` tags
- The `owner:` value must equal the project name (matching the name in repos.yml)
- `PR:` is `-` when no PR is open; other statuses are automatically derived from the PR lifecycle (**no manual update needed**)

**4.5 Create PROJECT.md**

```markdown
# {project-name} — Project Archive

## Sprint Archive

| Sprint | Period | Epics | Completion | Summary |
|--------|--------|-------|------------|---------|
```

### 5. Register work repo in repos.yml

Read `{moonlight-tavern-path}/repos.yml` and append to the end of the `repos:` list:

```yaml
  - name: {project-name}
    github: {org/repo-name}
    description: "{project-description}"
```

Commit and push changes:

```bash
cd {moonlight-tavern-path}
git add repos.yml projects/{project-name}/
git commit -m "chore: register {project-name} in repos.yml"
git push
```

### 6. Generate CLAUDE.md in the current project (work repo)

```markdown
# {project-name} — Agent Context

## What It Is
{project-description}

## Prerequisites
- **Moonlight Tavern commands** installed: `curl -fsSL https://raw.githubusercontent.com/lumetrix-dev/infra-moonlight-tavern/main/lib-claude-command/install.sh | bash`
- **Superpowers plugin** installed in Claude Code (provides brainstorming, planning, debugging, TDD skills)
- **GitHub CLI (`gh`)** installed and authenticated (`gh auth login`) — required for PR status queries

## Project Management
Moonlight Tavern board: `infra-moonlight-tavern` (see local path in memory)
**Task status is derived in real time from the PR lifecycle** — my-tasks / sp-close automatically query GitHub PR status
After completing a task, you do **not** need to manually update SPRINT.md in Moonlight Tavern

**Prohibited behavior**: When using Claude in the work repo, **never directly modify task checkbox states in Moonlight Tavern's `SPRINT.md`** (e.g. changing `- [ ]` to `- [x]`). Task status is automatically derived from the PR lifecycle; only `/sp-close` and `/plan` commands are authorized to modify SPRINT.md.

**Command update check**: Before the first interaction each day, automatically run `/mt-update` to check for new command versions.

## Tech Stack
{auto-populated from pyproject.toml / package.json, etc.}

## Key Files
{list main directories and entry files}

## Development Conventions
{project-specific conventions, or "TBD" if none}

## Project Management Commands
| Command | Purpose | Location |
|---------|---------|---------|
| `/plan` | Plan the next Sprint | Moonlight Tavern projects/{project-name}/SPRINT.md |
| `/ship` | Open a draft PR (title starts with [TXX.X]) | Current work repo |
| `/sp-close` | Aggregate all PR statuses and archive at Sprint end | Moonlight Tavern |
```

### 7. Push work repo changes

Commit and push CLAUDE.md in the current work repo:

```bash
git add CLAUDE.md
git commit -m "chore: add CLAUDE.md for moonlight-tavern integration"
git push
```

### 8. Output summary

```
✅ {project-name} initialization complete

Moonlight Tavern side (`infra-moonlight-tavern`):
  - projects/{project-name}/meta.yaml
  - projects/{project-name}/ROADMAP.md
  - projects/{project-name}/SPRINT.md
  - projects/{project-name}/PROJECT.md
  - repos.yml ← registered and pushed

Current project side:
  - CLAUDE.md ← committed and pushed

Available commands:
  - /roadmap  Plan the roadmap based on PRD and designs (next step)
  - /plan     Plan the next Sprint (Moonlight Tavern side)
  - /ship     Open a draft PR to start a task
  - /sp-close Aggregate PR statuses at Sprint end

👉 Next step: Run `/roadmap` to plan the project roadmap. It is recommended to provide the product document (PRD) and design assets to the Agent.
```

## Notes

- The Moonlight Tavern path is only asked for the first time `/project-init` is run; subsequent commands read it automatically from memory
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project
- Do not modify existing file contents (unless the user explicitly requests it)
- Task numbering format: T{sprint-number}.{task-number}, e.g. T1.1, T1.2, T2.1
- The owner value must match the name in repos.yml
- **Task status is automatically derived from the PR lifecycle**: after completing a task, open a PR with /ship; once the PR is merged, my-tasks / sp-close will automatically reflect the latest status — **no manual update to Moonlight Tavern's SPRINT.md is needed**
