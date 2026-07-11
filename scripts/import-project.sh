#!/bin/bash
# Import an existing sibling repository into Ralph management
# Usage: ./scripts/import-project.sh <name> <template> "<description>" [relative-path]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$ROOT_DIR/.." && pwd)"
PROJECTS_MD="$ROOT_DIR/PROJECTS.md"
MARKER_FILE=".git/ralph-managed"

NAME="$1"
TEMPLATE="$2"
DESC="$3"
PROJECT_PATH="${4:-../$NAME}"
DATE=$(date +%Y-%m-%d)
TARGET="$ROOT_DIR/$PROJECT_PATH"

if [ -z "$NAME" ] || [ -z "$TEMPLATE" ] || [ -z "$DESC" ]; then
  echo "Usage: $0 <name> <template> \"<description>\" [relative-path]"
  echo "  default path: ../<name>"
  exit 1
fi

if [ "$NAME" = "ralph" ]; then
  echo "Error: cannot import the Ralph manager repository itself"
  exit 1
fi

if [ ! -d "$TARGET" ]; then
  echo "Error: directory does not exist at $PROJECT_PATH"
  exit 1
fi

TARGET_PARENT="$(cd "$TARGET/.." && pwd)"
if [ "$TARGET_PARENT" != "$WORKSPACE_DIR" ]; then
  echo "Error: imported projects must be direct siblings under the workspace root"
  exit 1
fi

if [ ! -d "$TARGET/.git" ]; then
  echo "Error: target is not a git repository at $PROJECT_PATH"
  exit 1
fi

if grep -q "| $NAME |" "$PROJECTS_MD"; then
  echo "Error: project '$NAME' already exists in PROJECTS.md"
  exit 1
fi

cat > "$TARGET/$MARKER_FILE" << EOF
manager=ralph
registry=PROJECTS.md
created=$DATE
path=$PROJECT_PATH
imported=true
EOF

sed -i '' "/_(none yet)_/d" "$PROJECTS_MD"
LINE="| $NAME | $PROJECT_PATH | $TEMPLATE | $DATE | active | — | $DESC |"
awk -v line="$LINE" '/^\|---/ { print; print line; next } { print }' "$PROJECTS_MD" > "$PROJECTS_MD.tmp"
mv "$PROJECTS_MD.tmp" "$PROJECTS_MD"

echo "Imported '$NAME' from $PROJECT_PATH"
echo "  The repository keeps its own git history and origin settings."
