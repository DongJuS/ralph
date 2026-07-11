#!/bin/bash
# Create a new project from template
# Usage: ./scripts/new-project.sh <name> <type> "<description>"
#   type: dev (harness-scaffold) | general (minimal)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT_DIR/.." && pwd)"
PROJECTS_MD="$ROOT_DIR/PROJECTS.md"
REMOTE_TEMPLATE_REPO="https://github.com/DongJuS/harness-scaffold.git"
LOCAL_TEMPLATE_REPO="$WORKSPACE_DIR/harness-scaffold"
MARKER_FILE=".git/ralph-managed"

NAME="$1"
TYPE="$2"
DESC="$3"
DATE=$(date +%Y-%m-%d)

if [ -z "$NAME" ] || [ -z "$TYPE" ] || [ -z "$DESC" ]; then
  echo "Usage: $0 <name> <type> \"<description>\""
  echo "  type: dev | general"
  exit 1
fi

if [[ "$TYPE" != "dev" && "$TYPE" != "general" ]]; then
  echo "Error: type must be 'dev' or 'general'"
  exit 1
fi

TARGET="$WORKSPACE_DIR/$NAME"

if [ -d "$TARGET" ]; then
  echo "Error: project '$NAME' already exists at $TARGET"
  exit 1
fi

echo "Creating project: $NAME ($TYPE)"

init_project_repo() {
  local commit_message="$1"
  cd "$TARGET"
  git init
  cat > "$MARKER_FILE" << EOF
manager=ralph
registry=PROJECTS.md
created=$DATE
path=../$NAME
EOF
  git add -A
  git commit -m "$commit_message"
}

apply_dev_project_overrides() {
  local project_claude_template="$TARGET/templates/PROJECT-CLAUDE.md"
  if [ -f "$project_claude_template" ]; then
    cp "$project_claude_template" "$TARGET/CLAUDE.md"
  fi
}

sync_local_template_worktree() {
  if [ "$TEMPLATE_SOURCE" = "$LOCAL_TEMPLATE_REPO" ]; then
    rsync -a --exclude '.git' "$LOCAL_TEMPLATE_REPO"/ "$TARGET"/
  fi
}

if [ "$TYPE" = "dev" ]; then
  TEMPLATE_SOURCE="$REMOTE_TEMPLATE_REPO"
  if [ -d "$LOCAL_TEMPLATE_REPO/.git" ]; then
    TEMPLATE_SOURCE="$LOCAL_TEMPLATE_REPO"
  fi

  echo "Cloning harness-scaffold template..."
  git clone "$TEMPLATE_SOURCE" "$TARGET"
  rm -rf "$TARGET/.git"
  sync_local_template_worktree
  apply_dev_project_overrides
  init_project_repo "init: scaffold from harness-scaffold template"
  echo "Dev project created with harness-scaffold structure."

elif [ "$TYPE" = "general" ]; then
  mkdir -p "$TARGET/docs/decisions" "$TARGET/docs/journals" "$TARGET/scripts"

  cat > "$TARGET/README.md" << EOF
# $NAME

$DESC

## Structure

- \`docs/\` — documentation, decisions, journals
- \`scripts/\` — automation

## Created

$(date +%Y-%m-%d) via Ralph project factory
EOF

  cat > "$TARGET/CLAUDE.md" << EOF
# CLAUDE.md — AI Agent Rules for $NAME

## Core Rules

### 1. 200-Line File Limit
Every file must stay under 200 lines.

### 2. Self-Contained Writing
Every document must be understandable with zero prior context.
No "as discussed", no bare links, no undefined acronyms.

### 3. Decision Logging
When making a non-trivial choice, create an ADR in docs/decisions/.
EOF

  cat > "$TARGET/docs/decisions/TEMPLATE.md" << 'EOF'
# ADR-XXX: [Title]

## Status
proposed | accepted | deprecated

## Background
[Full context — write as if reader has never seen this project]

## Options
1. **Option A** — pros / cons
2. **Option B** — pros / cons

## Decision
[Which option was chosen]

## Reasoning
[Why this option won]

## Consequences
[What this enables and what it costs]
EOF

  init_project_repo "init: scaffold from general template"
  echo "General project created with minimal structure."
fi

cd "$ROOT_DIR"

TEMPLATE_NAME="harness-scaffold"
[ "$TYPE" = "general" ] && TEMPLATE_NAME="general"

sed -i '' "/_(none yet)_/d" "$PROJECTS_MD"
LINE="| $NAME | ../$NAME | $TEMPLATE_NAME | $DATE | active | — | $DESC |"

if ! grep -q "| $NAME |" "$PROJECTS_MD"; then
  awk -v line="$LINE" '/^\|---/ { print; print line; next } { print }' "$PROJECTS_MD" > "$PROJECTS_MD.tmp"
  mv "$PROJECTS_MD.tmp" "$PROJECTS_MD"
fi

echo ""
echo "Done! Project registered in PROJECTS.md"
echo "  cd ../$NAME"
echo "  This project is an independent git repository. Configure its own origin before pushing."
