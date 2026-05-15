#!/bin/bash
set -e

REPO="lumetrix-dev/lib-claude-command"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
COMMANDS_DIR="$HOME/.claude/commands"
FILES=(plan.md ship.md standup.md project-init.md)

# Detect local clone vs curl pipe
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)"
USE_LOCAL=false
[ -f "$SCRIPT_DIR/plan.md" ] && USE_LOCAL=true

echo "Installing Claude sprint workflow commands..."
mkdir -p "$COMMANDS_DIR"

for f in "${FILES[@]}"; do
  if $USE_LOCAL; then
    cp "$SCRIPT_DIR/$f" "$COMMANDS_DIR/$f"
  else
    curl -fsSL "$BASE_URL/$f" -o "$COMMANDS_DIR/$f"
  fi
  echo "  ✓ $f"
done

echo ""
echo "✅ Done. Commands available in any Claude Code session:"
echo "   /plan          规划下一个 Sprint"
echo "   /ship          完成任务后更新追踪"
echo "   /standup       生成项目状态快照"
echo "   /project-init  新项目初始化工作流"
