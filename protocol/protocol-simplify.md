---
name: Codeglish Simplify Mode
description: Re-explains the most recent Codeglish explanation at a reduced level when the user signals they didn't understand. Drops effective_level by 2 (minimum 1), re-runs the explanation, and skips XP update. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# Simplify mode

Runs when Step 1 of SKILL.md detects simplification intent in the user's message and no new technical input is present. Replaces the main Steps 2–6 for this invocation only. Emit `Simplify X/3 — <title>` at the start of each step, unconditionally.

---

**Simplify 1/3 — Recover input and current level**

Look in the conversation context for the most recent Codeglish explanation. Extract:
- `prior_input` — the original technical content that was explained (the diff, code snippet, PRD, file contents, or plan)
- `prior_language` — the language detected during that run
- `prior_effective_level` — the effective level used in that run; read from the XP summary line at the bottom of the explanation (e.g. `Level 6 — Practiced`)
- `prior_complexity_tier` — the complexity tier scored during that run; re-score using `refs/codeglish-heuristic.md` if not visible

If no prior Codeglish explanation is found in the conversation context, emit:
> "I don't have a recent explanation to simplify. Paste the diff, code, or plan you'd like me to explain, and I'll start fresh."
and stop.

Compute `simplified_level`:
- `simplified_level = max(1, prior_effective_level - 2)`

Load `simplified_level_name` from the level table in `refs/codeglish-levels.md`.

Output: `prior_input`, `prior_language`, `prior_complexity_tier`, `prior_effective_level`, `simplified_level`, `simplified_level_name`.

---

**Simplify 2/3 — Re-explain at reduced level**

Open with:
> "Let me try that again at a simpler level."

Re-translate `prior_input` following all four rules from Step 4 of `protocol/protocol-translate.md`, but substituting `simplified_level` for `effective_level`. Apply the same structure governed by `prior_complexity_tier` and the "Output structure by tier" table in `refs/codeglish-heuristic.md`.

Close with the re-explanation summary line instead of the standard XP line:
- `(Re-explained at Level simplified_level — simplified_level_name | XP unchanged)`

If `simplified_level == 1`, append:
> "This is the simplest level available. If it's still unclear, try asking about one specific part."

Do NOT write to `refs/codeglish-exp.json` — XP is never updated in simplify mode.

Output: `re_explanation` (full text, shown inline).

---

**Simplify 3/3 — Offer to go further**

If `simplified_level > 1`, ask via AskUserQuestion:

> "Does that make more sense?"
> - **Yes, thanks** — done
> - **Still too complex — simplify more** — drop another 2 levels and re-explain

If the user selects **Still too complex**: subtract 2 more from `simplified_level` (minimum 1), reload `simplified_level_name`, and re-run Simplify 2/3 with the updated level. Repeat until the user is satisfied or `simplified_level` reaches 1.

If `simplified_level == 1`, skip this step and end.

Output: user's satisfaction status; updated `re_explanation` if re-run.
