#!/bin/bash
set -e

REPO="lumetrix-dev/infra-moonlight-tavern"
BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH/mt-skills"
COMMANDS_DIR="$HOME/.claude/skills"
SKILLS=(mt-plan mt-ship mt-project-init mt-my-tasks mt-sprint-report mt-roadmap mt-sp-close mt-update)

# Version check
LOCAL_VERSION=""
if [ -f "$COMMANDS_DIR/.mt-version" ]; then
  LOCAL_VERSION=$(cat "$COMMANDS_DIR/.mt-version")
fi

REMOTE_VERSION=$(curl -fsSL "$RAW_BASE/.mt-version" 2>/dev/null)
if [ -z "$REMOTE_VERSION" ]; then
  echo "❌ Could not reach GitHub. Check your network and try again."
  exit 1
fi

if [ -z "$LOCAL_VERSION" ]; then
  echo "Local:  (not installed)"
  echo "Remote: v$REMOTE_VERSION"
  echo ""
  read -rp "Proceed with fresh install? [Y/n] " confirm </dev/tty
  [[ "$confirm" =~ ^[Nn]$ ]] && { echo "Aborted."; exit 0; }
elif [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
  echo "Local:  v$LOCAL_VERSION"
  echo "Remote: v$REMOTE_VERSION"
  echo ""
  read -rp "Already up to date. Reinstall anyway? [y/N] " confirm </dev/tty
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }
else
  echo "Local:  v$LOCAL_VERSION"
  echo "Remote: v$REMOTE_VERSION"
  echo ""
  read -rp "Update available. Upgrade? [Y/n] " confirm </dev/tty
  [[ "$confirm" =~ ^[Nn]$ ]] && { echo "Aborted."; exit 0; }
fi

echo "Installing Moonlight Tavern skills..."
mkdir -p "$COMMANDS_DIR"

# Remove legacy flat files from ~/.claude/commands/ and ~/.claude/skills/
LEGACY_COMMANDS="$HOME/.claude/commands"
for s in "${SKILLS[@]}"; do
  [ -f "$LEGACY_COMMANDS/$s.md" ]       && rm "$LEGACY_COMMANDS/$s.md"       && echo "  🗑 removed legacy $LEGACY_COMMANDS/$s.md"
  [ -f "$COMMANDS_DIR/$s.md" ]          && rm "$COMMANDS_DIR/$s.md"           && echo "  🗑 removed legacy flat $COMMANDS_DIR/$s.md"
done

# Install each skill as {name}/SKILL.md
for s in "${SKILLS[@]}"; do
  mkdir -p "$COMMANDS_DIR/$s"
  curl -fsSL "$RAW_BASE/$s.md" -o "$COMMANDS_DIR/$s/SKILL.md"
  echo "  ✓ $s"
done

# Version file (flat, not a skill folder)
curl -fsSL "$RAW_BASE/.mt-version" -o "$COMMANDS_DIR/.mt-version"

echo ""
echo "✅ Done. Skills available in any Claude Code session:"
echo ""
echo "  Moonlight Tavern side:"
echo "    /mt-project-init  Initialize a new project"
echo "    /mt-plan          Plan the next Sprint"
echo "    /mt-roadmap       Plan or update ROADMAP.md"
echo "    /mt-sp-close      Aggregate PR statuses and archive at Sprint end"
echo ""
echo "  Work Repo side:"
echo "    /mt-my-tasks      View incomplete tasks + real-time PR status"
echo "    /mt-sprint-report Generate Sprint progress report"
echo "    /mt-ship          Create aggregated draft PR (title starts with [TXX.X])"
echo "    /mt-update        Check for command updates"
echo ""
echo "  Restart Claude Code to activate the commands."
