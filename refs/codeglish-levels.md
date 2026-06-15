---
name: Codeglish Levels
description: The Codeglish XP economy — level threshold formula, the 12-level name/XP table, the level→explanation-depth mapping, the per-run XP award table, and the --init starting-XP seeds. Consulted at Steps 3–5, Override mode, and Init 3.
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
