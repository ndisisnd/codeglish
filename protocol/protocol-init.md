---
name: Codeglish Init Mode
description: The /codeglish --init setup wizard — scans the codebase, asks proficiency per language, optionally installs a PostToolUse hook, and writes codeglish-config.json. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# Init mode

Runs when Step 1 of SKILL.md detects `--init`. Replaces the main Steps 2–6 for this invocation only. Emit `Init X/5 — <title>` at the start of each step, unconditionally.

---

**Init 1/5 — Check for existing config**

Read `refs/codeglish-config.json`. If the file exists and is non-empty, show what was previously set up:
- Codebase path
- Detected languages and starting XP per language
- Whether the hook was enabled

Then ask:

> "Codeglish is already set up for this codebase. Overwrite the existing config?
> (1) Yes, overwrite  (2) No, keep existing"

If the user selects `No, keep existing` → stop. If the user selects `Yes, overwrite` or no config exists → continue.

Output: `overwrite` (boolean).

---

**Init 2/5 — Scan codebase for languages**

Run via Bash:
```bash
git ls-files 2>/dev/null || find . -type f -not -path './.git/*'
```

Extract all file extensions and classify each file into a language using `refs/codeglish-map.md`, applying its extension mapping, exclusion rules, noise threshold, and unmapped-extension rule (name any unrecognised extension and append it to the map). Deduplicate and sort by file count descending.

Present the detected languages to the user:

> "Found these languages in the codebase: [Language A] (N files), [Language B] (N files), ..."
> "Are there any you'd like to exclude? Enter numbers to exclude, or press Enter to keep all."

Ask via AskUserQuestion with the detected languages as options (multi-select: which to exclude). Accept the remaining set as `detected_languages`.

Output: `detected_languages` (list of language names).

---

**Init 3/5 — Ask proficiency per language**

For each language in `detected_languages`, ask via AskUserQuestion:

> "How familiar are you with [Language]?"
> (1) Never used it  (2) Can read it but rarely write it  (3) Know the basics  (4) Use it regularly  (5) Expert

Map each answer to its starting XP and level using the "Starting XP for --init" table in `refs/codeglish-levels.md`, then write each language record to `refs/codeglish-exp.json`: `{ "xp": <starting_xp>, "level": <starting_level> }`.

Output: `refs/codeglish-exp.json` updated with one record per detected language.

---

**Init 4/5 — Ask about hook setup**

Ask via AskUserQuestion:

> "Should Codeglish automatically run after every code change in this codebase?"
> (1) Yes — add a hook  (2) No — I'll run it manually

If the user selects `No` → skip to Init 5.

If the user selects `Yes`:
1. Read `.claude/settings.json` at the project root. Create it if it does not exist.
2. Merge in the following hook under the `hooks.PostToolUse` key:

```json
{
  "matcher": "Edit|Write",
  "hooks": [
    {
      "type": "command",
      "command": "git diff HEAD -- \"$CLAUDE_TOOL_INPUT_PATH\" 2>/dev/null | claude --print '/codeglish'"
    }
  ]
}
```

3. Write the merged config back to `.claude/settings.json`.

Output: `.claude/settings.json` updated (or unchanged if user declined).

---

**Init 5/5 — Write config and summarise**

Write `refs/codeglish-config.json`:

```json
{
  "codebase": "<absolute path of current working directory>",
  "languages": ["<language>", ...],
  "hook_enabled": <true|false>,
  "setup_at": "<ISO date string>"
}
```

Show a summary to the user:

> "Codeglish is set up.
> Languages tracked: [list]
> Hook: [enabled / disabled]
> Run /codeglish on any diff, code snippet, or plan to get a plain-English explanation."

Output: `refs/codeglish-config.json` written; summary shown inline.
