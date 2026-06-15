---
name: Codeglish Levels
description: The Codeglish XP economy — level threshold formula, the 12-level name/XP table, the level→explanation-depth mapping, depth exemplars rendering one diff across several bands, the per-run XP award table, and the --init starting-XP seeds. Consulted at Steps 3–5, Override mode, and Init 3.
type: reference
---

## Threshold formula

The XP required to reach level N:

> `threshold(N) = sum of floor(25 × 1.5^(k-1)) for k = 1 to N-1`

A user's level is the highest N where `current_xp >= threshold(N)`.

## Level table (levels 1–12)

| Level | Name | Min XP | XP to next level |
|-------|------|--------|-----------------|
| 1 | Beginner | 0 | 25 |
| 2 | Novice | 25 | 38 |
| 3 | Apprentice | 63 | 57 |
| 4 | Familiar | 120 | 85 |
| 5 | Practiced | 205 | 128 |
| 6 | Skilled | 333 | 192 |
| 7 | Comfortable | 525 | 288 |
| 8 | Proficient | 813 | 432 |
| 9 | Advanced | 1245 | 648 |
| 10 | Expert | 1893 | 972 |
| 11 | Master | 2865 | 1458 |
| 12 | Virtuoso | 4323 | ∞ |

To normalise a level name to its number (e.g. for `--override`), match against the Name column.

## Level → explanation depth

| Levels | Explanation depth |
|--------|------------------|
| 1–2 (Beginner / Novice) | No jargon; explain every term; 2+ everyday analogies per concept |
| 3–4 (Apprentice / Familiar) | Light jargon with inline definitions; 1–2 analogies per concept |
| 5–6 (Practiced / Skilled) | Common terms used freely; analogies only for non-obvious behavior |
| 7–8 (Comfortable / Proficient) | Technical vocabulary assumed; focus on logic flow and edge cases |
| 9–10 (Advanced / Expert) | Domain expertise assumed; focus on architectural intent and consequences |
| 11–12 (Master / Virtuoso) | Treat as a peer; discuss trade-offs, design patterns, and systemic implications |

## Depth exemplars — one change, several bands

The depth table above is abstract. These exemplars make it concrete: each takes **one fixed diff** and renders it at contrasting bands so the gradient is visible. Across the two exemplars, levels 1, 4, 6, 8, 10, and 12 are all shown.

What changes across bands: jargon, analogy density, and *what the explanation chooses to dwell on* (mechanics at low levels → consequences and trade-offs at high levels). What stays constant regardless of band: the opening "This [thing] does [action], so that [purpose]" framing, and the closing XP line. The XP values below are illustrative — the award math lives in "XP award per run".

### Exemplar 1 — a read-through cache (Python)

```diff
 def get_user(user_id):
+    if user_id in _cache:
+        return _cache[user_id]
     user = db.query(user_id)
+    _cache[user_id] = user
     return user
```

**At Level 1 — Beginner** (no jargon; explain every term; 2+ everyday analogies):

> This change does keep a copy of each answer the first time it's looked up, so that the same question never has to be asked twice.
>
> Imagine a librarian who, every time you ask for a book, walks all the way to a storeroom in the back to fetch it. That trip to the back is the line `db.query(...)` — "go ask the database for this user."
>
> The new lines add a small notepad at the front desk (called `_cache`). Now, before walking to the back, the librarian glances at the notepad:
> - If your user is already written down there, you get it instantly — no trip needed.
> - If not, the librarian fetches it the old way *and* jots it on the notepad on the way back, so next time it's just a quick glance.
>
> *What* you get back never changes — only how quickly you get it the second time onward.
>
> *(Python XP: +20 → Total: 20 | Level 1 — Beginner)*

**At Level 6 — Skilled** (common terms used freely; analogies only for non-obvious behavior):

> This change does add an in-memory cache in front of the database read, so that repeat lookups for the same user skip the query.
>
> Each call first checks `_cache` for `user_id`. A hit returns the stored object immediately; a miss falls through to `db.query`, stores the result under that key, then returns it — the classic read-through pattern. Behavior on a cold cache is identical to before; the win only shows up on the second and later calls for any given id.
>
> *(Python XP: +20 → Total: 350 | Level 6 — Skilled)*

**At Level 12 — Virtuoso** (peer-level; trade-offs, patterns, systemic implications):

> This change does interpose a read-through cache on the user fetch, so that hot keys avoid the database round-trip — and it ships with the sharp edges left in.
>
> It's a process-local, unbounded dict with no eviction: every distinct `user_id` ever requested is retained for the life of the process, so on a long-lived worker this is a slow memory leak — no TTL, no LRU bound. There's no invalidation path, so any write to a user elsewhere makes this serve stale reads until restart. The check-then-set isn't synchronized, so under threads or async you can race on the `in`/assign pair. And it never caches negative results, so repeated lookups of a nonexistent id keep hitting the DB. As a request-scoped read of near-immutable data it's fine; as a long-lived shared cache it wants a bounded store, an invalidation hook, and a concurrency story.
>
> *(Python XP: +20 → Total: 4500 | Level 12 — Virtuoso)*

### Exemplar 2 — sequential awaits → `Promise.all` (TypeScript)

```diff
-const user = await fetchUser(id);
-const orders = await fetchOrders(id);
-const prefs = await fetchPrefs(id);
+const [user, orders, prefs] = await Promise.all([
+  fetchUser(id),
+  fetchOrders(id),
+  fetchPrefs(id),
+]);
```

**At Level 4 — Familiar** (light jargon with inline definitions; 1–2 analogies):

> This change does start all three data fetches at the same time (in parallel) instead of one after another, so that the screen finishes loading sooner.
>
> Before, the code `await`ed each call in turn — "await" means *wait here until this one finishes*. So it waited for the user, then the orders, then the preferences: three waits, back to back.
>
> After, `Promise.all([...])` hands off all three requests at once and waits for the whole batch to return together — like running three loads of laundry in three machines at once rather than one machine three times.
>
> *(TypeScript XP: +25 → Total: 160 | Level 4 — Familiar)*

**At Level 8 — Proficient** (technical vocabulary assumed; focus on logic flow and edge cases):

> This change does fire the three fetches concurrently and await them as a batch, so that total latency drops from the sum of the three calls to the slowest single one.
>
> The destructuring is positional — `[user, orders, prefs]` map to the input array's order, not completion order. Mind the failure semantics: `Promise.all` is fail-fast, so the first rejection rejects the whole expression immediately; the other two requests still run to completion but their results and errors are discarded. A single flaky endpoint now fails the entire load, where before you'd at least have had `user` in hand before the failure.
>
> *(TypeScript XP: +25 → Total: 900 | Level 8 — Proficient)*

**At Level 10 — Expert** (domain expertise assumed; focus on architectural intent and consequences):

> This change does collapse a sequential await chain into a concurrent join, so that the three reads overlap on the wire — trading error granularity for latency.
>
> The architectural consequence is the failure model. Fail-fast `Promise.all` means partial success is no longer observable to the caller and error attribution coarsens — you learn the batch failed, not cleanly which leg. If the reads are independent and the UI can degrade per-section, `Promise.allSettled` keeps the latency win while preserving per-leg outcomes. Note too there's no cancellation: a rejection doesn't abort the in-flight siblings, so on the error path you still pay their full cost and any side effects land. And you've raised the concurrency floor to three simultaneous connections per call, which matters against rate limits or a connection-pool ceiling under load.
>
> *(TypeScript XP: +25 → Total: 2000 | Level 10 — Expert)*

## XP award per run

Base XP by input size:

| Input size | Base XP |
|-----------|---------|
| 1–10 lines | 10 |
| 11–50 lines | 25 |
| 51–200 lines | 50 |
| 200+ lines | 100 |

Complexity multiplier (tier from `codeglish-heuristic.md`):

| Complexity tier | Multiplier |
|----------------|-----------|
| Simple | ×1.0 |
| Moderate | ×1.5 |
| Complex | ×2.0 |
| Very Complex | ×3.0 |

Award = round(base XP × multiplier).

## Starting XP for --init

Maps each proficiency answer (Init 3) to a starting XP value and level:

| Answer | Starting XP | Starting level |
|--------|-------------|----------------|
| Never used it | 0 | 1 — Beginner |
| Can read but rarely write | 25 | 2 — Novice |
| Know the basics | 120 | 4 — Familiar |
| Use it regularly | 525 | 7 — Comfortable |
| Expert | 1893 | 10 — Expert |
