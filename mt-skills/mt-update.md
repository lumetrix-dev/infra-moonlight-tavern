---
name: mt-update
description: "[Moonlight Tavern] Check for skill updates by comparing the local version against the remote version. [Work Repo side]"
---

> **Language:** Detect the language the user is writing in and respond entirely in that language. Default to English if unclear.

## Steps

### 1. Read the local version

```bash
cat ~/.claude/skills/.mt-version 2>/dev/null || echo "not installed"
```

### 2. Fetch the latest remote version

```bash
gh api repos/lumetrix-dev/infra-moonlight-tavern/contents/mt-skills/.mt-version --jq '.content' 2>/dev/null | base64 -d
```

### 3. Compare versions

- Local version < remote version → prompt to update
- Local version == remote version → already up to date
- Not installed locally → prompt to install first

### 4. Prompt and perform the update

If already up to date:

```
✅ Already on the latest version (2.0.0)
```

If a new version is available, prompt the user in a conversational tone:

```
🔍 Skill version check

Local version:  2.0.0
Remote version: 2.1.0

⚠️ A new version is available! Would you like me to update?
```

Once the user agrees, re-run the installer directly from GitHub (no local clone needed):

```bash
curl -fsSL https://raw.githubusercontent.com/lumetrix-dev/infra-moonlight-tavern/main/mt-skills/install.sh | bash
```

After completion, remind the user to restart Claude Code for the update to take effect.