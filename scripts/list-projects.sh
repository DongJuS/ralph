#!/bin/bash
# List all projects and their status
# Usage: ./scripts/list-projects.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECTS_DIR="$ROOT_DIR/projects"
PROJECTS_MD="$ROOT_DIR/PROJECTS.md"

echo "=== Ralph Projects ==="
echo ""

REGISTERED=0
ORPHANED=0
MISSING=0

# Parse PROJECTS.md for registered projects
while IFS='|' read -r _ name path template created status desc _; do
  name=$(echo "$name" | xargs)
  path=$(echo "$path" | xargs)
  status=$(echo "$status" | xargs)
  template=$(echo "$template" | xargs)
  desc=$(echo "$desc" | xargs)

  [ -z "$name" ] && continue
  [[ "$name" == "Name" ]] && continue
  [[ "$name" == "---"* ]] && continue
  [[ "$name" == "_(none"* ]] && continue

  REGISTERED=$((REGISTERED + 1))

  if [ -d "$ROOT_DIR/$path" ]; then
    echo "  [$status] $name ($template) — $desc"
  else
    echo "  [MISSING] $name ($template) — $desc  ⚠️ directory not found at $path"
    MISSING=$((MISSING + 1))
  fi
done < "$PROJECTS_MD"

# Check for orphaned directories
for dir in "$PROJECTS_DIR"/*/; do
  [ ! -d "$dir" ] && continue
  dirname=$(basename "$dir")
  if ! grep -q "| $dirname |" "$PROJECTS_MD" 2>/dev/null; then
    echo "  [ORPHAN] $dirname — exists in projects/ but not in PROJECTS.md"
    ORPHANED=$((ORPHANED + 1))
  fi
done

echo ""
echo "--- Summary ---"
echo "  Registered: $REGISTERED"
[ "$MISSING" -gt 0 ] && echo "  Missing:    $MISSING ⚠️"
[ "$ORPHANED" -gt 0 ] && echo "  Orphaned:   $ORPHANED ⚠️"
[ "$MISSING" -eq 0 ] && [ "$ORPHANED" -eq 0 ] && echo "  All clean ✓"
