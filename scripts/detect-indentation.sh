#!/usr/bin/env bash
# Detect indentation style (tabs/spaces and width) for a Swift project.
# Checks sources in priority order:
#   1. .editorconfig  (Swift-specific sections only)
#   2. .xcodeproj/project.pbxproj
#   3. Xcode user defaults (macOS only)
#   4. First .swift source file found
#
# Usage: detect-indentation.sh [--swift-format] [DIR]
#   --swift-format  Print only the swift-format "indentation" JSON value
#   DIR             Root directory to search (default: current directory)
#
# Exit 0 if detected; exit 1 if style could not be determined.

set -euo pipefail

SWIFT_FORMAT_MODE=0
ROOT="."

while [[ $# -gt 0 ]]; do
  case "$1" in
    --swift-format) SWIFT_FORMAT_MODE=1; shift ;;
    -*) echo "error: unknown flag '$1'" >&2; exit 1 ;;
    *) ROOT="$1"; shift ;;
  esac
done

# Emit result and exit 0.
# Args: <style: tabs|spaces> <width: number> <source: description>
emit() {
  local style="$1" width="$2" source="$3"
  local json
  if [[ "$style" == "tabs" ]]; then
    json='{ "tabs": 1 }'
  else
    json="{ \"spaces\": $width }"
  fi

  if [[ "$SWIFT_FORMAT_MODE" -eq 1 ]]; then
    echo "$json"
  else
    echo "source:     $source"
    echo "style:      $style"
    echo "width:      $width"
    echo "swift-format \"indentation\": $json"
  fi
  exit 0
}

# ── 1. .editorconfig ────────────────────────────────────────────────────────
# Only reads settings from sections that match Swift files: [*], [*.swift], or
# any glob starting with * that contains "swift" (e.g. [*.{swift,objc}]).
# Per the editorconfig spec, later matching sections override earlier ones,
# so we scan the whole file and keep the last value seen in a matching section.
editorconfig="$ROOT/.editorconfig"
if [[ -f "$editorconfig" ]]; then
  ec_style=$(awk '
    /^\[/ {
      s = $0; gsub(/^\[|\].*/, "", s)
      in_section = (s == "*" || s == "*.swift" || \
                    (substr(s, 1, 1) == "*" && index(s, "swift") > 0))
    }
    in_section && /^[[:space:]]*indent_style[[:space:]]*=/ {
      v = $0; gsub(/^[^=]*=[[:space:]]*/, "", v); gsub(/[[:space:]]*$/, "", v)
      result = v
    }
    END { print result }
  ' "$editorconfig") || ec_style=""

  ec_size=$(awk '
    /^\[/ {
      s = $0; gsub(/^\[|\].*/, "", s)
      in_section = (s == "*" || s == "*.swift" || \
                    (substr(s, 1, 1) == "*" && index(s, "swift") > 0))
    }
    in_section && /^[[:space:]]*indent_size[[:space:]]*=/ {
      v = $0; gsub(/^[^=]*=[[:space:]]*/, "", v); gsub(/[[:space:]]*$/, "", v)
      result = v
    }
    END { print result }
  ' "$editorconfig") || ec_size=""

  if [[ "$ec_style" == "tab" ]]; then
    emit "tabs" "1" ".editorconfig"
  elif [[ "$ec_style" == "space" && -n "$ec_size" ]]; then
    emit "spaces" "$ec_size" ".editorconfig"
  fi
fi

# ── 2. .xcodeproj/project.pbxproj ───────────────────────────────────────────
# Use || true inside the subshell: when find returns multiple results, head -1
# closes the pipe early and find gets SIGPIPE (exit 141). With pipefail this
# would make the pipeline non-zero; || true inside ensures the captured value
# is kept rather than overwritten by an outer || var="" fallback.
pbxproj=$(find "$ROOT" -maxdepth 2 -name "project.pbxproj" 2>/dev/null \
          | head -1 || true)
if [[ -n "$pbxproj" ]]; then
  pb_tabs=$(grep -m1 'usesTabs' "$pbxproj" 2>/dev/null \
            | grep -o '[0-9]' | head -1 || true)
  pb_width=$(grep -m1 'indentWidth' "$pbxproj" 2>/dev/null \
             | grep -o '[0-9]*' | head -1 || true)
  if [[ "$pb_tabs" == "1" ]]; then
    emit "tabs" "1" "$pbxproj"
  elif [[ "$pb_tabs" == "0" && -n "$pb_width" ]]; then
    emit "spaces" "$pb_width" "$pbxproj"
  fi
fi

# ── 3. Xcode user defaults (macOS only) ─────────────────────────────────────
if command -v defaults &>/dev/null; then
  xc_tabs=$(defaults read com.apple.dt.Xcode DVTTextIndentUsingTabs 2>/dev/null) || xc_tabs=""
  xc_width=$(defaults read com.apple.dt.Xcode DVTTextIndentWidth 2>/dev/null) || xc_width=""
  if [[ "$xc_tabs" == "1" ]]; then
    emit "tabs" "1" "Xcode user defaults"
  elif [[ "$xc_tabs" == "0" && -n "$xc_width" ]]; then
    emit "spaces" "$xc_width" "Xcode user defaults"
  fi
fi

# ── 4. First .swift source file ─────────────────────────────────────────────
swift_file=$(find "$ROOT" \
  -name "*.swift" \
  -not -path "*/.build/*" \
  -not -path "*/build/*" \
  -not -path "*/.git/*" \
  -not -path "*/DerivedData/*" \
  2>/dev/null | head -1 || true)

if [[ -n "$swift_file" ]]; then
  tab_count=$(grep -c $'^\t' "$swift_file" 2>/dev/null) || tab_count=0
  if [[ "$tab_count" -gt 0 ]]; then
    emit "tabs" "1" "$swift_file"
  else
    space_width=$(grep -m1 '^ ' "$swift_file" 2>/dev/null \
                  | sed 's/[^ ].*//' | awk '{print length($0)}') || space_width=""
    if [[ -n "$space_width" && "$space_width" -gt 0 ]]; then
      emit "spaces" "$space_width" "$swift_file"
    fi
  fi
fi

echo "error: could not determine indentation style from any source." >&2
exit 1
