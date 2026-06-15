---
name: Complexity Heuristic
description: Complexity-tier rubric for any code input — scores it Simple / Moderate / Complex / Very Complex at Step 2, and maps each tier to its output structure at Step 4 of the Codeglish protocol.
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

For git diffs, scope is the number of distinct files changed.

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

### Example C — Complex (score: 11)

A git diff touching two files: a class refactored to use dependency injection, with async methods and error handling added.

- Size: ~80 lines → 3 points
- Nesting: 3–4 levels (class → method → async block → try/except) → 3 points
- Concepts: 6 (class, async/await, dependency injection, error handling, method, constructor) → 3 points
- Scope: 2 files → 2 points
- **Total: 11 → Complex**

Output structure: split into labeled parts (e.g. "Part 1 — The class structure", "Part 2 — The async methods", "Part 3 — Error handling"). Each part opens with "This [part] does [action], so that [purpose]." End with a summary paragraph.

---

### Example D — Very Complex (score: 14)

A PR diff spanning 4 files: a new authentication middleware, a JWT token validator, updates to route guards, and a migration script.

- Size: 250+ lines → 4 points
- Nesting: 4+ levels → 4 points
- Concepts: 8+ (middleware pattern, JWT, async, error handling, DB migration, route guards, token expiry, class inheritance) → 4 points
- Scope: cross-cutting (auth boundary across API and DB) → 4 points - wait that's too many. Let me recalculate: 4+4+4+2 = 14 → Very Complex

Actually: 4 files changed → 3 points (multiple files).
- **Total: 4+4+4+3 = 15 → Very Complex**

Output structure: split into labeled parts with sub-sections. Summary paragraph ties all parts to the business goal.
