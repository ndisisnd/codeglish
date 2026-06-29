<div align="center">

<img src="./asset/readme.jpg">

# 🧠 Codeglish 🧠

_I'm in too deep to ask what my code does..._

Created after vibe-coding a little too long and no longer able to understand what the LLM has written, `codeglish` is a skill that slows down cognitive atrophy by assisting in learning about written code and understanding why they do what they do.

It comes with it's own simple leveling system to ensure that explanations are scaling proportionally to your exposure to code.

</div>

## ⚒️ Installation

```bash
git clone https://github.com/andychan/codeglish
cd codeglish && bash install.sh
```

Copies the skill into `~/.claude/skills/codeglish/`. Run `/codeglish` in any Claude Code session to start.

---

## How it works

1. **Paste or point** — give it a diff, snippet, file path, or PRD inline or via a flag.
2. **Scores complexity** — rates input on seven tiers (Trivial → Intricate) and structures the output accordingly.
3. **Adapts to your level** — tracks XP per language across sessions; explanations deepen as you level up (12 levels).
4. **Plain English out** — writes the explanation, awards XP, and notifies you on level-up.

Run `--init` once per project to set your starting level. Use `--help` if you're not sure which mode to pick.

---

## Commands

| Command | What it does |
|---------|-------------|
| `/codeglish <input>` | Translate a diff, snippet, PRD, or plan pasted inline |
| `/codeglish <file>` | Translate a whole file (`.ts`, `.py`, `.go`, `.md`, etc.) |
| `/codeglish --comments <file>` | Insert plain-English comments above every function and class |
| `/codeglish --architecture [path]` | Scan every code file and write `codeglish-architecture.md` |
| `/codeglish --override <level>` | Pin explanations to a specific level (1–12 or name) without touching XP |
| `/codeglish --init` | One-time setup wizard — sets your starting level for this project |
| `/codeglish --help` | Triage wizard — describes modes and launches the right one |
| `/codeglish --reset exp` | Wipe all saved XP |
| `/codeglish --reset override` | Clear the active level override |

Natural-language triggers also work — "explain this", "what changed", "simplify", "map out this codebase", etc.

---

_Dedicated to the love of my life, JC, for creating so much wonder despite her non-engineering background._