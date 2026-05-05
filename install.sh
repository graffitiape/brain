#!/bin/bash
set -e

BRAIN_REPO="$(cd "$(dirname "$0")" && pwd)"
BRAIN_FOLDER_NAME="Brain"
OLD_BRAIN_FOLDER_NAME="Claude Brain"
INSTALL_TARGETS=("$@")

if [ "$#" -eq 0 ]; then
  INSTALL_TARGETS=("all")
fi

print_usage() {
  cat << EOF
Usage: ./install.sh [target ...]

Targets:
  all              Install every supported integration (default)
  claude           Install Claude Code Brain integration
  codex            Install Codex Brain integration
  cursor           Install Cursor Brain rule assets
  github-copilot   Install GitHub Copilot / VS Code Brain instructions
EOF
}

for target in "${INSTALL_TARGETS[@]}"; do
  case "$target" in
    -h|--help|help)
      print_usage
      exit 0
      ;;
    all|claude|codex|cursor|github-copilot)
      ;;
    copilot)
      echo "Error: use the exact target 'github-copilot' for GitHub Copilot / VS Code."
      exit 1
      ;;
    *)
      echo "Error: unknown install target '$target'."
      print_usage
      exit 1
      ;;
  esac
done

should_install() {
  local wanted="$1"
  local target

  for target in "${INSTALL_TARGETS[@]}"; do
    if [ "$target" = "all" ] || [ "$target" = "$wanted" ]; then
      return 0
    fi
  done

  return 1
}

link_to() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    echo "Backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  echo "Linked $dst -> $src"
}

link() {
  local rel="$1"
  link_to "$BRAIN_REPO/$rel" "$HOME/$rel"
}

ensure_toml_top_level_key() {
  local file="$1"
  local key="$2"
  local value="$3"

  if grep -q "^$key *= *" "$file"; then
    return
  fi

  local tmp
  tmp="$(mktemp)"
  awk -v line="$key = $value" '
    !inserted && /^\[/ { print line; inserted=1 }
    { print }
    END { if (!inserted) print line }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

replace_literal_in_file() {
  local file="$1"
  local old="$2"
  local new="$3"

  [ -f "$file" ] || return 0
  grep -Fq "$old" "$file" || return 0

  local tmp
  tmp="$(mktemp)"
  awk -v old="$old" -v new="$new" '
    {
      while ((idx = index($0, old)) > 0) {
        $0 = substr($0, 1, idx - 1) new substr($0, idx + length(old))
      }
      print
    }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

ensure_brain_folder() {
  local vault="$1"
  local brain="$vault/$BRAIN_FOLDER_NAME"
  local old_brain="$vault/$OLD_BRAIN_FOLDER_NAME"

  if [ ! -d "$brain" ] && [ -d "$old_brain" ]; then
    mv "$old_brain" "$brain"
    echo "Renamed $OLD_BRAIN_FOLDER_NAME -> $BRAIN_FOLDER_NAME"
  fi

  mkdir -p "$brain/Projects/Work" "$brain/Projects/Hobby" "$brain/Projects/Side-Projects" \
           "$brain/Learnings" "$brain/Decisions" \
           "$brain/Sessions" "$brain/Preferences"
}

ensure_claude_brain_permissions() {
  local file="$1"
  local brain="$2"

  if ! command -v python3 >/dev/null 2>&1; then
    echo "Note: add Read/Write/Edit($brain/**) permissions to $file"
    return 0
  fi

  python3 - "$file" "$brain" << 'PY'
import json
import sys
from pathlib import Path

path = Path(sys.argv[1])
brain = sys.argv[2]

try:
    data = json.loads(path.read_text())
except Exception:
    print(f"Note: could not update {path}; add Brain permissions manually")
    raise SystemExit(0)

permissions = data.setdefault("permissions", {})
allow = permissions.setdefault("allow", [])

for entry in (
    f"Read({brain}/**)",
    f"Write({brain}/**)",
    f"Edit({brain}/**)",
):
    if entry not in allow:
        allow.append(entry)

path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

detect_obsidian_vault() {
  local vault="$1"

  if [ -n "$vault" ] && [ -d "$vault" ]; then
    echo "$vault"
    return
  fi

  vault=""

  if [[ "$(uname)" == "Darwin" ]]; then
    local icloud_obsidian="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
    if [ -d "$icloud_obsidian" ]; then
      vault=$(find "$icloud_obsidian" -maxdepth 2 -name ".obsidian" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
    fi
  fi

  if [ -z "$vault" ]; then
    local dir
    for dir in "$HOME/Documents" "$HOME/Obsidian" "$HOME"; do
      if [ -d "$dir" ]; then
        vault=$(find "$dir" -maxdepth 3 -name ".obsidian" -type d 2>/dev/null | head -1 | xargs dirname 2>/dev/null)
        [ -n "$vault" ] && break
      fi
    done
  fi

  echo "$vault"
}

if should_install claude; then
  # Claude Code
  link .claude/CLAUDE.md
  link .claude/settings.json
  link .claude/hooks

  CLAUDE_OBSIDIAN_VAULT=""
  if [ -f "$HOME/.claude/obsidian-brain-path" ]; then
    CLAUDE_OBSIDIAN_VAULT="$(cat "$HOME/.claude/obsidian-brain-path")"
  fi

  CLAUDE_OBSIDIAN_VAULT="$(detect_obsidian_vault "$CLAUDE_OBSIDIAN_VAULT")"

  if [ -n "$CLAUDE_OBSIDIAN_VAULT" ]; then
    echo "$CLAUDE_OBSIDIAN_VAULT" > "$HOME/.claude/obsidian-brain-path"
    echo "Configured Claude Code Obsidian brain path: $CLAUDE_OBSIDIAN_VAULT"

    ensure_brain_folder "$CLAUDE_OBSIDIAN_VAULT"
    BRAIN="$CLAUDE_OBSIDIAN_VAULT/$BRAIN_FOLDER_NAME"

    LOCAL_SETTINGS="$HOME/.claude/settings.local.json"
    if [ ! -f "$LOCAL_SETTINGS" ]; then
      cat > "$LOCAL_SETTINGS" << EOJSON
{
  "permissions": {
    "allow": [
      "Read($BRAIN/**)",
      "Write($BRAIN/**)",
      "Edit($BRAIN/**)"
    ]
  }
}
EOJSON
      echo "Created settings.local.json with brain permissions"
    else
      replace_literal_in_file "$LOCAL_SETTINGS" "$CLAUDE_OBSIDIAN_VAULT/$OLD_BRAIN_FOLDER_NAME" "$BRAIN"
      ensure_claude_brain_permissions "$LOCAL_SETTINGS" "$BRAIN"
      echo "Updated settings.local.json brain path if needed"
    fi
  else
    echo "Warning: No Obsidian vault found. Brain will auto-detect on first session."
  fi
fi

if should_install codex; then
  # Codex
  link .codex/AGENTS.md
  link .codex/hooks.json
  link .codex/hooks/obsidian_session_start.sh
  link .codex/hooks/obsidian_stop.sh

  mkdir -p "$HOME/.codex"
  CODEX_OBSIDIAN_VAULT=""

  if [ -f "$HOME/.codex/obsidian-brain-path" ]; then
    CODEX_OBSIDIAN_VAULT="$(cat "$HOME/.codex/obsidian-brain-path")"
  elif [ -f "$HOME/.claude/obsidian-brain-path" ]; then
    CODEX_OBSIDIAN_VAULT="$(cat "$HOME/.claude/obsidian-brain-path")"
  fi

  CODEX_OBSIDIAN_VAULT="$(detect_obsidian_vault "$CODEX_OBSIDIAN_VAULT")"

  if [ -n "$CODEX_OBSIDIAN_VAULT" ]; then
    echo "$CODEX_OBSIDIAN_VAULT" > "$HOME/.codex/obsidian-brain-path"
    echo "Configured Codex Obsidian brain path: $CODEX_OBSIDIAN_VAULT"

    ensure_brain_folder "$CODEX_OBSIDIAN_VAULT"
    CODEX_BRAIN="$CODEX_OBSIDIAN_VAULT/$BRAIN_FOLDER_NAME"
    OLD_CODEX_BRAIN="$CODEX_OBSIDIAN_VAULT/$OLD_BRAIN_FOLDER_NAME"

    CODEX_CONFIG="$HOME/.codex/config.toml"
    touch "$CODEX_CONFIG"
    ensure_toml_top_level_key "$CODEX_CONFIG" "commit_attribution" '""'
    replace_literal_in_file "$CODEX_CONFIG" "$OLD_CODEX_BRAIN" "$CODEX_BRAIN"

    if command -v codex >/dev/null 2>&1; then
      codex features enable codex_hooks >/dev/null 2>&1 || echo "Note: could not enable Codex hooks automatically"
    elif ! grep -q "^codex_hooks *= *true" "$CODEX_CONFIG"; then
      if grep -q "^\[features\]" "$CODEX_CONFIG"; then
        echo "Note: add 'codex_hooks = true' under [features] in $CODEX_CONFIG"
      else
        cat >> "$CODEX_CONFIG" << EOTOML

[features]
codex_hooks = true
EOTOML
      fi
    fi

    if ! grep -Fq "$CODEX_BRAIN" "$CODEX_CONFIG"; then
      if grep -q "^\[sandbox_workspace_write\]" "$CODEX_CONFIG"; then
        echo "Note: add '$CODEX_BRAIN' to sandbox_workspace_write.writable_roots in $CODEX_CONFIG"
      else
        cat >> "$CODEX_CONFIG" << EOTOML

[sandbox_workspace_write]
writable_roots = ["$CODEX_BRAIN"]
EOTOML
      fi
    fi
  else
    echo "Warning: No Obsidian vault found. Codex Brain will auto-detect using AGENTS.md fallback instructions."
  fi
fi

if should_install cursor; then
  # Cursor
  link_to "$BRAIN_REPO/.cursor/brain-user-rules.txt" "$HOME/.cursor/brain-user-rules.txt"
  link_to "$BRAIN_REPO/.cursor/rules/obsidian-brain.mdc" "$HOME/.cursor/brain-project-rules/obsidian-brain.mdc"

  CURSOR_OBSIDIAN_VAULT=""
  if [ -f "$HOME/.cursor/obsidian-brain-path" ]; then
    CURSOR_OBSIDIAN_VAULT="$(cat "$HOME/.cursor/obsidian-brain-path")"
  elif [ -f "$HOME/.codex/obsidian-brain-path" ]; then
    CURSOR_OBSIDIAN_VAULT="$(cat "$HOME/.codex/obsidian-brain-path")"
  elif [ -f "$HOME/.claude/obsidian-brain-path" ]; then
    CURSOR_OBSIDIAN_VAULT="$(cat "$HOME/.claude/obsidian-brain-path")"
  fi

  CURSOR_OBSIDIAN_VAULT="$(detect_obsidian_vault "$CURSOR_OBSIDIAN_VAULT")"

  if [ -n "$CURSOR_OBSIDIAN_VAULT" ]; then
    echo "$CURSOR_OBSIDIAN_VAULT" > "$HOME/.cursor/obsidian-brain-path"
    echo "Configured Cursor Obsidian brain path: $CURSOR_OBSIDIAN_VAULT"

    ensure_brain_folder "$CURSOR_OBSIDIAN_VAULT"
    echo "Cursor user rule snippet: $HOME/.cursor/brain-user-rules.txt"
    echo "Cursor project rule template: $HOME/.cursor/brain-project-rules/obsidian-brain.mdc"
    echo "Note: Cursor global User Rules are configured in Cursor Settings > Rules; paste the snippet there for all-project support."
  else
    echo "Warning: No Obsidian vault found. Cursor Brain rules will use fallback path instructions."
  fi
fi

if should_install github-copilot; then
  # GitHub Copilot
  link .copilot/instructions/obsidian-brain.instructions.md

  COPILOT_OBSIDIAN_VAULT=""
  if [ -f "$HOME/.copilot/obsidian-brain-path" ]; then
    COPILOT_OBSIDIAN_VAULT="$(cat "$HOME/.copilot/obsidian-brain-path")"
  elif [ -f "$HOME/.codex/obsidian-brain-path" ]; then
    COPILOT_OBSIDIAN_VAULT="$(cat "$HOME/.codex/obsidian-brain-path")"
  elif [ -f "$HOME/.claude/obsidian-brain-path" ]; then
    COPILOT_OBSIDIAN_VAULT="$(cat "$HOME/.claude/obsidian-brain-path")"
  fi

  COPILOT_OBSIDIAN_VAULT="$(detect_obsidian_vault "$COPILOT_OBSIDIAN_VAULT")"

  if [ -n "$COPILOT_OBSIDIAN_VAULT" ]; then
    echo "$COPILOT_OBSIDIAN_VAULT" > "$HOME/.copilot/obsidian-brain-path"
    echo "Configured GitHub Copilot Obsidian brain path: $COPILOT_OBSIDIAN_VAULT"

    ensure_brain_folder "$COPILOT_OBSIDIAN_VAULT"
  else
    echo "Warning: No Obsidian vault found. Copilot Brain instructions will use fallback path instructions."
  fi
fi
