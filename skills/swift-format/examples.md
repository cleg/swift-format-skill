# swift-format Examples

## Format

**Format all Swift files under current directory (in-place):**
```bash
swift-format format -i -r .
```

**Format a single file:**
```bash
swift-format format -i path/to/File.swift
```

**Format with parallel processing:**
```bash
swift-format format -i -p -r .
```

**Format using a specific config file:**
```bash
swift-format format -i --configuration .swift-format path/to/File.swift
```

## Lint

**Lint current directory recursively:**
```bash
swift-format lint -r .
```

**Lint with strict exit code (e.g. CI):**
```bash
swift-format lint -s -r .
```

**Lint but skip unparsable files:**
```bash
swift-format lint -r --ignore-unparsable-files .
```

## Format Changed Files Only

**Format files changed since last commit (useful in pre-commit hooks):**
```bash
git diff --name-only --diff-filter=ACM HEAD | grep '\.swift$' | xargs swift-format format -i
```

**Format only staged files:**
```bash
git diff --cached --name-only --diff-filter=ACM | grep '\.swift$' | xargs swift-format format -i
```

## Configuration

**Print default configuration (JSON):**
```bash
swift-format dump-configuration
```

**Print effective configuration from current directory:**
```bash
swift-format dump-configuration --effective
```

**Create a project config file:**
```bash
swift-format dump-configuration > .swift-format
```

Then edit `.swift-format` as needed.
