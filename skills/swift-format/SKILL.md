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

## Configuration

- swift-format looks for a JSON file named `.swift-format` in the same directory as each source file, then in parent directories. Use the project's existing config; do not pass `--configuration` unless the user requests an override.
- To inspect config: `swift-format dump-configuration` (defaults) or `swift-format dump-configuration --effective` (effective config from current directory).
- For config options (lineLength, indentation, etc.), see [reference.md](reference.md).

## Optional Script

If the repository includes `scripts/format-in-place.sh`, run it to format paths in-place with consistent flags. Otherwise, invoke `swift-format format -i` (and optionally `-r`, `-p`) directly as above.

## Additional Resources

- [swift-format on GitHub](https://github.com/swiftlang/swift-format)
- [reference.md](reference.md) — CLI flags and configuration summary
- [examples.md](examples.md) — Example commands and scenarios
