#!/usr/bin/env bash
# Format Swift files in-place using swift-format.
# Usage: format-in-place.sh [PATH...]
#   No paths: format current directory recursively.
#   With paths: format those files or directories (directories processed recursively).

set -e

SWIFT_FORMAT=
if command -v xcrun &>/dev/null; then
  SWIFT_FORMAT=$(xcrun --find swift-format 2>/dev/null || true)
fi
if [[ -z "$SWIFT_FORMAT" ]]; then
  SWIFT_FORMAT=$(command -v swift-format 2>/dev/null || true)
fi
if [[ -z "$SWIFT_FORMAT" ]]; then
  echo "error: swift-format not found. Install via Xcode (Swift 6+), Homebrew (brew install swift-format), or build from source." >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  exec "$SWIFT_FORMAT" format -i -r -p .
fi

# With paths: allow directories (use -r so dirs are processed recursively)
exec "$SWIFT_FORMAT" format -i -r -p "$@"
