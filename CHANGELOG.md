# Changelog

All notable changes to this project will be documented here.

## 2026-06-28

Added a consistent persona voice and session follow-up prompts to the codeglish skill. All explanation modes now speak as a principal engineer mentoring a smart adult colleague — respecting intelligence, teaching the why, and staying direct. Translate and file modes both end with an `AskUserQuestion` giving users the option to dive deeper or wrap up.

- README.md — add dedication line
- SKILL.md — add Persona section defining the mentoring voice and its six behavioural rules
- protocol/protocol-translate.md — add Rule 0 (persona) to the translate step, add Step 7 (follow-up prompt)
- protocol/protocol-file.md — renumber steps X/6 → X/7, add File 7/7 follow-up prompt

## 2026-06-15 (2)

Expanded the complexity tier system from 4 tiers to 7 (Trivial → Simple → Moderate → Involved → Complex → Very Complex → Intricate). The Size scoring dimension now reaches 6 points (up from 4), and Scope gains a full-stack row at 5 points. Every reference file and the SKILL.md entry point was updated to match; new XP multipliers (×0.75 for Trivial, ×1.75 for Involved, ×4.0 for Intricate) were added to the levels ref.

- SKILL.md — update all tier references and heuristic ref description
- refs/codeglish-heuristic.md — add Trivial/Involved/Intricate tiers, expand Size/Scope scoring, rebalance tier ranges, add worked examples C–G, update permutation exemplars and boundary table
- refs/codeglish-levels.md — add XP multipliers for Trivial, Involved, and Intricate

## 2026-06-15

Initial scaffold of the codeglish skill: protocol definitions, reference data, and project tooling.

- SKILL.md — skill entry point and usage
- protocol/protocol-init.md, protocol-override.md, protocol-reset.md — protocol definitions
- refs/codeglish-config.json, codeglish-exp.json — configuration and experience data
- refs/codeglish-heuristic.md, codeglish-levels.md, codeglish-map.md — heuristics, levels, and concept map
- CHANGELOG.md — initialize changelog
- .gitignore — ignore plan file and local .claude state
