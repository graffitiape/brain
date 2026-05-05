#!/bin/zsh
set -u

vault=""

if [[ -f "${HOME}/.codex/obsidian-brain-path" ]]; then
  vault="$(<"${HOME}/.codex/obsidian-brain-path")"
fi

if [[ -z "$vault" && -f "${HOME}/.claude/obsidian-brain-path" ]]; then
  vault="$(<"${HOME}/.claude/obsidian-brain-path")"
fi

index_file="${vault}/Brain/_Index.md"

if [[ -z "$vault" || ! -f "$index_file" ]]; then
  print "=== OBSIDIAN BRAIN NOT CONFIGURED ==="
  print "Expected a vault path in ~/.codex/obsidian-brain-path or ~/.claude/obsidian-brain-path."
  print "Find the Obsidian vault, then store its absolute path in ~/.codex/obsidian-brain-path."
  exit 0
fi

cache_file="${HOME}/.codex/.obsidian_brain_index_last_loaded"
dedupe_seconds=60
now="$(date +%s)"
index_mtime="$(stat -f %m "$index_file" 2>/dev/null || stat -c %Y "$index_file" 2>/dev/null || print unknown)"
session_key="${PWD}|${index_file}|${index_mtime}"
last_ts=""
last_key=""

if [[ -f "$cache_file" ]]; then
  IFS=$'\t' read -r last_ts last_key < "$cache_file"
fi

if [[ "$last_ts" =~ '^[0-9]+$' && "$last_key" == "$session_key" ]] && (( now - last_ts < dedupe_seconds )); then
  print "=== OBSIDIAN BRAIN INDEX ALREADY LOADED ==="
  print "Skipping duplicate index injection within ${dedupe_seconds}s."
  print "Use the visible _Index.md as the brain map, then load only task-relevant notes."
  exit 0
fi

if mkdir -p "${cache_file:h}" 2>/dev/null && [[ -w "${cache_file:h}" ]]; then
  printf '%s\t%s\n' "$now" "$session_key" >! "$cache_file"
fi

print "=== OBSIDIAN BRAIN INDEX (MAP ONLY) ==="
cat "$index_file"
print ""
print "=== OBSIDIAN BRAIN USAGE ==="
print "Shared brain folder: ${vault}/Brain"
print "Before work: use _Index.md to identify relevant notes; load only the project, preference, learning, or decision notes needed for the current task."
print "Do not read whole vault folders or old session notes by default."
print "After meaningful work: update the relevant notes and _Index.md before the final answer."
