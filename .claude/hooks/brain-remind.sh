#!/bin/bash
# Lightweight reminder injected before each prompt so Claude doesn't forget the brain.

echo "OBSIDIAN BRAIN: If this session involves substantial work, read relevant project notes and write brain notes when done. Vault: $(head -1 ~/.claude/obsidian-brain-path 2>/dev/null)/Brain/"
exit 0
