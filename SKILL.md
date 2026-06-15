---
name: codeglish
description: Translates technical input — diffs, code, PRDs, markdown, plans — into plain English for non-technical readers. Scores input complexity, breaks complex code into labeled parts, tracks XP per programming language, and adapts explanation depth as users level up. Invoke with /codeglish or phrases like "explain this" or "translate this".
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
**Setup**: `/codeglish --init` — run the one-time setup wizard for this codebase.
**Override**: `/codeglish --override <level>` — force explanations at a specific level without changing your XP. Level can be a number (1–12) or a name (e.g. `Practiced`, `Expert`).
**Reset**: `/codeglish --reset exp` — wipe all saved XP levels. `/codeglish --reset override` — clear the active level override.

Also triggers without a slash command on:
- Natural-language: "explain this", "translate this", "what does this mean", "what changed"
- Context: user pastes a git diff, code snippet, PRD, markdown file, or proposed plan alongside a request for a plain-English explanation

## Inputs

| Name | Format | Source |
|------|--------|--------|
| `--init` flag | literal string `--init` | user message; triggers setup wizard instead of translation |
| `--override <level>` | `--override` followed by a level number (1–12) or level name | user message; sets a temporary explanation depth override |
| `--reset exp` | literal string `--reset exp` | user message; wipes all XP instead of translating |
| `--reset override` | literal string `--reset override` | user message; clears the active override instead of translating |
| `--reset` (no arg) | literal string `--reset` with nothing following | user message; triggers disambiguation hint |
| `input` | git diff, code snippet, PRD, markdown file, or proposed plan | inline in user message or file reference |
| `language` | detected automatically from syntax, file extension, or diff header | derived from `input` |

## Outputs

| Name | Format | Destination |
|------|--------|-------------|
| `explanation` | plain-English document; structured into parts when complexity is Complex or Very Complex | shown inline |
| `xp_update` | JSON write | `refs/codeglish-exp.json` |
| `level_up_notification` | one-line message appended to explanation | shown inline; omitted if no level-up |
| `codeglish-config.json` | JSON config written during `--init` | `refs/codeglish-config.json` |

## Progress emission

Main mode: emit `Step X/6 — <title>` at the start of each step, unconditionally.
Init mode: emit `Init X/5 — <title>` at the start of each init step, unconditionally.
Override mode: no progress markers — the mode is a single write operation.

## Step-by-step protocol

**Step 1 — Detect mode**

Check the user message for mode flags in this order:

- If `--init` is present → run `protocol/protocol-init.md` instead of Steps 2–6.
- If `--override` is present → run `protocol/protocol-override.md` instead of Steps 2–6.
- If any `--reset` variant is present (`--reset exp`, `--reset override`, or bare `--reset`) → run `protocol/protocol-reset.md` and stop.
- Otherwise → classify the input as one of: git diff, code snippet, PRD, markdown file, or proposed plan. Identify the primary programming language from syntax, file extension, or diff header. If the input contains no technical content — no code, no diff, no spec — emit this refusal and stop:
  > "Codeglish only works with technical input — diffs, code, specs, or plans. This doesn't look like one."

Output: `mode` (one of `translate` | `init` | `override` | `reset-override` | `reset-exp` | `reset-hint`), `input_type`, and `language` (when mode is `translate`).

**Step 2 — Score complexity**

Apply the heuristic from `refs/codeglish-heuristic.md` to the input. Assign one tier: Simple, Moderate, Complex, or Very Complex.

Output: `complexity_tier` (one of the four values above).

**Step 3 — Load XP for the detected language**

Read `refs/codeglish-exp.json`. Find the record keyed by `language`. If no record exists, create one: `{ "xp": 0, "level": 1 }`.

Compute `current_level` from `current_xp` using the threshold formula and level table in `refs/codeglish-levels.md` — `current_level` is the highest N whose threshold `current_xp` meets — and read the matching `level_name` from that table.

After determining `current_level`, read `refs/codeglish-config.json` and check for `override_level`. If `override_level` is set and non-null, set `effective_level = override_level`. Otherwise set `effective_level = current_level`. Use `effective_level` — not `current_level` — to drive explanation depth (per the "Level → explanation depth" table in `refs/codeglish-levels.md`) in Step 4. XP accumulation in Step 5 always uses `current_level` regardless.

Output: `current_level`, `effective_level`, `level_name`, and `current_xp`.

**Step 4 — Write plain-English output**

Translate the input into a detailed explanation. Apply all four rules:

1. **Explanation style**: frame every unit using the pattern "This [thing] does [action], so that [purpose/outcome]." Apply this at the level of the whole input first, and again for each part when breaking down.

2. **XP depth**: use `effective_level` from Step 3 to calibrate jargon and analogy density per the "Level → explanation depth" table in `refs/codeglish-levels.md`. The "Depth exemplars" section of that ref shows the same diff rendered across contrasting bands — consult it to calibrate the voice for `effective_level`.

3. **Structure by complexity**: look up `complexity_tier` in the "Output structure by tier" table of `refs/codeglish-heuristic.md` (the same ref applied at Step 2) and follow it — that table governs continuous vs. labeled parts, the per-part (and, for Very Complex, per-sub-section) "does X, so that Y" sentence, and the closing summary paragraph. Examples C and D in that ref show the labeled-parts format. The tier picks the structure; within it, let the dominant scoring dimension steer the emphasis per the "Dimension permutation exemplars" section of the same ref.

4. **Refusal boundary**: never suggest code changes, rewrites, or improvements. If the user asks for a fix or rewrite, explain the code and append:
   > "Codeglish only explains — it doesn't rewrite. Ask Claude directly for that."

Close the explanation with the XP summary line:
- No override active: `(Language XP: +N → Total: T | Level L — Label)`
- Override active: `(Language XP: +N → Total: T | Level L — Label | Override: explaining as Level OL — OLabel)`

Output: `explanation` (full text, ready to show inline).

**Step 5 — Award XP and update memory**

Calculate the XP award using the "XP award per run" table in `refs/codeglish-levels.md`: base XP for the input size × the complexity-tier multiplier, rounded to the nearest whole number. Add it to `current_xp` to get `new_xp`.

Recompute `new_level` from `new_xp` using the same threshold formula and level table (`refs/codeglish-levels.md`): apply `threshold(N)` starting at N=12 and walk down until `new_xp >= threshold(N)`. Set `leveled_up = true` if `new_level > current_level`.

Write `{ "xp": new_xp, "level": new_level }` to `refs/codeglish-exp.json` under the `language` key. Create the file if it does not exist.

Output: `new_xp`, `new_level`, `leveled_up` (boolean).

**Step 6 — Show level-up notification**

If `leveled_up` is true, append to the output:

> "Level up! You're now Level [N] in [Language]. Explanations will assume a bit more from here."

If `leveled_up` is false, skip this step and end.

Output: final inline response shown to the user.

## Mode protocols

Steps 1–6 above are the default **translate** mode. The other modes live in standalone protocol files, each replacing Steps 2–6 for that invocation:

- `protocol/protocol-init.md` — `--init` setup wizard (5 steps)
- `protocol/protocol-override.md` — `--override <level>` depth pin
- `protocol/protocol-reset.md` — `--reset`, `--reset exp`, and `--reset override` branches

## References

- `refs/codeglish-heuristic.md` — assigns a complexity tier (Simple / Moderate / Complex / Very Complex) at Step 2, and maps each tier to its output structure at Step 4; also holds the dimension-permutation exemplars (same tier via different dimension mixes) and the dominant-dimension → emphasis table that Step 4 rule 3 draws on
- `refs/codeglish-levels.md` — the XP economy: threshold formula, 12-level table, level→depth mapping, depth exemplars (one diff across several bands) used at Step 4 rule 2, per-run XP award table, and `--init` starting-XP seeds; consulted at Steps 3–5, Override mode, and Init 3
- `refs/codeglish-exp.json` — persistent XP store; one record per programming language; read at Step 3, written at Step 5
- `refs/codeglish-config.json` — codebase-level config written by `--init`; read at Init 1 to detect prior setup
- `refs/codeglish-map.md` — classifies scanned files into languages (extension mapping, exclusion rules, noise threshold); used at Init 2 when scanning the codebase
