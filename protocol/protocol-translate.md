---
name: Codeglish Translate Mode
description: The default /codeglish translation protocol — scores complexity, loads XP, writes a plain-English explanation structured by tier, awards XP, and shows a level-up notification if earned. Runs as Steps 2–6 when no other mode flag is detected.
type: protocol
---

# Translate mode

Runs when Step 1 of SKILL.md detects no mode flag and classifies the input as a git diff, code snippet, PRD, markdown file, or proposed plan. Step 1 has already emitted `Checking your input…`. Emit `Translating…` once before Step 4 begins; no other progress markers.

---

**Step 2 — Score complexity** *(no progress marker)*

Apply the heuristic from `refs/codeglish-heuristic.md` to the input. Assign one of the seven tiers: Trivial, Simple, Moderate, Involved, Complex, Very Complex, or Intricate.

Output: `complexity_tier` (one of the seven values above).

---

**Step 3 — Load XP for the detected language** *(no progress marker)*

Read `refs/codeglish-exp.json`. Find the record keyed by `language`. If no record exists, create one: `{ "xp": 0, "level": 1 }`.

Compute `current_level` from `current_xp` using the threshold formula and level table in `refs/codeglish-levels.md` — `current_level` is the highest N whose threshold `current_xp` meets — and read the matching `level_name` from that table.

After determining `current_level`, read `refs/codeglish-config.json` and check for `override_level`. If `override_level` is set and non-null, set `effective_level = override_level`. Otherwise set `effective_level = current_level`. Use `effective_level` — not `current_level` — to drive explanation depth in Step 4. XP accumulation in Step 5 always uses `current_level` regardless.

Output: `current_level`, `effective_level`, `level_name`, `current_xp`.

---

**Step 4 — Write plain-English output** *(emit `Translating…` before this step)*

Translate the input into a detailed explanation. Apply all four rules:

1. **Explanation style**: frame every unit using the pattern "This [thing] does [action], so that [purpose/outcome]." Apply this at the level of the whole input first, and again for each part when breaking down.

2. **XP depth**: use `effective_level` from Step 3 to calibrate jargon and analogy density per the "Level → explanation depth" table in `refs/codeglish-levels.md`. The "Depth exemplars" section of that ref shows the same diff rendered across contrasting bands — consult it to calibrate the voice for `effective_level`.

3. **Structure by complexity**: look up `complexity_tier` in the "Output structure by tier" table of `refs/codeglish-heuristic.md` and follow it — that table governs continuous vs. labeled parts, the per-part (and, for Very Complex and Intricate, per-sub-section) "does X, so that Y" sentence, and the closing summary paragraph. The tier picks the structure; within it, let the dominant scoring dimension steer the emphasis per the "Dimension permutation exemplars" section of the same ref.

4. **Refusal boundary**: never suggest code changes, rewrites, or improvements. If the user asks for a fix or rewrite, explain the code and append:
   > "Codeglish only explains — it doesn't rewrite. Ask Claude directly for that."

Close the explanation with the XP summary line:
- No override active: `(Language XP: +N → Total: T | Level L — Label)`
- Override active: `(Language XP: +N → Total: T | Level L — Label | Override: explaining as Level OL — OLabel)`

Output: `explanation` (full text, ready to show inline).

---

**Step 5 — Award XP and update memory** *(no progress marker)*

Calculate the XP award using the "XP award per run" table in `refs/codeglish-levels.md`: base XP for the input size × the complexity-tier multiplier, rounded to the nearest whole number. Add it to `current_xp` to get `new_xp`.

Recompute `new_level` from `new_xp` using the same threshold formula and level table: apply `threshold(N)` starting at N=12 and walk down until `new_xp >= threshold(N)`. Set `leveled_up = true` if `new_level > current_level`.

Write `{ "xp": new_xp, "level": new_level }` to `refs/codeglish-exp.json` under the `language` key. Create the file if it does not exist.

Output: `new_xp`, `new_level`, `leveled_up` (boolean).

---

**Step 6 — Show level-up notification** *(appended to output; no separate marker)*

If `leveled_up` is true, append to the output:
> "Level up! You're now Level [N] in [Language]. Explanations will assume a bit more from here."

If `leveled_up` is false, skip this step and end.

Output: final inline response shown to the user.
