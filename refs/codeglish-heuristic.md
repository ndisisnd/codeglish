---
name: Complexity Heuristic
description: Complexity-tier rubric for any code input — scores it across four weighted dimensions and maps the total to one of seven tiers (Trivial → Simple → Moderate → Involved → Complex → Very Complex → Intricate) at Step 2, then maps each tier to its output structure at Step 4 of the Codeglish protocol. Includes dimension-permutation exemplars showing how the same tier is reached by different dimension mixes, and which dimension steers the explanation's emphasis.
type: reference
---

## Overview

Score the input on four dimensions. Sum the points. Map the total to a tier.

No single dimension is decisive — a 300-line file with no branching is Moderate, not Complex. The dimensions are weighted unevenly on purpose: Size reaches 6 points and Scope reaches 5, because raw bulk and cross-boundary reach are the two things most likely to hide complexity that the other dimensions miss.

## Scoring dimensions

### 1. Size (lines of code or diff lines)

| Range | Points |
|-------|--------|
| 1–10 lines | 1 |
| 11–40 lines | 2 |
| 41–100 lines | 3 |
| 101–250 lines | 4 |
| 251–600 lines | 5 |
| 600+ lines | 6 |

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
| Spans both front-end and back-end (full-stack change) | 5 |

For git diffs, score scope by reach: a hunk inside one function → 1; one file, several functions → 2; multiple files → 3; touches a cross-cutting concern (auth, logging, DB, API boundary) → 4; the change straddles both the front-end and the back-end — a full-stack change where the same feature lands on both sides of the client/server boundary → 5. When more than one applies, take the highest — a 4-file change that also crosses the auth boundary scores 4; if those files straddle the front-end/back-end split, it scores 5.

## Tier mapping

| Total score | Tier |
|-------------|------|
| 4–5 | Trivial |
| 6–7 | Simple |
| 8–9 | Moderate |
| 10–12 | Involved |
| 13–14 | Complex |
| 15–16 | Very Complex |
| 17–19 | Intricate |

The minimum possible total is 4 (all dimensions at 1); the maximum is 19 (Size 6 + Nesting 4 + Concepts 4 + Scope 5).

## Output structure by tier

| Tier | Output structure |
|------|-----------------|
| Trivial | One short continuous explanation, a sentence or two; no analogy needed |
| Simple | One continuous explanation |
| Moderate | One continuous explanation, up to 2 analogies |
| Involved | One continuous explanation opened by a one-line map of the moving parts; up to 2 analogies |
| Complex | Split into labeled parts; one "does X, so that Y" sentence per part; summary paragraph at end |
| Very Complex | Split into labeled parts with sub-sections where needed; one "does X, so that Y" sentence per part and per sub-section; summary paragraph at end |
| Intricate | Split into labeled parts with sub-sections; an orientation paragraph up front naming the parts and how they relate; one "does X, so that Y" sentence per part and per sub-section; summary paragraph at end tying every part to the business goal |

## Worked examples

One example per tier, scored on all four dimensions.

### Example A — Trivial (score: 4)

```python
def double(x):
    return x * 2
```

- Size: 2 lines → 1 point
- Nesting: 1 level (function body) → 1 point
- Concepts: 2 (function definition, return) → 1 point
- Scope: 1 function → 1 point
- **Total: 4 → Trivial**

Output structure: one short continuous explanation.

---

### Example B — Simple (score: 7)

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
- **Total: 7 → Simple**

Output structure: one continuous explanation.

---

### Example C — Moderate (score: 8)

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

- Size: 8 lines → 1 point
- Nesting: function → for → if/else → 3 points
- Concepts: 5 (function, loop, conditional, recursion, list) → 3 points
- Scope: 1 function → 1 point
- **Total: 8 → Moderate**

Output structure: one continuous explanation with up to two analogies.

---

### Example D — Involved (score: 12)

A git diff touching two files: a class refactored to use dependency injection, with async methods and error handling added.

- Size: ~80 lines → 3 points
- Nesting: 3–4 levels (class → method → async block → try/except) → 3 points
- Concepts: 6 (class, async/await, dependency injection, error handling, method, constructor) → 3 points
- Scope: 2 files → 3 points (multiple files)
- **Total: 12 → Involved**

Output structure: one continuous explanation, opened by a one-line map of the moving parts ("Three things change: the class constructor, the async methods, and the new error handling").

---

### Example E — Complex (score: 14)

A 140-line refactor across two files: a synchronous data-processing module rewritten as a generic, async pipeline with typed stages and centralized error handling.

- Size: ~140 lines → 4 points (101–250)
- Nesting: 3 levels (pipeline → stage → try/except) → 3 points
- Concepts: 8+ (generics, async/await, higher-order functions, error handling, type annotations, closures, pipeline pattern, decorators) → 4 points
- Scope: 2 files → 3 points
- **Total: 14 → Complex**

Output structure: split into labeled parts (e.g. "Part 1 — The pipeline shell", "Part 2 — The typed stages", "Part 3 — Error handling"). Each part opens with "This [part] does [action], so that [purpose]." End with a summary paragraph.

---

### Example F — Very Complex (score: 15)

A feature PR adding a "save draft" capability: a new React form component with local state and inline validation (front-end) **and** a new `POST /drafts` endpoint with request validation and a DB write (back-end), ~200 lines total.

- Size: ~200 lines → 4 points (101–250)
- Nesting: 3 levels → 3 points
- Concepts: 6 (component state, validation, async fetch, endpoint handler, DB write, error handling) → 3 points
- Scope: spans front-end **and** back-end → 5 points (full-stack)
- **Total: 15 → Very Complex**

Output structure: split into labeled parts with sub-sections where needed (e.g. a "Front-end" part and a "Back-end" part, each with its own sub-sections). Each part and sub-section opens with "This [part] does [action], so that [purpose]." Summary paragraph ties the two halves to the one feature.

---

### Example G — Intricate (score: 17)

A PR diff spanning 4 files: a new authentication middleware, a JWT token validator, updates to route guards, and a migration script.

- Size: 250+ lines → 5 points (251–600)
- Nesting: 4+ levels → 4 points
- Concepts: 8+ (middleware pattern, JWT, async, error handling, DB migration, route guards, token expiry, class inheritance) → 4 points
- Scope: 4 files **and** a cross-cutting concern (auth across API and DB) → take the higher → 4 points
- **Total: 17 → Intricate**

Output structure: an orientation paragraph up front naming the four parts and how they relate, then labeled parts with sub-sections. Summary paragraph ties all parts to the business goal.

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
| **Scope** | The through-line. Name the one change and show that it recurs across the files/modules; emphasise consistency ("the same edit, six places"), not novelty. For a full-stack change (Scope 5), show how the *same intent* appears on both sides of the front-end/back-end boundary — the front-end sends what the back-end is now expecting. |

When two dimensions tie for highest, lead with whichever the reader is more likely to stumble on — usually Concepts over Size.

### Three roads to Moderate (total 8–9)

All three score Moderate, so all three get one continuous explanation with up to two analogies. But the dominant dimension — and therefore the emphasis — differs in each.

**Road 1 — big but flat.** A 600+ line database seed file: one long literal list of record dicts, no logic.

- Size: 600+ lines → 6
- Nesting: flat literal → 1
- Concepts: assignment + list/dict literal → 1
- Scope: one literal block → 1
- **Total: 9 → Moderate.** Dominant dimension: **Size** → emphasis on *grouping & navigation*. Describe the kinds of records and how they're organised; do not walk every entry.

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

**Road 3 — wide but shallow.** A rename of an API field `usr_name` → `user_name`, applied in a React form (front-end) and the matching serializer (back-end).

- Size: ~20 changed lines → 2
- Nesting: flat → 1
- Concepts: a rename + field references → 1
- Scope: spans front-end and back-end → 5 (full-stack)
- **Total: 9 → Moderate.** Dominant dimension: **Scope** → emphasis on *the through-line*. State the single rename once and that the front-end and back-end had to move together so the field they exchange still matches; the cross-boundary reach is the only reason this isn't Trivial.

Same tier, three completely different explanations: the seed file gets *skimmed*, the flattener gets *unpacked*, the rename gets *summarised once across both sides*.

### One dimension flips the tier

No single dimension is decisive in the middle of a tier — but at a boundary, a one-point move on a single dimension changes the output structure. Same ~120-line async function in both versions:

| Version | Size | Nesting | Concepts | Scope | Total | Tier | Structure |
|---------|------|---------|----------|-------|-------|------|-----------|
| Before | 4 | 4 | 3 | 1 | **12** | Involved | one continuous explanation |
| After (adds a closure + a callback → concepts 3→4) | 4 | 4 | 4 | 1 | **13** | Complex | split into labeled parts |

The code grew by a few lines, but crossing 12→13 flips the reader from a single narrative into labeled parts with a summary. Re-score at the boundary; don't assume a small edit keeps the old structure.

### The extremes mirror

The two ends of the Size dimension can land on the *same tier* — proof that length alone never decides:

- A ~200-line auto-generated API client: Size 4, Nesting 1, Concepts 1, Scope 1 → **7, Simple**.
- A 3-line point-free functional one-liner (compose + currying + partial application + higher-order fns + point-free style + pattern matching → 8+ concepts): Size 1, Nesting 1, Concepts 4, Scope 1 → **7, Simple**.

Both Simple; opposite emphases (skim the generated bulk vs. unpack the dense one-liner). "Huge" and "tiny" are not "complex" — the rubric scores reach and density, not line count.
