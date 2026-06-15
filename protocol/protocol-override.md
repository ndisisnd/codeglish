---
name: Codeglish Override Mode
description: The /codeglish --override <level> handler — pins explanation depth to a chosen level (1–12 or a level name) by writing override_level to codeglish-config.json, without changing XP. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# Override mode

Runs when Step 1 of SKILL.md detects `--override`. Replaces the main Steps 2–6 for this invocation only. No progress markers — this is a single write operation.

Parse the level arg from the user message. Accept either a number (1–12) or a level name. Normalise a name to its corresponding number using the Name column of the level table in `refs/codeglish-levels.md`.

If no arg is given or the arg is not a recognised level, ask via AskUserQuestion:

> "Which level should Codeglish explain at?
> (1) Beginner (2) Novice (3) Apprentice (4) Familiar (5) Practiced (6) Skilled (7) Comfortable (8) Proficient (9) Advanced (10) Expert (11) Master (12) Virtuoso"

Once a valid level N is confirmed, read `refs/codeglish-config.json` (create it as `{}` if it does not exist). Set `override_level: N` in the JSON and write the file back.

Emit:

> "Override set to Level [N] — [Name]. Codeglish will explain at this level until you run `/codeglish --reset override`."

Stop.

Output: `refs/codeglish-config.json` updated with `override_level`; confirmation shown inline.
