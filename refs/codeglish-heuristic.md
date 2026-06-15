---
name: Complexity Heuristic
description: Complexity-tier rubric for any code input — scores it Simple / Moderate / Complex / Very Complex at Step 2, and maps each tier to its output structure at Step 4 of the Codeglish protocol. Includes dimension-permutation exemplars showing how the same tier is reached by different dimension mixes, and which dimension steers the explanation's emphasis.
type: reference
---

## Overview

Score the input on four dimensions. Sum the points. Map the total to a tier.

No single dimension is decisive — a 300-line file with no branching is Moderate, not Complex.

## Scoring dimensions

### 1. Size (lines of code or diff lines)

| Range | Points |
|-------|--------|
| 1–10 lines | 1 |
| 11–50 lines | 2 |
| 51–200 lines | 3 |
| 200+ lines | 4 |

Count only code lines. Blank lines and comments do not count.

### 2. Nesting depth (how many levels of indentation the logic reaches)

| Max nesting depth | Points |
|-------------------|--------|
| 0–1 levels (flat) | 1 |
| 2 levels | 2 |
| 3 levels | 3 |
| 4+ levels | 4 |

Count each `if`, `for`, `while`, `try`, `with`, lambda body, or function body as one nesting level.

### 3. Concept count (distinct programming concepts introduced)

| Concepts introduced | Points |
|--------------------|--------|
| 1–2 (e.g. a single loop or a single function call) | 1 |
| 3–4 (e.g. a function with a loop and a conditional) | 2 |
| 5–7 (e.g. classes, inheritance, callbacks, or async) | 3 |
| 8+ (e.g. multiple design patterns, closures, generics, concurrency) | 4 |

Concepts include: variable assignment, function definition, function call, loop, conditional, class, inheritance, closure, callback, async/await, error handling, type annotation, recursion, decorator, generator, higher-order function, pattern matching.

### 4. Scope (how many units the input spans)

| Scope | Points |
|-------|--------|
| One function or block | 1 |
| One file, multiple functions | 2 |
| Multiple files or modules | 3 |
| Cross-cutting concern (auth, logging, DB, API boundary) | 4 |

For git diffs, score scope by reach: a hunk inside one function → 1; one file, several functions → 2; multiple files → 3; touches a cross-cutting concern (auth, logging, DB, API boundary) → 4. When more than one applies, take the highest — a 4-file change that also crosses the auth boundary scores 4, not 3.

## Tier mapping

| Total score | Tier |
|-------------|------|
| 4–6 | Simple |
| 7–9 | Moderate |
| 10–12 | Complex |
| 13–16 | Very Complex |

## Output structure by tier

| Tier | Output structure |
|------|-----------------|
| Simple | One continuous explanation |
| Moderate | One continuous explanation, up to 2 analogies |
| Complex | Split into labeled parts; one "does X, so that Y" sentence per part; summary paragraph at end |
| Very Complex | Split into labeled parts with sub-sections where needed; one "does X, so that Y" sentence per part and per sub-section; summary paragraph at end |

## Worked examples

### Example A — Simple (score: 5)

```python
def double(x):
    return x * 2
```

- Size: 2 lines → 1 point
- Nesting: 1 level (function body) → 1 point
- Concepts: 2 (function definition, return) → 1 point
- Scope: 1 function → 1 point
- **Total: 4 → Simple**

Output structure: one continuous explanation.

---

### Example B — Moderate (score: 8)

```python
def get_active_users(users):
    result = []
    for user in users:
        if user["active"]:
            result.append(user)
    return result
```

- Size: 6 lines → 1 point
- Nesting: 3 levels (function → for → if) → 3 points
- Concepts: 4 (function, list, loop, conditional) → 2 points
- Scope: 1 function → 1 point
- **Total: 7 → Moderate**

Output structure: one continuous explanation with one analogy.

---

### Example C — Complex (score: 12)

A git diff touching two files: a class refactored to use dependency injection, with async methods and error handling added.

- Size: ~80 lines → 3 points
- Nesting: 3–4 levels (class → method → async block → try/except) → 3 points
- Concepts: 6 (class, async/await, dependency injection, error handling, method, constructor) → 3 points
- Scope: 2 files → 3 points (multiple files)
- **Total: 12 → Complex**

Output structure: split into labeled parts (e.g. "Part 1 — The class structure", "Part 2 — The async methods", "Part 3 — Error handling"). Each part opens with "This [part] does [action], so that [purpose]." End with a summary paragraph.

---

### Example D — Very Complex (score: 16)

A PR diff spanning 4 files: a new authentication middleware, a JWT token validator, updates to route guards, and a migration script.

- Size: 250+ lines → 4 points
- Nesting: 4+ levels → 4 points
- Concepts: 8+ (middleware pattern, JWT, async, error handling, DB migration, route guards, token expiry, class inheritance) → 4 points
- Scope: 4 files **and** a cross-cutting concern (auth across API and DB) → take the higher → 4 points
- **Total: 16 → Very Complex**

Output structure: split into labeled parts with sub-sections. Summary paragraph ties all parts to the business goal.

## Dimension permutation exemplars

The four dimensions do not move in lockstep. Two inputs can hit the **same total** by entirely different routes, and they need different explanations even though the tier — and so the output *container* (continuous vs. labeled parts) — is identical.

Read the score in two passes:

1. **The total picks the container.** Use the tier mapping and "Output structure by tier" table above — that decides continuous vs. labeled parts.
2. **The dominant dimension picks the emphasis.** The single highest-scoring dimension tells you *where inside that container the words should go*.

### Dominant dimension → explanation emphasis

| Highest-scoring dimension | Where the explanation should spend its words |
|---------------------------|----------------------------------------------|
| **Size** | Grouping & navigation. Chunk the bulk into a few named regions the reader can skim; describe the shape of the whole, don't narrate every line. |
| **Nesting** | Control flow. Walk the decision and loop layers from the outside in — "first it checks X; *inside that* it loops over Y; *inside that* …" — one beat per level. |
| **Concepts** | Vocabulary. Introduce each unfamiliar concept once, in dependency order, before showing how they combine. The reader's blocker is terms, not length. |
| **Scope** | The through-line. Name the one change and show that it recurs across the files/modules; emphasise consistency ("the same edit, six places"), not novelty. |

When two dimensions tie for highest, lead with whichever the reader is more likely to stumble on — usually Concepts over Size.

### Three roads to Moderate (total 7–9)

All three score Moderate, so all three get one continuous explanation with up to two analogies. But the dominant dimension — and therefore the emphasis — differs in each.

**Road 1 — big but flat.** A 240-line database seed file: one long literal list of record dicts, no logic.

- Size: 240 lines → 4
- Nesting: flat literal → 1
- Concepts: assignment + list/dict literal → 1
- Scope: one literal block → 1
- **Total: 7 → Moderate.** Dominant dimension: **Size** → emphasis on *grouping & navigation*. Describe the kinds of records and how they're organised; do not walk every entry.

**Road 2 — tiny but dense.** An 8-line recursive list-flattener.

```python
def flatten(xs):
    out = []
    for x in xs:
        if isinstance(x, list):
            out.extend(flatten(x))
        else:
            out.append(x)
    return out
```

- Size: 8 lines → 1
- Nesting: function → for → if/else → 3
- Concepts: function, loop, conditional, recursion, list → 5 → 3
- Scope: one function → 1
- **Total: 8 → Moderate.** Dominant dimensions: **Nesting + Concepts** (tie) → lead with *vocabulary* (what recursion means), then *control flow* (a call that re-enters itself). Eight lines, but the densest of the three.

**Road 3 — wide but shallow.** A rename of `getUsr` → `getUser` and its call sites across 4 files.

- Size: ~16 changed lines → 2
- Nesting: flat → 1
- Concepts: a rename + function calls → 1
- Scope: 4 files → 3 (multiple files)
- **Total: 7 → Moderate.** Dominant dimension: **Scope** → emphasis on *the through-line*. State the single rename once and that it was applied identically everywhere; the file count is the only reason this isn't Simple.

Same tier, three completely different explanations: the seed file gets *skimmed*, the flattener gets *unpacked*, the rename gets *summarised once*.

### One dimension flips the tier

No single dimension is decisive in the middle of a tier — but at a boundary, a one-point move on a single dimension changes the output structure. Same ~70-line async function in both versions:

| Version | Size | Nesting | Concepts | Scope | Total | Tier | Structure |
|---------|------|---------|----------|-------|-------|------|-----------|
| Before | 3 | 3 | 2 | 1 | **9** | Moderate | one continuous explanation |
| After (adds a closure + a callback → concepts 2→3) | 3 | 3 | 3 | 1 | **10** | Complex | split into labeled parts |

The code grew by a few lines, but crossing 9→10 flips the reader from a single narrative into labeled parts with a summary. Re-score at the boundary; don't assume a small edit keeps the old structure.

### The extremes mirror

The two ends of the Size dimension can land on the *same tier* — proof that length alone never decides:

- A 500-line auto-generated API client: Size 4, Nesting 1, Concepts 1, Scope 1 → **7, Moderate**.
- A 3-line point-free functional one-liner (compose + currying + higher-order fns): Size 1, Nesting 1, Concepts 4, Scope 1 → **7, Moderate**.

Both Moderate; opposite emphases (skim the generated bulk vs. unpack the dense one-liner). "Huge" and "tiny" are not "complex" — the rubric scores reach and density, not line count.
