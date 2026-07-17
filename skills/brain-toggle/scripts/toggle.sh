#!/usr/bin/env bash
# Toggle the ~/brain second-brain interruptor.
# Usage: toggle.sh {on|off|status} [--hard]
set -euo pipefail

LOADER="$HOME/brain/LOADER.md"
POINTERS=(
  "$HOME/.claude/CLAUDE.md"
  "$HOME/.codex/AGENTS.md"
  "$HOME/AGENTS.md"
)
MARK_START="<!-- BRAIN:START -->"
MARK_END="<!-- BRAIN:END -->"
IMPORT_LINE="@~/brain/LOADER.md"

usage() {
  echo "Usage: $(basename "$0") {on|off|status} [--hard]" >&2
  exit 1
}

set_soft_status() {
  local new="$1"
  [ -f "$LOADER" ] || { echo "error: $LOADER not found" >&2; exit 1; }
  sed -i "1s/^STATUS:.*/STATUS: $new/" "$LOADER"
}

has_block() {
  grep -qF "$MARK_START" "$1" 2>/dev/null
}

remove_block() {
  local file="$1"
  has_block "$file" || return 0
  sed -i "/$MARK_START/,/$MARK_END/d" "$file"
}

insert_block() {
  local file="$1"
  touch "$file"
  has_block "$file" && return 0
  local tmp
  tmp="$(mktemp)"
  {
    printf '%s\n%s\n%s\n' "$MARK_START" "$IMPORT_LINE" "$MARK_END"
    cat "$file"
  } > "$tmp"
  mv "$tmp" "$file"
}

cmd_status() {
  local status_line
  status_line="$(head -1 "$LOADER" 2>/dev/null || echo "MISSING")"
  echo "LOADER.md: $status_line"
  for f in "${POINTERS[@]}"; do
    if has_block "$f"; then
      echo "  [hard: ON ] $f"
    else
      echo "  [hard: OFF] $f"
    fi
  done
}

cmd_on() {
  local hard="$1"
  set_soft_status "ON"
  if [ "$hard" = "true" ]; then
    for f in "${POINTERS[@]}"; do
      insert_block "$f"
    done
  fi
  cmd_status
}

cmd_off() {
  local hard="$1"
  set_soft_status "OFF"
  if [ "$hard" = "true" ]; then
    for f in "${POINTERS[@]}"; do
      remove_block "$f"
    done
  fi
  cmd_status
}

main() {
  local action="${1:-}"
  local hard="false"
  [ "${2:-}" = "--hard" ] && hard="true"

  case "$action" in
    on) cmd_on "$hard" ;;
    off) cmd_off "$hard" ;;
    status) cmd_status ;;
    *) usage ;;
  esac
}

main "$@"
