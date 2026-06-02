[Moonlight Tavern] Plan or update ROADMAP.md, brainstorming based on product documents and design assets. [Moonlight Tavern side]

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Prerequisites

- Requires repos.yml from Moonlight Tavern and the corresponding project's ROADMAP.md
- Can be run from either the work repo or the Moonlight Tavern directory

## Steps

### 0. Confirm Moonlight Tavern path

Read the local path of `infra-moonlight-tavern` from memory. If not recorded, ask the user and save to memory.

### 1. Identify the current project

Use git remote to get the current repository's `org/repo`, then find the matching name in repos.yml:

```bash
git remote get-url origin | sed 's/.*:\(.*\)\.git/\1/'
```

Match against the github field in repos.yml to obtain the project name `PROJECT_NAME`.

### 2. Collect existing materials

Read all source materials available for brainstorming:

**2.1 Existing ROADMAP.md**

```bash
cat {moonlight-tavern-path}/projects/{PROJECT_NAME}/ROADMAP.md
```

If it does not exist, this is a fresh planning session.

**2.2 Product documents (PRD)**

Search the work repo for PRD-related files:

```bash
# Find PRD files
find . -maxdepth 2 -iname "*prd*" -o -iname "*product*" -o -iname "*requirements*" -o -iname "*spec*" 2>/dev/null | head -10
```

If found, read each file's contents.

**2.3 Design assets / design documents**

```bash
find . -maxdepth 2 \( -iname "*design*" -o -iname "*ui*" -o -iname "*figma*" \) 2>/dev/null | head -10
```

If design documents (non-images) are found, read their contents.

**2.4 Current project structure**

Use a few commands to understand the project's focus:

```bash
ls src/ 2>/dev/null || ls app/ 2>/dev/null || ls lib/ 2>/dev/null || echo "No standard source directory found"
cat package.json 2>/dev/null | head -20 || cat pyproject.toml 2>/dev/null || cat Cargo.toml 2>/dev/null
```

**2.5 Git commit history (to understand completed features)**

```bash
git log --oneline -20 2>/dev/null
```

### 3. Brainstorm

Synthesize all of the above materials and brainstorm to produce the ROADMAP.md. Thinking framework:

1. **Product positioning** — What problem is this project actually solving?
2. **What has been done** — Summarize delivered features from git log and the existing ROADMAP.md
3. **What is missing** — Compare against PRD / design assets / product goals to identify gaps
4. **Priority ordering** — Sequence phases by user value + technical dependencies
5. **Phased output** — Use `- [ ]` for pending items in the current phase; keep later phases coarse-grained

### 4. Output ROADMAP.md

```markdown
# {project-name} — Roadmap

## Product Positioning
{one-sentence product positioning derived from brainstorming}

## Current Phase

### Phase {N} · {Phase Name} (In Progress)

- [ ] {Milestone 1: one-sentence description}
- [ ] {Milestone 2}

### Phase {N-1} · {Phase Name} (Completed)

- [x] {Completed Milestone}

## Upcoming Phases

### Phase {N+1} · {Phase Name} (To be planned)

- [ ] TBD

## Appendix

### References
- PRD: {filename}
- Design assets: {filename}
- Other: {filename}
```

### 5. Write to file

Write the generated ROADMAP.md to:

```bash
{moonlight-tavern-path}/projects/{PROJECT_NAME}/ROADMAP.md
```

### 6. Output summary

Display a change summary:
```
✅ {project-name} ROADMAP updated

Current phase: Phase {N} · {Phase Name}
Milestones: X pending · Y completed

👉 Next step: Run `/plan` to break down the ROADMAP into concrete Tasks for the current Sprint.
```

## Notes

- This command enhances the existing ROADMAP.md — do not delete existing content
- "Moonlight Tavern", "tavern", and "moonlight" all refer to the `infra-moonlight-tavern` project
