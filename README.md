# Swift-Format AI Skill

A universal AI coding skill that teaches any AI assistant (Cursor, Claude Code, and others) to use [swift-format](https://github.com/swiftlang/swift-format) to automatically format Swift source code and fix style/lint issues.

## What This Does

When the instructions are available to the assistant, it will:

- Detect the project's indentation style (tabs/spaces, width) before touching any files — from `.editorconfig`, `.xcodeproj`, Xcode user defaults, or source file inspection — and refuse to format if a mismatch would silently reformat the whole codebase
- Use the `swift-format` CLI to format Swift files in-place or run lint checks
- Respect project configuration (`.swift-format` in the repo)
- Apply the right flags (`-i`, `-r`, `-p`, `-s`) for formatting vs linting and for CI vs interactive use
- Format only git-changed files when working in a large existing codebase
- Run in safe mode with a conservative temporary config to minimise diff noise on first-time formatting

Use it when you want the assistant to "format my Swift code", "fix swift-format lint issues", or keep Swift files consistently formatted while editing.

## Installing / Using the Skill

### Cursor

**Option A — User skills (all projects):**
```bash
cp -r skills/swift-format ~/.cursor/skills/swift-format
```

**Option B — Project skill:**
Copy the `skills/swift-format` folder into your project at `.cursor/skills/swift-format`.

### Claude Code (and other AI coding tools)

Make the skill instructions available to Claude Code so it knows how to run swift-format:

- **CLAUDE.md:** Paste or reference the contents of [SKILL.md](skills/swift-format/SKILL.md) into your project’s `CLAUDE.md` (or `.claude/CLAUDE.md`). Claude Code reads this file automatically on every session, so the formatting workflow is always active.
- **Project docs:** Add `skills/swift-format/` (or a copy) to your repo so Claude can read it on demand (e.g. `@skills/swift-format/SKILL.md`).
- **One-shot:** You can say: “Use swift-format to format Swift files; run `swift-format format -i -r .` from the project root, or use the instructions in `skills/swift-format/SKILL.md`.”

The instructions in `SKILL.md` are written to be agent-agnostic: any assistant with terminal access can follow them.

### Install swift-format (required for all)

The instructions assume `swift-format` is available. Install it in one of these ways:

- **Swift 6+ / Xcode 16:** Included in the toolchain. Run `swift format` or use the binary from `xcrun --find swift-format`.
- **Homebrew:** `brew install swift-format`
- **From source:** See [swift-format — Getting swift-format](https://github.com/swiftlang/swift-format#getting-swift-format)

## Repository Layout

```
swift-format-skill/
├── README.md           # This file
├── LICENSE             # Apache-2.0
├── .gitignore
├── skills/
│   └── swift-format/   # Universal skill (Cursor, Claude Code, etc.)
│       ├── SKILL.md    # Main instructions for any AI assistant
│       ├── reference.md
│       └── examples.md
└── scripts/
    ├── detect-indentation.sh   # Detects tabs/spaces style for a Swift project
    └── format-in-place.sh      # Optional wrapper for in-place formatting
```

## Optional scripts

### detect-indentation.sh

Detects the indentation style (tabs or spaces, and width) of a Swift project by checking `.editorconfig`, `.xcodeproj/project.pbxproj`, Xcode user defaults, and source files — in that order.

```bash
./scripts/detect-indentation.sh              # human-readable summary
./scripts/detect-indentation.sh --swift-format   # prints only the JSON value for .swift-format
./scripts/detect-indentation.sh [DIR]        # search from a specific directory
```

### format-in-place.sh

Formats Swift files in-place using swift-format. With no arguments it formats the current directory recursively; with paths it formats those files or directories.

```bash
./scripts/format-in-place.sh [PATH...]
```

Both scripts require `swift-format` on your PATH (or available via `xcrun`).

## License

Apache-2.0. See [LICENSE](LICENSE).

## Links

- [swift-format on GitHub](https://github.com/swiftlang/swift-format)
- [swift-format configuration docs](https://github.com/swiftlang/swift-format/blob/main/Documentation/Configuration.md)
