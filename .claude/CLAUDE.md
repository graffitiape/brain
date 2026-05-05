## Obsidian Brain - Persistent Mind Map Memory

You have a persistent brain stored as interconnected notes in an Obsidian vault. Use it to remember knowledge across sessions and build a connected mind map of everything you learn.

**Vault path:** Read from `~/.claude/obsidian-brain-path` (one line, the absolute path to the vault on this machine).
**Brain folder:** `Brain/` (inside the vault above)

### First-Run Setup (if brain is not configured on this machine)

If `~/.claude/obsidian-brain-path` does not exist or the path inside it is invalid:

1. **Find the Obsidian vault** by searching these locations in order:
   - macOS: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/` (iCloud Obsidian)
   - Linux/generic: `~/Documents/`, `~/Obsidian/`, `~/.obsidian/`
   - Look for a directory containing a `.obsidian/` subfolder
2. **Write the vault path** to `~/.claude/obsidian-brain-path` (just the path, one line, no trailing newline)
3. **Create the `Brain/` folder structure** if it doesn't exist inside the vault:
   - `Brain/Projects/Work/`, `Brain/Projects/Hobby/`
   - `Brain/Learnings/`, `Brain/Decisions/`, `Brain/Sessions/`, `Brain/Preferences/`
   - `Brain/_Index.md` (the central Map of Content hub)
4. **Create/update `~/.claude/settings.local.json`** to include write permissions for the brain folder:
   - `Write(<vault-path>/Brain/**)`
   - `Edit(<vault-path>/Brain/**)`
5. **Tell the user** what vault was detected and confirm it's correct.

### Reading the Brain (at the start of relevant work)

1. Read `~/.claude/obsidian-brain-path` to get the vault path.
2. Read `<vault>/Brain/_Index.md` to recall what you know.
3. If working on a known project, read its note from `<vault>/Brain/Projects/Work/` or `<vault>/Brain/Projects/Hobby/`.
4. If the task relates to an existing learning or decision, read those notes from `<vault>/Brain/Learnings/` or `<vault>/Brain/Decisions/`.
5. Check `<vault>/Brain/Preferences/coding-conventions.md` to respect observed coding style preferences.

### Writing to the Brain (after completing meaningful work)

**Write a note when:**
- You worked on a project substantially (create/update a Project note)
- You discovered a reusable pattern or solution (create a Learning note in `Learnings/`)
- A non-trivial technical decision was made (create a Decision note in `Decisions/`)
- A significant session was completed -- implemented a feature, fixed a complex bug, did major refactoring (create a Session note in `Sessions/`)
- You noticed a repeating user preference (update `Preferences/coding-conventions.md` or create a new Preference note)

**Do NOT write a note when:**
- The task was trivial (quick question, small config change, simple one-line fix)
- The information is already captured in an existing note
- The work was exploratory with no concrete outcome

### Note Format (follow exactly)

```
---
id: <Note Title>
aliases: []
tags: [brain, <CATEGORY_TAG>]
created: YYYY-MM-DD
updated: YYYY-MM-DD
project: <project-name-if-applicable>
---

DD/MM/YYYY HH:mm

Links: [[_Index]], [[related-note-1]], [[related-note-2]]
Tags: #BRAIN #<CATEGORY_TAG>

### Summary
<1-3 sentences describing what this note captures>

### Details
<The actual content -- architecture, patterns, solutions, rationale, etc.>

### Connections
- Related to [[note-name]] because <why>
- Builds on [[other-note]] because <why>

#### References
```

### Category Tags and Folders

| Tag | Folder | Use for |
|-----|--------|---------|
| `#PROJECT` + `#WORK` | `Projects/Work/` | Work project knowledge |
| `#PROJECT` + `#HOBBY` | `Projects/Hobby/` | Personal/hobby project knowledge |
| `#LEARNING` | `Learnings/` | Reusable technical patterns and solutions |
| `#DECISION` | `Decisions/` | Technical decision rationale and trade-offs |
| `#SESSION` | `Sessions/` | Summaries of significant work sessions |
| `#PREFERENCE` | `Preferences/` | User workflow and coding style patterns |

### Wiki Linking Rules (Critical for Graph View)

- **ALWAYS** link back to `[[_Index]]` from every note.
- Link to related notes using `[[note-filename-without-extension]]` (e.g., `[[vessel-iq-frontend]]`, `[[react-query-caching-patterns]]`).
- In the `### Connections` section, explain **WHY** notes are linked, not just that they are.
- After creating a new note, **update `Brain/_Index.md`** to include it in the appropriate section.
- Cross-link between categories when relevant (e.g., a Learning note should link to the Project where it was discovered, a Decision should link to the Project it affects).

### Naming Conventions

- **Project notes:** kebab-case matching the project directory name (e.g., `vessel-iq-frontend.md`)
- **Learning notes:** kebab-case descriptive (e.g., `react-query-caching-patterns.md`)
- **Decision notes:** kebab-case action-oriented (e.g., `chose-zustand-over-redux.md`)
- **Session notes:** `YYYY-MM-DD-project-brief-description.md` (e.g., `2026-04-08-vessel-iq-auth-refactor.md`)
- **Preference notes:** kebab-case topic-focused (e.g., `coding-conventions.md`)

### Maintenance Rules

- **Prefer updating** an existing note over creating a new one for the same topic.
- When updating, change the `updated` date in frontmatter and the date/time line.
- Keep only the **last 10-15 session summaries** linked from the MOC index. Older session notes stay in `Sessions/` but are removed from the index.
- Keep notes **concise but complete enough** to be useful months later.
- Write for **both audiences**: you (Claude, for future context) and the user (for readable knowledge).
