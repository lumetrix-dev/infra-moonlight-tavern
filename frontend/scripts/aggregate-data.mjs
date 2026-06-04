import { readFileSync, readdirSync, writeFileSync, existsSync, statSync } from 'fs'
import { join, dirname } from 'path'
import { fileURLToPath } from 'url'
import { execSync } from 'child_process'
import { load } from 'js-yaml'

const __dirname = dirname(fileURLToPath(import.meta.url))
const ROOT = join(__dirname, '..', '..')
const OUT_DIR = join(__dirname, '..')

function parseFrontmatter(raw) {
  const match = raw.match(/^---\n([\s\S]*?)\n---/)
  if (match) {
    const meta = load(match[1])
    const body = raw.slice(match[0].length).trim()
    return { meta, body }
  }
  try {
    const meta = load(raw)
    return { meta, body: '' }
  } catch {
    return { meta: {}, body: raw }
  }
}

// ── repos.yml ────────────────────────────────────────────────────
const reposPath = join(ROOT, 'repos.yml')
const repos = {}
if (existsSync(reposPath)) {
  const raw = readFileSync(reposPath, 'utf-8')
  const data = load(raw)
  if (data?.repos) {
    for (const r of data.repos) {
      repos[r.name] = { github: r.github }
      if (r.description) repos[r.name].description = r.description
    }
  }
}

// ── Projects (existing) ──────────────────────────────────────────
const projectsDir = join(ROOT, 'projects')
const projects = {}
const tasks = []

for (const projectName of readdirSync(projectsDir)) {
  const projectDir = join(projectsDir, projectName)
  if (!statSync(projectDir).isDirectory()) continue

  const repoData = repos[projectName] || {}
  projects[projectName] = { name: projectName, description: repoData.description || '', color: '#94a3b8' }

  // Task files (old format)
  const tasksDir = join(projectDir, 'tasks')
  if (!existsSync(tasksDir)) continue

  for (const taskFile of readdirSync(tasksDir)) {
    if (!taskFile.endsWith('.md') && !taskFile.endsWith('.yaml')) continue
    const raw = readFileSync(join(tasksDir, taskFile), 'utf-8')
    const { meta, body } = parseFrontmatter(raw)
    if (meta && meta.id) {
      tasks.push({ ...meta, body, _file: `projects/${projectName}/tasks/${taskFile}` })
    }
  }
}

// ── Sprints (old format, from sprints/ dir) ─────────────────────
const sprintsDir = join(ROOT, 'sprints')
const sprints = {}
if (existsSync(sprintsDir)) {
  for (const sprintFile of readdirSync(sprintsDir)) {
    if (!sprintFile.endsWith('.yaml')) continue
    const raw = readFileSync(join(sprintsDir, sprintFile), 'utf-8')
    const s = load(raw)
    if (s && s.id) {
      sprints[s.id] = s
    }
  }
}

// ── SPRINT.md parser (new format per project) ───────────────────
function parseSprintMd(raw) {
  const lines = raw.split('\n')
  const sprint = { name: '', epics: [] }
  let currentEpic = null
  let currentStory = null

  // Sprint title: # Sprint [<name>] — <start> ～ <end>
  // Supports: "Sprint 1 · name — date", "Sprint — date" (no name)
  // Note: .*? captures everything between "Sprint " and the " — date" pattern
  const headerMatch = raw.match(/^#{1,2}\s+Sprint\s+(.*?)\s*[—–-]\s*(\d{4}-\d{2}-\d{2})\s*[～~]\s*(\d{4}-\d{2}-\d{2})/m)
  if (headerMatch) {
    sprint.name = headerMatch[1].trim()
    sprint.start = headerMatch[2]
    sprint.end = headerMatch[3]
	} else {
		const simpleMatch = raw.match(/^#{1,2}\s+Sprint\s+(.+)/m)
		if (simpleMatch) sprint.name = simpleMatch[1].trim()
	}
  // Normalize: "2 · Some Title" → "S2 - Some Title"
  sprint.name = sprint.name.replace(/^(\d+)\s*[·•]\s*/, 'S$1 - ')

  for (const line of lines) {
    // Epic: ## E1 · Title (or ### E1 in archived sprints)
    const epicMatch = line.match(/^#{2,3}\s+(E\d+)\s*[·•]\s*(.+)/)
    if (epicMatch) {
      currentEpic = { id: epicMatch[1], title: epicMatch[2].trim(), goal: '', stories: [], tasks: [] }
      sprint.epics.push(currentEpic)
      currentStory = null
      continue
    }

    if (!currentEpic) continue

    // Epic goal: first blockquote after epic header, skip warning/bold lines
    const goalMatch = line.match(/^>\s+(.+)/)
    if (goalMatch && !currentEpic.goal && !goalMatch[1].startsWith('⚠️') && !goalMatch[1].startsWith('**')) {
      currentEpic.goal = goalMatch[1].trim()
      continue
    }

    // Story: ### S1.1 Title (M) or ### S1.1 Title（M）✅
    // Removed $ anchor — title may have trailing `branch: ...` or other inline info
    const storyMatch = line.match(/^#{3,4}\s+(S[\d.]+)\s+(.+?)\s*[（(](\w+)[）)]/)
    if (storyMatch) {
      currentStory = { id: storyMatch[1], title: storyMatch[2].trim(), size: storyMatch[3], tasks: [], status: 'todo' }
      currentEpic.stories.push(currentStory)
      continue
    }

    // Sub-task: `  - [x] T1.1 Title `owner: ui` `PR: #123``
    // Matches 0+ leading whitespace (markdown may not indent tasks under stories)
    const subtaskMatch = line.match(/^\s*-\s+\[([ x])\]\s+(T[\d.]+)\s+(.+?)(?:\s*`([^`]+)`(?:\s*`([^`]+)`)?)?\s*$/)
    if (subtaskMatch && currentStory) {
      const done = subtaskMatch[1] === 'x'
      const tid = subtaskMatch[2]
      const title = subtaskMatch[3].trim()
      let owner = '', pr = null, prStatus = null

      for (const tag of [subtaskMatch[4], subtaskMatch[5]].filter(Boolean)) {
        const o = tag.match(/^owner:\s*(.+)/)
        const p = tag.match(/^PR:\s*(.+)/)
        if (o) owner = o[1].trim()
        if (p) {
          const val = p[1].trim()
          if (val === '-' || val === '—') {
            pr = null
          } else if (val === 'draft') {
            pr = 'draft'
            prStatus = 'wip'
          } else {
            pr = val
          }
        }
      }

      const status = done ? 'done' : (prStatus || (pr ? 'check' : 'todo'))
      const task = { id: tid, title, owner, pr, status, _done: done }
      currentStory.tasks.push(task)
      currentEpic.tasks = currentEpic.tasks || []
      currentEpic.tasks.push(task)
      continue
    }

    // Parent task: `- [x] **T1** Title`
    const taskMatch = line.match(/^\s*-\s+\[([ x])\]\s+\*\*(T\d+)\*\*\s+(.+)/)
    if (taskMatch && currentStory) {
      // parent task is implicit, handled via sub-tasks
      continue
    }
  }

  return sprint
}

// ── GitHub PR status resolution ──────────────────────────────────
// Maps PR lifecycle to task status: todo ⚪ / wip 🟡 / review 🔵 / done ✅ / error 🟥
// Uses `gh` CLI — if unavailable, falls back to static SPRINT.md labels.
const PR_STATUS = { TODO: 'todo', WIP: 'wip', REVIEW: 'review', DONE: 'done', ERROR: 'error' }

const PR_LIFECYCLE = {
  mergedAt:  { label: 'done',  priority: 5 },
  isDraft:   { label: 'wip',   priority: 4 },
  stateOpen: { label: 'review', priority: 3 },
  stateClosed: { label: 'error', priority: 2 },
  fallback:  { label: 'todo',  priority: 1 },
}

function resolvePrStatus(pr) {
  if (!pr) return 'todo'
  if (pr.mergedAt) return 'done'     // Merged: highest priority
  if (pr.isDraft) return 'wip'       // Draft PR: in progress
  if (pr.state === 'OPEN') return 'review'  // Open + ready
  if (pr.state === 'CLOSED' || pr.state === 'MERGED') return 'error'  // Closed unmerged
  return 'todo'
}

function fetchLivePrStatuses(sprintData, repos) {
  try {
    execSync('gh --version', { encoding: 'utf-8', stdio: ['ignore', 'pipe', 'ignore'] })
  } catch {
    console.log('  ⚠ gh CLI not available, using static PR labels')
    return
  }

  // Collect all unique (owner, taskId) pairs grouped by repo
  const repoMap = {} // github_repo → [{taskId, story, epic, sprint}]
  for (const [projectName, sprint] of Object.entries(sprintData)) {
    for (const epic of sprint.epics) {
      for (const story of epic.stories) {
        for (const task of story.tasks) {
          const repo = repos[task.owner]?.github
          if (!repo) continue
          if (!repoMap[repo]) repoMap[repo] = []
          repoMap[repo].push({ taskId: task.id, task, story, epic, sprint })
        }
      }
    }
  }

  for (const [repo, entries] of Object.entries(repoMap)) {
    try {
      // Batch query: fetch all PRs (open + recently merged) for this repo
      const raw = execSync(
        `gh pr list --repo ${repo} --state all --limit 100 --json number,title,state,isDraft,mergedAt,url,createdAt`,
        { encoding: 'utf-8', stdio: ['ignore', 'pipe', 'ignore'], timeout: 15000 }
      )
      const prs = JSON.parse(raw)

      // Build taskId → PR map by matching [TXX.X] in PR title
      // Supports multiple task IDs per PR (e.g. "[T1.1][T1.2] description")
      for (const pr of prs) {
        const matches = [...pr.title.matchAll(/\[(T[\d.]+)\]/g)]
        if (!matches.length) continue

        for (const match of matches) {
          const taskId = match[1]

          // Find matching task entries
          for (const entry of entries) {
            if (entry.taskId !== taskId) continue

            // Skip tasks with no PR reference (PR: -). They have no PR yet.
            if (entry.task.pr == null) continue
            // For tasks with an explicit PR number, match that specific PR only.
            // The [#N] title match is a fallback; skip if task already has a
            // different PR number assigned (avoids cross-sprint false matches).
            const taskPrNum = (entry.task.pr || '').replace('#', '')
            if (taskPrNum && /^\d+$/.test(taskPrNum) && String(pr.number) !== taskPrNum) continue
            // For draft tasks, only match open PRs. Merged/closed PRs with
            // the same task ID belong to a previous sprint.
            if (entry.task.pr === 'draft' && pr.mergedAt) continue
            if (entry.task.pr === 'draft' && pr.state === 'CLOSED') continue

            const status = resolvePrStatus(pr)
            entry.task.pr = `#${pr.number}`
            entry.task.prUrl = pr.url
            entry.task.prTitle = pr.title
            // [x] checkbox takes priority: only downgrade 'done' if PR is
            // closed without merge (error 🟥) — draft/open PR doesn't undo [x].
            entry.task.status = (entry.task._done && status !== 'error') ? 'done' : status
          }
        }
      }

      console.log(`  ✓ ${repo}: ${prs.length} PRs scanned`)
    } catch (e) {
      const msg = e.message?.split('\n')[0] || e
      if (msg.includes('401') || msg.includes('403') || msg.includes('not found') || msg.includes('could not read')) {
        console.log(`  ⚠ ${repo}: auth/permission error — need GH_TOKEN with repo scope`)
      } else {
        console.log(`  ⚠ ${repo}: query failed (${msg}), using static data`)
      }
    }
  }
}

// ── Derive parent status from children ───────────────────────────
function deriveParentStatuses(sprintData) {
  for (const sprint of Object.values(sprintData)) {
    for (const epic of sprint.epics) {
      for (const story of epic.stories) {
        const allDone = story.tasks.length > 0 && story.tasks.every(t => t.status === 'done')
        const anyDone = story.tasks.some(t => t.status === 'done')
        const anyError = story.tasks.some(t => t.status === 'error')
        story.status = allDone ? 'done' : anyError ? 'error' : anyDone ? 'wip' : 'todo'
      }
    }
  }
}

// ── Parse SPRINT.md per project ─────────────────────────────────
const sprintData = {}
for (const projectName of Object.keys(projects)) {
  const sprintPath = join(projectsDir, projectName, 'SPRINT.md')
  if (existsSync(sprintPath)) {
    const raw = readFileSync(sprintPath, 'utf-8')
    sprintData[projectName] = parseSprintMd(raw)
  }
}

// ── Parse PROJECT.md for archived sprints ───────────────────────
const archiveData = {}
for (const projectName of Object.keys(projects)) {
  const projPath = join(projectsDir, projectName, 'PROJECT.md')
  if (!existsSync(projPath)) continue
  const raw = readFileSync(projPath, 'utf-8')
  // Split by sprint headers: # Sprint N · ...
  const sections = raw.split(/(?=^#{1,2}\s+Sprint\s+\d+)/m)
  for (const section of sections) {
    if (!/^#{1,2}\s+Sprint\s+\d+/.test(section)) continue
    const sprint = parseSprintMd(section)
    if (sprint.epics.length > 0) {
      archiveData[projectName] = archiveData[projectName] || []
      archiveData[projectName].push(sprint)
    }
  }
}

// ── Resolve real PR statuses via GitHub API ─────────────────────
console.log('🔍 Resolving PR statuses...')
fetchLivePrStatuses(sprintData, repos)
deriveParentStatuses(sprintData)
// Archived sprints are already frozen — just derive parent statuses
for (const [proj, sprints] of Object.entries(archiveData)) {
  for (const sprint of sprints) {
    const tmp = { _: sprint }
    deriveParentStatuses(tmp)
  }
}

// ── Convert Date objects ─────────────────────────────────────────
function convertDates(obj) {
  if (obj instanceof Date) {
    const y = obj.getUTCFullYear()
    const m = String(obj.getUTCMonth() + 1).padStart(2, '0')
    const d = String(obj.getUTCDate()).padStart(2, '0')
    return `${y}-${m}-${d}`
  }
  if (Array.isArray(obj)) return obj.map(convertDates)
  if (obj && typeof obj === 'object') {
    const next = {}
    for (const [k, v] of Object.entries(obj)) next[k] = convertDates(v)
    return next
  }
  return obj
}

// ── Output ───────────────────────────────────────────────────────
const output = convertDates({
  repos,
  projects,
  tasks,
  sprints,
  sprint_data: sprintData,
  archive_data: archiveData,
  _generated: new Date().toISOString(),
})

writeFileSync(join(OUT_DIR, 'data.json'), JSON.stringify(output, null, 2))
console.log(`✓ Generated data.json: ${Object.keys(projects).length} projects, ${tasks.length} tasks, ${Object.keys(sprints).length} sprints, ${Object.keys(sprintData).length} sprint_md`)
