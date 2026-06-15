---
name: Codeglish Comments Mode
description: The /codeglish --comments [file path] protocol — explains a code file in Codeglish format, then offers to insert single-line comments above functions and classes. Runs in place of Steps 2–6 of SKILL.md.
type: protocol
---

# Comments mode

Runs when Step 1 of SKILL.md detects `--comments`. Replaces the main Steps 2–6 for this invocation only. Emit `Comment X/5 — <title>` at the start of each step, unconditionally.

---

**Comment 1/5 — Read and validate the file**

Read the file at the path given after `--comments`. Detect language from the file extension. Confirm it is a code file; if the extension is not a known code extension (`.ts`, `.tsx`, `.js`, `.jsx`, `.py`, `.go`, `.rs`, `.swift`, `.kt`, `.java`, `.rb`, `.c`, `.cpp`, `.cs`, `.php`), emit:
> "Codeglish comments work on code files. Try a `.ts`, `.tsx`, `.js`, `.py`, `.go`, `.rs`, `.swift`, or similar file."
and stop.

Output: `language`, file contents.

---

**Comment 2/5 — Score complexity and load XP**

Apply the heuristic from `refs/codeglish-heuristic.md` to the file contents (same as Step 2 of the main translate protocol). Load XP from `refs/codeglish-exp.json` for the detected language (same as Step 3). Resolve `effective_level` by checking `refs/codeglish-config.json` for `override_level`.

Output: `complexity_tier`, `current_level`, `effective_level`, `level_name`, `current_xp`.

---

**Comment 3/5 — Explain the file inline**

Write a plain-English overview of the file in Codeglish format:

1. **File summary** — one sentence: "This file does [action], so that [purpose]."
2. **Block-by-block** — for each significant block (function, class, hook, named export, constant): one "does X, so that Y" sentence at the `effective_level` depth, plus a brief note on key dependencies if visible in the file.

Apply `effective_level` depth per `refs/codeglish-levels.md`. Never suggest changes or rewrites.

Close with the XP summary line, noting that XP is awarded at half rate:
- `(Language XP: +N → Total: T | Level L — Label | ½ rate — comments mode)`

Output: `file_explanation` (shown inline).

---

**Comment 4/5 — Offer to insert comments**

After showing the explanation, ask via AskUserQuestion:

> "Want me to add single-line Codeglish comments to `[filename]`?"
> Each comment appears on the line directly above the function or class it describes.
> Format: `// [Plain-English purpose] — deps: [dep1, dep2] | refs: [callers or usage if visible]`

If the user says yes:
- For each significant block (function, class, hook, named export), compose a single-line comment in the format above. Keep each comment under 120 characters.
- `deps:` lists imports or other symbols the block directly calls. Omit the segment if none.
- `refs:` notes where the block is called or used within the same file. Omit the segment if not visible.
- Insert the comment on the line immediately preceding the function/class declaration.
- Write the modified contents back to the original file path using the Write tool.

If the user says no: no file write.

Output: the user's choice and the modified file (if written).

---

**Comment 5/5 — Award XP and show level-up**

Calculate XP at **half** the normal rate (annotation is lighter work than full explanation): apply the standard "XP award per run" formula from `refs/codeglish-levels.md`, then halve the result (round to nearest whole number). Add to `current_xp` to get `new_xp`. Recompute `new_level`. Write `{ "xp": new_xp, "level": new_level }` to `refs/codeglish-exp.json` under the `language` key.

If `new_level > current_level`, append:
> "Level up! You're now Level [N] in [Language]. Explanations will assume a bit more from here."

Output: `new_xp`, `new_level`; level-up notification if applicable.
