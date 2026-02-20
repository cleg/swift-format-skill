# swift-format Reference

## CLI Summary

**Invocation:** `swift-format [SUBCOMMAND] [OPTIONS...] [FILES...]`

### Subcommands

| Subcommand | Purpose |
|------------|---------|
| `format` (default) | Format Swift source; use `-i` to write changes in-place |
| `lint` | Report style violations; use `-s` for strict (non-zero exit on warnings) |
| `dump-configuration` | Print default config (JSON). Use `--effective` to show config from cwd |

### Key Flags (format and lint)

| Flag | Description |
|------|-------------|
| `-i`, `--in-place` | Overwrite input files (format only). No backup. |
| `-r`, `--recursive` | Process `.swift` files in listed directories |
| `-p`, `--parallel` | Process files in parallel |
| `--configuration <path>` | Use this config file instead of searching for `.swift-format` |
| `--assume-filename <path>` | Filename for diagnostics when reading from stdin |
| `--ignore-unparsable-files` | Skip files that fail to parse (no diagnostics, not formatted) |
| `--color-diagnostics` / `--no-color-diagnostics` | Force color on/off for diagnostics |

### Lint-only

| Flag | Description |
|------|-------------|
| `-s`, `--strict` | Exit with non-zero code if any lint warnings |

---

## Configuration (`.swift-format`)

- **Filename:** `.swift-format` (JSON).
- **Search order:** For each source file, swift-format looks in the file’s directory, then parent directories; the first `.swift-format` found is used.
- **Override:** `--configuration <path>` forces use of that file and skips directory search.

### Common options (summary)

| Option | Type | Description |
|--------|------|-------------|
| `version` | number | Config version; use `1` |
| `lineLength` | number | Max line length (default 100) |
| `indentation` | object | `{ "spaces": N }` or `{ "tabs": N }` (default `{ "spaces": 2 }`) |
| `tabWidth` | number | Spaces per tab for line-length (default 8) |
| `maximumBlankLines` | number | Max consecutive blank lines (default 1) |
| `spacesBeforeEndOfLineComments` | number | Spaces before `//` (default 2) |
| `respectsExistingLineBreaks` | boolean | Honor existing line breaks (default true) |
| `lineBreakBeforeControlFlowKeywords` | boolean | Break before `else`/`catch` (default false) |
| `lineBreakBeforeEachArgument` | boolean | Vertical layout for arguments (default false) |
| `lineBreakBeforeEachGenericRequirement` | boolean | Vertical layout for generic requirements (default false) |

Full options and semantics: [swift-format Documentation/Configuration.md](https://github.com/swiftlang/swift-format/blob/main/Documentation/Configuration.md).
