#!/bin/bash
# Create a new project from template
# Usage: ./scripts/new-project.sh <name> <type> "<description>"
#   type: dev (harness-scaffold) | general (minimal)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_DIR="$ROOT_DIR/projects"
PROJECTS_MD="$ROOT_DIR/PROJECTS.md"
TEMPLATE_REPO="https://github.com/DongJuS/harness-scaffold.git"

NAME="$1"
TYPE="$2"
DESC="$3"

if [ -z "$NAME" ] || [ -z "$TYPE" ] || [ -z "$DESC" ]; then
  echo "Usage: $0 <name> <type> \"<description>\""
  echo "  type: dev | general"
  exit 1
fi

if [[ "$TYPE" != "dev" && "$TYPE" != "general" ]]; then
  echo "Error: type must be 'dev' or 'general'"
  exit 1
fi

TARGET="$PROJECTS_DIR/$NAME"

if [ -d "$TARGET" ]; then
  echo "Error: project '$NAME' already exists at $TARGET"
  exit 1
fi

echo "Creating project: $NAME ($TYPE)"

if [ "$TYPE" = "dev" ]; then
  echo "Cloning harness-scaffold template..."
  git clone "$TEMPLATE_REPO" "$TARGET"
  rm -rf "$TARGET/.git"
  cd "$TARGET"
  git init
  git add -A
  git commit -m "init: scaffold from harness-scaffold template"
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

  cd "$TARGET"
  git init
  git add -A
  git commit -m "init: scaffold from general template"
  echo "General project created with minimal structure."
fi

cd "$ROOT_DIR"

DATE=$(date +%Y-%m-%d)
TEMPLATE_NAME="harness-scaffold"
[ "$TYPE" = "general" ] && TEMPLATE_NAME="general"

sed -i '' "/_(none yet)_/d" "$PROJECTS_MD"
LINE="| $NAME | projects/$NAME | $TEMPLATE_NAME | $DATE | active | $DESC |"

if ! grep -q "| $NAME |" "$PROJECTS_MD"; then
  awk -v line="$LINE" '/^\|---/ { print; print line; next } { print }' "$PROJECTS_MD" > "$PROJECTS_MD.tmp"
  mv "$PROJECTS_MD.tmp" "$PROJECTS_MD"
fi

echo ""
echo "Done! Project registered in PROJECTS.md"
echo "  cd projects/$NAME"
