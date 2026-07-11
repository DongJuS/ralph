#!/bin/bash
FILES=$(find /Users/ddj/Documents/00_code/05_Project -name ralph.sh)
for f in $FILES; do
  echo "Updating $f..."
  # Add ollama to validation
  sed -i '' 's/&& "$TOOL" != "gemini"/ \&\& "$TOOL" != "gemini" \&\& "$TOOL" != "ollama"/g' "$f"
  sed -i '' "s/or 'gemini'./or 'gemini', or 'ollama'./g" "$f"
  
  # Add ollama execution logic if not already present
  if ! grep -q "ollama" "$f"; then
    # Use a more robust way to insert the elif block before the final else
    # Finding the line with '    OUTPUT=$(claude' and inserting before it or something similar
    sed -i '' '/  else/i\
  elif [[ "$TOOL" == "ollama" ]]; then\
    echo "Running with Ollama (qwen2.5:14b)..."\
    OUTPUT=$(ollama run qwen2.5:14b "$(cat "$SCRIPT_DIR/CLAUDE.md")" 2>&1) || true\
    printf "%s\\n" "$OUTPUT"
' "$f"
  fi
done
echo "All ralph.sh files updated."
