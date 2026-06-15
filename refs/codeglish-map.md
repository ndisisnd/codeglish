---
name: Language Map
description: Maps file extensions to canonical programming language names, and self-extends — an unrecognised extension found during a scan is named and appended to the map. Used during codeglish --init to classify files found in the codebase.
type: reference
---

## Extension to language mapping

One extension per row. When a file matches multiple rows (e.g. `.ts` and `.tsx`), use the more specific match first.

| Extension(s) | Language |
|--------------|---------|
| `.py`, `.pyw`, `.pyx` | Python |
| `.ts`, `.tsx` | TypeScript |
| `.js`, `.mjs`, `.cjs`, `.jsx` | JavaScript |
| `.go` | Go |
| `.rs` | Rust |
| `.java` | Java |
| `.kt`, `.kts` | Kotlin |
| `.swift` | Swift |
| `.rb`, `.erb` | Ruby |
| `.php` | PHP |
| `.cs` | C# |
| `.cpp`, `.cc`, `.cxx`, `.c++` | C++ |
| `.c`, `.h` | C |
| `.m`, `.mm` | Objective-C |
| `.scala` | Scala |
| `.hs`, `.lhs` | Haskell |
| `.ex`, `.exs` | Elixir |
| `.erl`, `.hrl` | Erlang |
| `.clj`, `.cljs`, `.cljc` | Clojure |
| `.r`, `.R` | R |
| `.jl` | Julia |
| `.lua` | Lua |
| `.sh`, `.bash`, `.zsh` | Shell |
| `.ps1`, `.psm1` | PowerShell |
| `.sql` | SQL |
| `.tf`, `.tfvars` | Terraform (HCL) |
| `.yaml`, `.yml` | YAML |
| `.json` | JSON |
| `.toml` | TOML |
| `.md`, `.mdx` | Markdown |
| `.html`, `.htm` | HTML |
| `.css`, `.scss`, `.sass`, `.less` | CSS |
| `.vue` | Vue |
| `.svelte` | Svelte |
| `.dart` | Dart |
| `.zig` | Zig |

## Exclusion rules

Skip these extensions during codebase scanning — they are not programming languages:

| Extension(s) | Reason |
|--------------|--------|
| `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.ico`, `.webp` | Images |
| `.ttf`, `.woff`, `.woff2`, `.eot` | Fonts |
| `.mp4`, `.mp3`, `.wav`, `.mov` | Media |
| `.zip`, `.tar`, `.gz`, `.bz2` | Archives |
| `.lock` | Lock files (yarn.lock, package-lock.json, etc.) |
| `.min.js`, `.min.css` | Minified build artifacts |
| `.d.ts` | TypeScript declaration files — count toward TypeScript, not a separate language |
| `.map` | Source maps |
| `.env`, `.env.*` | Environment config |

## Noise threshold

After counting files per language, discard any language with fewer than 2 matching files. Single-file appearances are likely vendored code or boilerplate, not the user's actual working language.

## Unmapped extensions

A file whose extension is in neither the mapping table nor the exclusion rules is *unmapped*. Do not silently drop it — learn it instead:

1. Group the unmapped extensions and count files per extension. Apply the same noise threshold: ignore any unmapped extension with fewer than 2 files.
2. For each remaining unmapped extension, settle on a language name — infer it when the extension is well-known, otherwise ask the user: "Found N `.ext` files I don't recognise. What language is this? (name it, or skip)".
3. For each extension the user names (or confirms the inferred name for), append a new row to the **Extension to language mapping** table above — `` `.ext` | <Language> `` — and write this file back so the mapping persists for every future scan.
4. Treat each newly named language exactly like a built-in one for the rest of the scan (counting, sorting, noise threshold).

An extension the user chooses to skip is dropped for this scan only and is *not* added to the exclusion rules. Extensionless files (e.g. `Makefile`) have no extension to key on and are skipped unless the user explicitly asks to track them by full filename.

Example: a scan turns up `schema.proto` and `events.proto`. `.proto` is unmapped and has 2 files (meets the threshold), so Codeglish asks and the user answers "Protocol Buffers". A new row `` `.proto` | Protocol Buffers `` is appended to the mapping table, the file is saved, and Protocol Buffers joins the scan results.

## Worked example

Given these files in a codebase:
```
src/main.py
src/utils.py
src/api.ts
src/types.ts
src/components/Button.tsx
tests/test_main.py
Makefile
README.md
.env
```

Step 1 — Extract extensions and map:
- `.py` → Python (3 files: main.py, utils.py, test_main.py)
- `.ts` → TypeScript (2 files: api.ts, types.ts)
- `.tsx` → TypeScript (1 file: Button.tsx; merged with `.ts` count → 3 total)
- `Makefile` → no extension → skip
- `.md` → Markdown (1 file → below noise threshold → discard)
- `.env` → excluded

Step 2 — Apply noise threshold (≥2 files):
- Python: 3 files ✓
- TypeScript: 3 files ✓

Step 3 — Result: `["Python", "TypeScript"]` sorted by file count descending.
