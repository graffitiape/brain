#!/bin/bash
# Reads the Obsidian Brain index and injects it as context at session start.
# Claude receives this output as a system reminder so it always knows what's in the brain.

VAULT_PATH="$(head -1 ~/.claude/obsidian-brain-path 2>/dev/null)"
BRAIN_DIR="$VAULT_PATH/Brain"
INDEX="$BRAIN_DIR/_Index.md"

if [ ! -f "$INDEX" ]; then
  echo "Obsidian Brain index not found at: $INDEX"
  exit 0
fi

echo "=== OBSIDIAN BRAIN INDEX (auto-loaded at session start) ==="
cat "$INDEX"
echo ""
echo "--- Brain Usage ---"
echo "- Read project notes from: $BRAIN_DIR/Projects/ when working on a known project"
echo "- Read learnings from: $BRAIN_DIR/Learnings/ when relevant patterns exist"
echo "- After substantial work, CREATE or UPDATE brain notes (Sessions/, Learnings/, Projects/)"
echo "- Always update _Index.md when adding new notes"
echo "=== END BRAIN INDEX ==="
exit 0
