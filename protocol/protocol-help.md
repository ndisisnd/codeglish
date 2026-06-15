---
name: Codeglish Help Mode
description: The /codeglish --help triage wizard — asks questions to identify what the user is trying to do, then offers to run the appropriate mode. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# Help mode

Runs when Step 1 of SKILL.md detects `--help`. Replaces the main Steps 2–6 for this invocation only. No progress markers — this mode is a triage conversation, not a processing pipeline.

---

**Help 1/3 — Identify goal**

Ask via AskUserQuestion:

> "What are you trying to do?"
> - **Understand a diff, code snippet, plan, or spec** — paste technical content and get a plain-English explanation
> - **Understand what a specific file does** — give me a file path and I'll read and explain it
> - **Add plain-English comments to a file** — annotate a code file's functions and classes in place
> - **Map out the whole codebase** — scan every file and produce an architecture table
> - **Set up Codeglish for this project** — first-time wizard that detects languages and sets your starting level
> - **Change how deep my explanations go** — pin or reset the explanation depth
> - **Reset my XP or level** — wipe saved progress

Map the answer to a provisional `target_mode`:

| Answer | `target_mode` |
|--------|--------------|
| Understand a diff, code snippet, plan, or spec | `translate` |
| Understand what a specific file does | `file-translate` |
| Add plain-English comments to a file | `comments` |
| Map out the whole codebase | `architecture` |
| Set up Codeglish for this project | `init` |
| Change how deep my explanations go | `depth` |
| Reset my XP or level | `reset` |

Output: `target_mode`.

---

**Help 2/3 — Collect missing input**

Ask only what is needed to run the resolved mode. If the user already provided the needed input alongside their Help 1 answer, skip straight to Help 3.

Before asking for a file path in any mode below, check whether the conversation context contains an `ide_opened_file` tag (the file the user currently has open in their editor). If it does, offer it as a shortcut option in the AskUserQuestion:

> "Which file would you like to use?"
> - **Use `<ide_opened_file path>`** (currently open in your editor)
> - **Enter a different path**

If the user chooses "Enter a different path", accept a free-text response. If no `ide_opened_file` is present, ask for the path directly.

| `target_mode` | What to ask |
|--------------|-------------|
| `translate` | "Paste the diff, code, plan, or spec you'd like explained." (free-text via AskUserQuestion with an "Other" field) |
| `file-translate` | "Which file would you like explained?" — apply the IDE-file shortcut above |
| `comments` | "Which file would you like annotated?" — apply the IDE-file shortcut above |
| `architecture` | "Should I scan the whole project, or a specific subdirectory? (Leave blank for whole project.)" (free-text, optional) |
| `init` | No input needed — the wizard is self-contained. Skip to Help 3. |
| `depth` | Ask two things in one step via AskUserQuestion: (1) "Temporary or permanent change?" → **Temporary — just this session** / **Reset to automatic**; and (2) if temporary: "Which level? (1 = simplest, 12 = most technical, or type a level name like `Practiced`)". If reset: no further input. Map to either `--override <level>` or `--reset override`. |
| `reset` | Ask via AskUserQuestion: "What would you like to reset?" → **My XP for all languages** / **Only the depth override** / **Both**. Map to `--reset exp`, `--reset override`, or both in sequence. |

Output: `collected_input` — the file path, inline content, scope path, level, or reset target gathered from the user.

---

**Help 3/3 — Confirm and run**

Show the resolved command and offer to run it immediately.

Compose the full command string from `target_mode` and `collected_input`:

| `target_mode` | Command |
|--------------|---------|
| `translate` | `/codeglish` (with `collected_input` as inline body) |
| `file-translate` | `/codeglish <file_path>` |
| `comments` | `/codeglish --comments <file_path>` |
| `architecture` | `/codeglish --architecture <scope_path>` (omit scope if whole project) |
| `init` | `/codeglish --init` |
| `depth` (override) | `/codeglish --override <level>` |
| `depth` (reset) | `/codeglish --reset override` |
| `reset exp` | `/codeglish --reset exp` |
| `reset override` | `/codeglish --reset override` |
| `reset both` | Run `--reset exp` then `--reset override` in sequence |

Ask via AskUserQuestion:

> "Here's the command I'd run: `<command>`. Ready to go?"
> - **Yes, run it** — proceed immediately
> - **No, let me adjust** — go back to Help 1

If the user selects **Yes**: execute the resolved mode by entering Step 1 of SKILL.md with the composed command as input.
If the user selects **No**: return to Help 1/3 and start the triage again, discarding prior answers.
