#!/bin/bash
set -e

REPO="523753042/lib-claude-command"
BRANCH="main"
BASE_URL="https://raw.githubusercontent.com/$REPO/$BRANCH"
COMMANDS_DIR="$HOME/.claude/commands"
FILES=(plan.md ship.md standup.md project-init.md my-tasks.md new-task.md sprint-report.md update-task.md)

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
echo ""
echo "  Sprint 工作流（Group 1）："
echo "    /project-init  新项目初始化工作流"
echo "    /plan          规划下一个 Sprint（自动创建看板任务）"
echo "    /ship          完成任务后更新追踪（自动同步看板）"
echo "    /standup       生成项目状态快照"
echo ""
echo "  看板任务管理（Group 2）："
echo "    /my-tasks      查看当前用户未完成任务"
echo "    /new-task      创建新看板任务"
echo "    /update-task   更新看板任务状态"
echo "    /sprint-report 生成 Sprint 进度报告"
echo ""
echo "  Group 1 命令在执行时会自动同步到看板（需要先配置看板路径）。"
