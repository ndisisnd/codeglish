---
name: codeglish
description: Translates technical input — diffs, code, PRDs, markdown, plans, and files — into plain English for non-technical readers. Supports file translation (/codeglish [file]) and code annotation (--comments [file]). Scores complexity, breaks complex code into labeled parts, tracks XP per language, and adapts depth as users level up. Invoke with /codeglish or phrases like "explain this" or "translate this".
model: claude-sonnet-4-6
allowed_tools:
  - AskUserQuestion
  - Bash
  - Edit
  - Read
  - Write
---

## Usage

**Invoke**: `/codeglish <input>` — paste or attach a git diff, code snippet, PRD, markdown file, or proposed plan.
**File**: `/codeglish [file path]` — translate a file (markdown, doc, or code) to plain English with a summary. After translation, choose to show only, overwrite the original, or emit a `codeglish-filename.ext` copy.
**Comments**: `/codeglish --comments [file path]` — explain a code file in Codeglish format, then offer to insert single-line Codeglish comments above functions and classes.
**Setup**: `/codeglish --init` — run the one-time setup wizard for this codebase.
**Architecture**: `/codeglish --architecture [path]` — scan every code file in the codebase (or a subdirectory), read each one, and produce a `codeglish-architecture.md` table that lists every file with a plain-English description of what it does. `path` is optional; omit to scan from the project root.
**Override**: `/codeglish --override <level>` — force explanations at a specific level without changing your XP. Level can be a number (1–12) or a name (e.g. `Practiced`, `Expert`).
**Reset**: `/codeglish --reset exp` — wipe all saved XP levels. `/codeglish --reset override` — clear the active level override.

Also triggers without a slash command on:
- Natural-language: "explain this", "translate this", "what does this mean", "what changed"
- Natural-language (architecture): "map out this codebase", "list all files", "document the codebase", "what files are in this project", "give me an overview of the files", "show me the file structure with explanations", "generate an architecture doc", "what does each file do" — when detected, always confirm with the user before proceeding (see Step 1 architecture-NL detection below)
- Context: user pastes a git diff, code snippet, PRD, markdown file, or proposed plan alongside a request for a plain-English explanation

## Inputs

| Name | Format | Source |
|------|--------|--------|
| `--init` flag | literal string `--init` | user message; triggers setup wizard instead of translation |
| `--override <level>` | `--override` followed by a level number (1–12) or level name | user message; sets a temporary explanation depth override |
| `--reset exp` | literal string `--reset exp` | user message; wipes all XP instead of translating |
| `--reset override` | literal string `--reset override` | user message; clears the active override instead of translating |
| `--reset` (no arg) | literal string `--reset` with nothing following | user message; triggers disambiguation hint |
| `--architecture` flag | `--architecture` optionally followed by a directory path | user message; triggers architecture-scan mode on the codebase or a subdirectory |
| `--comments` flag | `--comments` followed by a file path | user message; triggers code-comment mode on the given file |
| `file_path` | path string pointing to a file on disk | user message; triggers file-translate mode when no inline code or diff is present |
| `input` | git diff, code snippet, PRD, markdown file, or proposed plan | inline in user message or file reference |
| `language` | detected automatically from syntax, file extension, or diff header | derived from `input` or `file_path` |

## Outputs

| Name | Format | Destination |
|------|--------|-------------|
| `explanation` | plain-English document; structured into labeled parts when complexity is Complex, Very Complex, or Intricate | shown inline |
| `xp_update` | JSON write | `refs/codeglish-exp.json` |
| `level_up_notification` | one-line message appended to explanation | shown inline; omitted if no level-up |
| `codeglish-config.json` | JSON config written during `--init` | `refs/codeglish-config.json` |
| `codeglish-[filename].[ext]` | translated copy of the source file in Codeglish style | written to same directory as source; only in file mode when user chooses new-file option |
| `commented_file` | original code file with single-line Codeglish comments inserted above functions and classes | written back to the source path; only in comments mode when user confirms |
| `codeglish-architecture.md` | markdown table listing every code file with its language and a plain-English description | written to project root; only in architecture mode when user chooses to save |

## Progress emission

Main mode: emit `Step X/6 — <title>` at the start of each step, unconditionally.
Init mode: emit `Init X/5 — <title>` at the start of each init step, unconditionally.
File-translate mode: emit `File X/6 — <title>` at the start of each step, unconditionally.
Comments mode: emit `Comment X/5 — <title>` at the start of each step, unconditionally.
Architecture mode: emit `Architecture X/5 — <title>` at the start of each step, unconditionally.
Override mode: no progress markers — the mode is a single write operation.

## Step-by-step protocol

Step 1 is the only step defined here — it detects the mode and delegates to the appropriate protocol file. All translation, XP, and write logic lives in `protocol/`.

**Step 1 — Detect mode**

Check the user message for mode flags in this order:

- If `--init` is present → run `protocol/protocol-init.md` instead of Steps 2–6.
- If `--architecture` is present → extract the optional directory path that follows it (or default to `.`), then run `protocol/protocol-architecture.md` instead of Steps 2–6.
- If no flag is present but the message contains natural-language architecture intent — phrases like "map out this codebase", "list all files", "document the codebase", "what files are in this project", "give me an overview of the files", "show me the file structure with explanations", "generate an architecture doc", or "what does each file do" → confirm first: ask "It sounds like you want a full-codebase architecture document that lists every file with a plain-English description. Should I run `/codeglish --architecture` now?" (yes/no via AskUserQuestion). If yes, proceed with `protocol/protocol-architecture.md`. If no, fall through to the standard translate path.
- If `--override` is present → run `protocol/protocol-override.md` instead of Steps 2–6.
- If any `--reset` variant is present (`--reset exp`, `--reset override`, or bare `--reset`) → run `protocol/protocol-reset.md` and stop.
- If `--comments` is present → extract the file path that follows it, then run the **Comments protocol** (Steps C1–C5) instead of Steps 2–6.
- If the input is a file path (and no inline code or diff is present) → run the **File-translate protocol** (Steps F1–F6) instead of Steps 2–6. A file path is recognised by a leading `/`, `./`, `~/`, or a bare string ending in a known extension (`.md`, `.ts`, `.tsx`, `.js`, `.py`, `.go`, `.rs`, `.swift`, `.kt`, `.java`, `.rb`, `.json`, `.yaml`, `.yml`, `.toml`, `.html`, `.css`, `.scss`, `.sh`, `.txt`).
- Otherwise → classify the input as one of: git diff, code snippet, PRD, markdown file, or proposed plan. Identify the primary programming language from syntax, file extension, or diff header. If the input contains no technical content — no code, no diff, no spec — emit this refusal and stop:
  > "Codeglish only works with technical input — diffs, code, specs, plans, or file paths. This doesn't look like one."

Output: `mode` (one of `translate` | `file-translate` | `comments` | `init` | `architecture` | `override` | `reset-override` | `reset-exp` | `reset-hint`), `input_type`, and `language` (when mode is `translate`, `file-translate`, or `comments`).

Steps 2–6 are handled by `protocol/protocol-translate.md`.

## Mode protocols

Step 1 above is the only logic in SKILL.md. All modes, including the default translate mode, run their steps from a protocol file:

- `protocol/protocol-translate.md` — default mode; scores complexity, explains, awards XP (6 steps)
- `protocol/protocol-init.md` — `--init` setup wizard (5 steps)
- `protocol/protocol-architecture.md` — `--architecture [path]`; scans all code files and generates `codeglish-architecture.md` (5 steps)
- `protocol/protocol-override.md` — `--override <level>` depth pin
- `protocol/protocol-reset.md` — `--reset`, `--reset exp`, and `--reset override` branches
- `protocol/protocol-file.md` — file path as primary input; reads, translates, and optionally writes output (6 steps)
- `protocol/protocol-comments.md` — `--comments [file path]`; explains a code file and optionally inserts single-line comments (5 steps)

## References

- `refs/codeglish-heuristic.md` — assigns a complexity tier (Trivial / Simple / Moderate / Involved / Complex / Very Complex / Intricate) at Step 2, and maps each tier to its output structure at Step 4; also holds the dimension-permutation exemplars (same tier via different dimension mixes) and the dominant-dimension → emphasis table that Step 4 rule 3 draws on
- `refs/codeglish-levels.md` — the XP economy: threshold formula, 12-level table, level→depth mapping, depth exemplars (one diff across several bands) used at Step 4 rule 2, per-run XP award table, and `--init` starting-XP seeds; consulted at Steps 3–5, Override mode, and Init 3
- `refs/codeglish-exp.json` — persistent XP store; one record per programming language; read at Step 3, written at Step 5
- `refs/codeglish-config.json` — codebase-level config written by `--init`; read at Init 1 to detect prior setup
- `refs/codeglish-map.md` — classifies scanned files into languages (extension mapping, exclusion rules, noise threshold); used at Init 2 when scanning the codebase
