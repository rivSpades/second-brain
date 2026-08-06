#!/usr/bin/env bash
# Toggle the multi-agent-cli orchestrator on/off.
# Usage: toggle.sh {on|off|status}
set -euo pipefail

STATUS_FILE="$HOME/brain/.multi-agent-cli-status"

usage() {
  echo "Usage: $(basename "$0") {on|off|status}" >&2
  exit 1
}

cmd_status() {
  local status
  status="$(cat "$STATUS_FILE" 2>/dev/null || echo "MISSING")"
  echo "multi-agent-cli: $status"
  echo "  status file: $STATUS_FILE"
}

set_status() {
  local new="$1"
  printf '%s\n' "$new" > "$STATUS_FILE"
  cmd_status
}

main() {
  local action="${1:-}"

  case "$action" in
    on) set_status "ON" ;;
    off) set_status "OFF" ;;
    status) cmd_status ;;
    *) usage ;;
  esac
}

main "$@"
