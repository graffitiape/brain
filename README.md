# brain

Standalone Claude Code and Codex configuration for the shared Obsidian Brain workflow.

## What's included

- **Claude Code** global instructions, settings, and lifecycle hooks
- **Codex** global `AGENTS.md`, hooks config, and lifecycle hooks
- Obsidian Brain vault auto-detection and local machine setup

The Obsidian vault notes are not stored in this repo. They remain in the user's vault and are synced separately.

## Setup

```bash
git clone https://github.com/graffitiape/brain.git ~/brain
cd ~/brain
./install.sh
```

The install script will:

- Symlink Claude Code and Codex config files to their expected home-directory paths
- Detect the local Obsidian vault
- Create or migrate the shared `Brain/` folder structure inside the vault
- Configure Claude Code local brain permissions
- Configure Codex hooks and writable Brain access

Machine-local files such as `settings.local.json`, `obsidian-brain-path`, and Codex `config.toml` stay outside this repo.
