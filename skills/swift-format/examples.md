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

## Configuration

**Print default configuration (JSON):**
```bash
swift-format dump-configuration
```

**Print effective configuration from current directory:**
```bash
swift-format dump-configuration --effective
```

Redirect to create a project config: `swift-format dump-configuration > .swift-format`, then edit as needed.
