---
name: swift-format
description: Uses the swift-format CLI to format Swift source code and fix style/lint issues. Use when the user asks to format Swift code, fix lint or style issues, run swift-format, or when modifying Swift files and consistent formatting is expected (e.g. project has .swift-format or CI uses swift-format). Works with Cursor, Claude Code, and any AI coding assistant with terminal access.
---

# Swift-Format

Universal instructions for using [swift-format](https://github.com/swiftlang/swift-format) to format and lint Swift code. Apply these steps regardless of which AI coding environment you run in (Cursor, Claude Code, etc.).

## When to Use

Apply these instructions when:

- The user asks to format Swift code, fix style/lint issues, or "run swift-format".
- You are modifying or reviewing Swift files and should apply consistent formatting.
- The project expects swift-format (e.g. `.swift-format` in the repo or CI runs swift-format).
- You are running swiftlint to validate files and getting formatting-related errors (line is too long, inconsistent spaces, etc.)

## Prerequisites

Discover the `swift-format` binary before running it, in this order:

1. **Toolchain (preferred):** `xcrun --find swift-format` (returns path to standalone binary).
2. **PATH fallback:** `which swift-format` (e.g. Homebrew: `brew install swift-format`).
3. **Swift subcommand (Swift 6+ / Xcode 16+):** `swift format` — invoke as `swift format -i …` instead of `swift-format format -i …`.

If not found, inform the user how to install (toolchain, Homebrew, or build from [swift-format](https://github.com/swiftlang/swift-format)).

If the binary is found via `xcrun` but is not on `PATH`, substitute its full path for `swift-format` in all commands below.

## Pre-Flight: Check Indentation Before Formatting

**Always do this before running `swift-format format -i`.**

### 1. Check for a project config

```bash
# Search up to 3 levels deep from the repo root
find . -maxdepth 3 -name ".swift-format" | head -5
```

- If `.swift-format` is found, swift-format will use it — proceed to format.
- If **no config is found**, continue to step 2.

### 2. Detect the indentation style

When no `.swift-format` exists, swift-format falls back to its built-in default: `{ "spaces": 2 }`. Check the project's actual style to see whether that would conflict.

**If `scripts/detect-indentation.sh` is available**, run it from the repo root — it checks all sources below automatically and prints a ready-to-paste swift-format value:

```bash
scripts/detect-indentation.sh            # human-readable summary
scripts/detect-indentation.sh --swift-format   # prints only the JSON value
```

**Otherwise**, check sources in this order and stop at the first one that gives a definitive answer.

**a) `.editorconfig` — reliable cross-tool signal**

```bash
grep -E '^\s*(indent_style|indent_size)\s*=' .editorconfig 2>/dev/null
```

Xcode 16+ reads `.editorconfig` to drive its own editor. swift-format does **not** read it directly, but its presence is a strong signal of the project's intended style. `indent_style = tab` / `indent_style = space` and `indent_size` map to swift-format's `indentation` key.

**b) Xcode project file (`.pbxproj`) — per-project setting**

```bash
grep -E 'usesTabs|indentWidth|tabWidth' *.xcodeproj/project.pbxproj 2>/dev/null | head -10
```

Look for `usesTabs = 1` (tabs) or `indentWidth = 4` (spaces, where 4 is the width). These are written by Xcode when indentation is set via **File Inspector → Text Settings** on the project node.

**c) Global Xcode user defaults — user's machine-wide setting**

```bash
defaults read com.apple.dt.Xcode 2>/dev/null | grep -i indent
```

Relevant keys (user-level, not project-level):

| Key | Meaning |
|-----|---------|
| `DVTTextIndentWidth` | Indent width in spaces |
| `DVTTextIndentTabWidth` | Tab stop width |
| `DVTTextIndentUsingTabs` | `1` = tabs, `0` = spaces |

**d) Fallback: inspect a representative source file**

If none of the above yields a result:

```bash
# Tabs? (non-zero means tabs are used)
grep -c $'^\t' path/to/File.swift

# How many leading spaces on the first indented line?
grep -m1 '^ ' path/to/File.swift | sed 's/[^ ].*//' | awk '{print length($0)}'
```

### 3. Act on the result

When no `.swift-format` exists, the effective indentation is always `{ "spaces": 2 }` (swift-format default).

| Situation | Action |
|-----------|--------|
| `.swift-format` exists | Proceed — config governs formatting. |
| No config; project already uses 2-space indentation | Proceed, but note to the user that defaults are being applied. |
| No config; **mismatch detected** (e.g. project uses tabs or 4 spaces) | **Stop.** Warn the user that formatting will change indentation. Offer to create a `.swift-format` that preserves the current style (`swift-format dump-configuration > .swift-format`, then edit `indentation` to match), or ask for explicit confirmation before reformatting. |

## Format In-Place

To fix formatting by overwriting files (no backup):

```bash
swift-format format -i [FILES...]
```

- **Single file:** `swift-format format -i path/to/File.swift`
- **Directory (recursive):** `swift-format format -i -r .` (processes all `.swift` files under current directory)
- **Parallel (faster on many files):** add `-p` or `--parallel`
- **Custom config:** `--configuration /path/to/.swift-format` (only when overriding project config)

**Important:** `-i`/`--in-place` overwrites files without backup. Use only when the user or context expects in-place fixes.

After formatting, confirm success to the user and note any files that failed to parse.

## Lint Only

To report style violations without changing files:

```bash
swift-format lint [FILES...]
```

- Use `-r` for recursive directories, `-p` for parallel.
- Use `-s`/`--strict` when lint failures should cause a non-zero exit (e.g. CI).
- Use `--ignore-unparsable-files` to skip files that fail to parse (e.g. generated or partial sources).

## Create or Bootstrap a Config

If the project has no `.swift-format`, offer to create one instead of relying on defaults.

**Bootstrap from defaults:**

```bash
swift-format dump-configuration > .swift-format
```

This writes the full default config as JSON. Edit the relevant keys before committing.

**Bootstrap matching the current file's indentation style:**

1. Detect current style (tabs or spaces, and width) as described in the Pre-Flight section.
2. Dump defaults and patch `indentation`:
   ```bash
   swift-format dump-configuration > .swift-format
   ```
3. Edit `.swift-format` — set `indentation` to match:
   - Tabs: `"indentation": { "tabs": 1 }`
   - 4 spaces: `"indentation": { "spaces": 4 }`
4. Commit `.swift-format` so the whole team benefits.

## Format Selectively (Git-Changed Files Only)

Prefer this when formatting a large existing codebase where you don't want to reformat untouched files.

**Files changed since last commit:**

```bash
swift_files=$(git diff --name-only --diff-filter=ACM HEAD | grep '\.swift$' || true)
[ -n "$swift_files" ] && echo "$swift_files" | xargs swift-format format -i
```

**Only staged files (useful in pre-commit hooks):**

```bash
swift_files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' || true)
[ -n "$swift_files" ] && echo "$swift_files" | xargs swift-format format -i
```

Apply the same pre-flight indentation check before running either of these.

## Safe Mode (Minimal Reformatting)

swift-format has no built-in safe mode — the formatter always applies all transformations. However, you can minimise collateral changes by running with a temporary conservative config.

**What a conservative config still fixes** (low-risk, broadly desirable):
- Spacing around operators, colons, commas, and punctuation
- Excess blank lines (above `maximumBlankLines`)
- Indentation normalised to the detected style (no style change, just consistency)

**What it suppresses** (high-risk for large diffs):
- Line rewrapping (by setting `lineLength` very high)
- Structural reformatting of control flow and argument lists

### Steps

1. **Detect current indentation** using the Pre-Flight steps above.
2. **Write a temporary conservative config:**

```bash
swift-format dump-configuration > /tmp/.swift-format-safe
```

`dump-configuration` writes the full config. Within that file, change these specific keys (adjust `indentation` to match the detected style — do not replace the whole file with this snippet):

```json
"lineLength": 9999,
"indentation": { "spaces": 4 },
"respectsExistingLineBreaks": true,
"lineBreakBeforeControlFlowKeywords": false,
"lineBreakBeforeEachArgument": false,
"lineBreakBeforeEachGenericRequirement": false
```

3. **Stash uncommitted work if any, then run with the temporary config:**

```bash
# Only stash if there is something to save
[ -n "$(git status --porcelain)" ] && git stash push -m "safe-mode-pre"
swift-format format -i --configuration /tmp/.swift-format-safe [FILES...]
```

4. **Review the diff before committing:**

```bash
git diff
```

Confirm the changes are limited to spacing and blank lines. If anything unexpected changed, discard the formatting and restore the stash:

```bash
git restore .
git stash list | grep -q "safe-mode-pre" && git stash pop
```

> **Note:** The temporary config is intentionally not committed. It is only used for this one-off cleanup pass. If you want these settings as the project standard, create a permanent `.swift-format` instead (see "Create or Bootstrap a Config" above).

## Configuration

- swift-format looks for a JSON file named `.swift-format` in the same directory as each source file, then in parent directories. Use the project's existing config; do not pass `--configuration` unless the user requests an override.
- To inspect config: `swift-format dump-configuration` (defaults) or `swift-format dump-configuration --effective` (effective config from current directory).
- For config options (lineLength, indentation, etc.), see [reference.md](reference.md).

## Optional Script

Complete the Pre-Flight indentation check before running the script — it does not perform this check itself.

If the repository includes `scripts/format-in-place.sh`, run it to format paths in-place with consistent flags. Otherwise, invoke `swift-format format -i` (and optionally `-r`, `-p`) directly as above.

## Additional Resources

- [swift-format on GitHub](https://github.com/swiftlang/swift-format)
- [reference.md](reference.md) — CLI flags and configuration summary
- [examples.md](examples.md) — Example commands and scenarios
