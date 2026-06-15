---
name: Codeglish Reset Mode
description: The /codeglish --reset handler — routes bare --reset to a disambiguation hint, --reset override to clear the level override in codeglish-config.json, and --reset exp to wipe codeglish-exp.json after confirmation. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# Reset mode

Runs when Step 1 of SKILL.md detects any `--reset` variant. Replaces the main Steps 2–6 for this invocation only. Route to the matching branch below.

---

### `--reset` with no arg — disambiguation hint

Emit and stop:

> "Did you mean `--reset exp` to wipe all XP levels, or `--reset override` to clear the level override?"

No files are changed.

---

### `--reset override` — clear the level override

Read `refs/codeglish-config.json`. Check for `override_level`.

- If `override_level` is not present or is null → emit "No override is active. Nothing to clear." and stop.
- Otherwise → remove the `override_level` key and write the config back.

Emit:

> "Level override cleared. Codeglish will use your actual XP level again."

Stop.

Output: `refs/codeglish-config.json` updated (override_level removed).

---

### `--reset exp` — wipe XP

**Reset 1/3 — Read XP memory**

Read `refs/codeglish-exp.json`. Extract every language key that has `xp > 0`.

- If the file does not exist or no language has XP > 0 → emit "No XP data found. Nothing to reset." and stop.
- Otherwise → collect the language names as `languages_with_xp`.

Output: `languages_with_xp` (list of language names).

---

**Reset 2/3 — Confirm reset**

Emit:

> "XP detected for: [Language A] ([XP] XP, Level [N]), [Language B] ([XP] XP, Level [N]), ... Reset XP levels?"

Ask via AskUserQuestion:

> (1) Yes, reset all  (2) No, keep my progress

If the user selects `No` → emit "Reset cancelled." and stop.

Output: `confirmed` (boolean).

---

**Reset 3/3 — Wipe XP and terminate**

Write `{}` to `refs/codeglish-exp.json`.

Emit:

> "XP reset. All language levels cleared."

Stop.

Output: `refs/codeglish-exp.json` overwritten with empty object.
