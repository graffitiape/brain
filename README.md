# brain 🧠

Standalone AI-tool configuration for the shared Obsidian Brain workflow.

The Obsidian vault notes are not stored in this repo. They remain in the user's vault and are synced separately.

## Install

Clone the repo:

```bash
git clone https://github.com/graffitiape/brain.git ~/brain
cd ~/brain
```

Install only the tool you use:

```bash
./install.sh claude
./install.sh codex
./install.sh cursor
./install.sh github-copilot
```

Install several tools at once:

```bash
./install.sh claude codex cursor
```

Install every supported integration:

```bash
./install.sh
# same as:
./install.sh all
```

The installer detects the local Obsidian vault, creates or migrates the shared `Brain/` folder structure, and writes tool-specific local path files such as `obsidian-brain-path`.

## Claude Code

Use this if you work in Claude Code.

```bash
./install.sh claude
```

Installs:

- `~/.claude/CLAUDE.md`
- `~/.claude/settings.json`
- `~/.claude/hooks`
- `~/.claude/obsidian-brain-path`
- Brain read/write permissions in `~/.claude/settings.local.json`

Claude Code gets startup and reminder hooks so it can read the Brain index and update notes after meaningful work.

## Codex

Use this if you work in Codex.

```bash
./install.sh codex
```

Installs:

- `~/.codex/AGENTS.md`
- `~/.codex/hooks.json`
- `~/.codex/hooks/obsidian_session_start.sh`
- `~/.codex/hooks/obsidian_stop.sh`
- `~/.codex/obsidian-brain-path`

The installer also updates `~/.codex/config.toml` where possible for hooks, commit attribution, and writable Brain access.

## Cursor

Use this if you work in Cursor.

```bash
./install.sh cursor
```

Installs:

- `~/.cursor/obsidian-brain-path`
- `~/.cursor/brain-user-rules.txt`
- `~/.cursor/brain-project-rules/obsidian-brain.mdc`

Cursor supports project rules in `.cursor/rules` and plain-text global User Rules in Cursor Settings. For all-project support, paste the contents of `~/.cursor/brain-user-rules.txt` into Cursor Settings > Rules > User Rules. For a specific repo, copy or symlink `~/.cursor/brain-project-rules/obsidian-brain.mdc` into that repo's `.cursor/rules/` folder.

## GitHub Copilot

Use this if you work with GitHub Copilot in VS Code.

```bash
./install.sh github-copilot
```

Installs:

- `~/.copilot/instructions/obsidian-brain.instructions.md`
- `~/.copilot/obsidian-brain-path`

VS Code Copilot reads user instruction files from `~/.copilot/instructions`, so this gives GitHub Copilot the same Brain rules as the other supported coding tools.

## Machine-Local Files

Machine-local files stay outside git:

- `~/.claude/obsidian-brain-path`
- `~/.claude/settings.local.json`
- `~/.codex/obsidian-brain-path`
- `~/.codex/config.toml`
- `~/.cursor/obsidian-brain-path`
- `~/.copilot/obsidian-brain-path`
