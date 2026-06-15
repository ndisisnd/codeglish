---
name: Codeglish File-Translate Mode
description: The /codeglish [file path] protocol — reads a file, translates it to plain English with a summary, then offers to show only, overwrite, or emit a codeglish-filename.ext copy. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# File-translate mode

Runs when Step 1 of SKILL.md detects a file path as the primary or sole input (no inline diff or code). Replaces the main Steps 2–6 for this invocation only. Emit `File X/6 — <title>` at the start of each step, unconditionally.

---

**File 1/6 — Read and classify the file**

Read the file at the given path using the Read tool. Classify it as one of:
- `doc-file` — markdown, plain text, or prose documentation (`.md`, `.txt`, `.yaml`, `.toml`, `.json` used as config docs)
- `code-file` — any source code file detected by extension

Identify the primary language: for code files use the file extension; for doc files set language to `"markdown"` or `"prose"`.

Output: `file_type` (`doc-file` | `code-file`), `language`.

---

**File 2/6 — Score complexity**

Apply the heuristic from `refs/codeglish-heuristic.md` to the file contents. Assign one of the seven tiers: Trivial, Simple, Moderate, Involved, Complex, Very Complex, or Intricate.

Output: `complexity_tier`.

---

**File 3/6 — Load XP**

Same as Step 3 of the main translate protocol. Read `refs/codeglish-exp.json` for the detected language. If no record exists, create one: `{ "xp": 0, "level": 1 }`. Compute `current_level` and `level_name` from the threshold formula in `refs/codeglish-levels.md`. Check `refs/codeglish-config.json` for `override_level`; set `effective_level` accordingly.

Output: `current_level`, `effective_level`, `level_name`, `current_xp`.

---

**File 4/6 — Translate the file**

Produce a plain-English translation of the entire file. Structure:

1. **Summary** — one paragraph stating what this file is and why it exists ("This file does [action], so that [purpose]").
2. **Section-by-section** — for `doc-file`: rewrite each heading's content in Codeglish style, preserving heading labels. For `code-file`: walk through each exported function, class, hook, and named constant with the "does X, so that Y" framing; note key dependencies inline.
3. **Closing summary** — one paragraph recapping the file's role in the larger system.

Apply `effective_level` depth per `refs/codeglish-levels.md`. Never suggest changes or rewrites; if the file invites that, append:
> "Codeglish only explains — it doesn't rewrite. Ask Claude directly for that."

Close with the XP summary line (same format as Step 4 main mode):
- No override: `(Language XP: +N → Total: T | Level L — Label)`
- Override active: `(Language XP: +N → Total: T | Level L — Label | Override: explaining as Level OL — OLabel)`

Output: `translation` (full text, shown inline).

---

**File 5/6 — Offer write options**

After showing the translation, ask the user to choose one of three options via AskUserQuestion:

> "What would you like to do with this translation?"
> - **Show only** — keep it in the chat (default)
> - **Overwrite** — replace `[filename]` with the Codeglish version
> - **Save as new file** — write `codeglish-[filename].[ext]` in the same directory

If the user chooses **Overwrite**: write the translation to the original file path using the Write tool.
If the user chooses **Save as new file**: derive the output path as `[directory]/codeglish-[basename].[ext]` and write the translation there using the Write tool.
If the user chooses **Show only** (or skips): no file write.

Output: chosen option and any file written.

---

**File 6/6 — Award XP and show level-up**

Calculate XP using the "XP award per run" table in `refs/codeglish-levels.md`: base XP for input size × complexity-tier multiplier, rounded to the nearest whole number. Add to `current_xp` to get `new_xp`. Recompute `new_level`. Write `{ "xp": new_xp, "level": new_level }` to `refs/codeglish-exp.json` under the `language` key.

If `new_level > current_level`, append:
> "Level up! You're now Level [N] in [Language]. Explanations will assume a bit more from here."

Output: `new_xp`, `new_level`; level-up notification if applicable.
