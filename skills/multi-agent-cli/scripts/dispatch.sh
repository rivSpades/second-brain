#!/usr/bin/env bash
# Dispatch a single task to the CLI/model mapped for it in tasks.json.
# Usage: dispatch.sh --task <task_id> --prompt "<text>" [--cwd <path>] [--simulate] [--timeout <seconds>] [--batch-ts <timestamp>]
#
# Deliberately NOT using `set -e`: several lines below use the
# `[ cond ] && { ...; return 1; }` idiom, which trips `set -e` when the test
# is false (classic bash gotcha). Errors are handled explicitly instead.
set -uo pipefail

BRAIN_DIR="$HOME/brain"
STATUS_FILE="$BRAIN_DIR/.multi-agent-cli-status"
TASKS_JSON="$BRAIN_DIR/skills/multi-agent-cli/tasks.json"
RUNS_DIR="$BRAIN_DIR/.multi-agent-cli"
DEFAULT_TIMEOUT=600

usage() {
  cat >&2 <<'EOF'
Usage: dispatch.sh --task <task_id> --prompt "<text>" [--cwd <path>] [--simulate] [--timeout <seconds>] [--batch-ts <timestamp>]

task_id must exist in tasks.json (~/brain/skills/multi-agent-cli/tasks.json).
Prints the result_file path (JSON) to stdout on completion.
EOF
}

TASK_ID=""
PROMPT=""
CWD="$PWD"
FORCE_SIMULATE="false"
TIMEOUT_S="$DEFAULT_TIMEOUT"
BATCH_TS=""

while [ $# -gt 0 ]; do
  case "$1" in
    --task) TASK_ID="${2:-}"; shift 2 ;;
    --prompt) PROMPT="${2:-}"; shift 2 ;;
    --cwd) CWD="${2:-}"; shift 2 ;;
    --simulate) FORCE_SIMULATE="true"; shift ;;
    --timeout) TIMEOUT_S="${2:-}"; shift 2 ;;
    --batch-ts) BATCH_TS="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [ -z "$TASK_ID" ] || [ -z "$PROMPT" ]; then
  usage
  exit 1
fi

if [ ! -d "$CWD" ]; then
  echo "cwd inválido: $CWD" >&2
  exit 1
fi

status="$(tr -d '[:space:]' < "$STATUS_FILE" 2>/dev/null || echo "MISSING")"
if [ "$status" != "ON" ]; then
  echo "multi-agent-cli está OFF ($STATUS_FILE) — executa a task na sessão actual em vez de despachar." >&2
  exit 2
fi

if [ ! -f "$TASKS_JSON" ]; then
  echo "tasks.json não encontrado: $TASKS_JSON" >&2
  exit 3
fi

TASK_JSON="$(jq -c --arg id "$TASK_ID" '.tasks[] | select(.id==$id)' "$TASKS_JSON")"
if [ -z "$TASK_JSON" ]; then
  echo "task_id desconhecido em tasks.json: $TASK_ID" >&2
  echo "ids disponíveis: $(jq -r '.tasks[].id' "$TASKS_JSON" | tr '\n' ' ')" >&2
  exit 3
fi

WRITE_MODE="$(echo "$TASK_JSON" | jq -r '.write_mode')"
PRI_CLI="$(echo "$TASK_JSON" | jq -r '.primary.cli')"
PRI_MODEL="$(echo "$TASK_JSON" | jq -r '.primary.model')"
PRI_SLUG="$(echo "$TASK_JSON" | jq -r '.primary.slug')"
PRI_VARIANT="$(echo "$TASK_JSON" | jq -r '.primary.variant // empty')"
HAS_FALLBACK="$(echo "$TASK_JSON" | jq -r 'if .fallback == null then "false" else "true" end')"
FB_CLI=""; FB_MODEL=""; FB_SLUG=""; FB_VARIANT=""
if [ "$HAS_FALLBACK" = "true" ]; then
  FB_CLI="$(echo "$TASK_JSON" | jq -r '.fallback.cli')"
  FB_MODEL="$(echo "$TASK_JSON" | jq -r '.fallback.model')"
  FB_SLUG="$(echo "$TASK_JSON" | jq -r '.fallback.slug')"
  FB_VARIANT="$(echo "$TASK_JSON" | jq -r '.fallback.variant // empty')"
fi

mkdir -p "$RUNS_DIR"
TS="${BATCH_TS:-$(date +%Y%m%d-%H%M%S)}"
HASH8="$(head -c4 /dev/urandom | od -An -tx1 | tr -d ' \n')"
RUN_DIR="$RUNS_DIR/${TS}-${HASH8}"
mkdir -p "$RUN_DIR"
RESULT_FILE="$RUN_DIR/${TASK_ID}.json"

# Globals populated by try_cli(): ATTEMPT_STATUS ATTEMPT_EXIT ATTEMPT_STDOUT
# ATTEMPT_STDERR ATTEMPT_BINARY ATTEMPT_CMD_JSON ATTEMPT_DURATION
try_cli() {
  local cli="$1" model="$2" slug="$3" variant="$4"
  local binary=""
  local -a cmd=()

  case "$cli" in
    opencode)
      binary="$(command -v opencode || true)"
      if [ -z "$binary" ]; then ATTEMPT_STATUS="missing_binary"; return 1; fi
      cmd=("$binary" run -m "$slug")
      if [ -n "$variant" ]; then cmd+=(--variant "$variant"); fi
      cmd+=(--dir "$CWD")
      if [ "$WRITE_MODE" = "workspace" ]; then cmd+=(--auto); fi
      cmd+=("$PROMPT")
      ;;
    claude)
      binary="$(command -v claude || true)"
      if [ -z "$binary" ]; then ATTEMPT_STATUS="missing_binary"; return 1; fi
      cmd=("$binary" -p --model "$slug")
      if [ "$WRITE_MODE" = "workspace" ]; then cmd+=(--dangerously-skip-permissions); fi
      cmd+=("$PROMPT")
      ;;
    cursor-agent)
      binary="$(command -v cursor-agent || true)"
      if [ -z "$binary" ]; then ATTEMPT_STATUS="missing_binary"; return 1; fi
      cmd=("$binary" -p --model "$slug" --workspace "$CWD" --output-format text)
      if [ "$WRITE_MODE" = "workspace" ]; then cmd+=(--force); fi
      cmd+=("$PROMPT")
      ;;
    *)
      ATTEMPT_STATUS="unknown_cli"
      return 1
      ;;
  esac

  local -a cmd_display=("${cmd[@]}")
  cmd_display[-1]="<prompt>"
  local cmd_json_tmp
  cmd_json_tmp="$(jq -c -n --args '$ARGS.positional' -- "${cmd_display[@]}")"

  local out err ec start end
  out="$(mktemp)"; err="$(mktemp)"
  start="$(date +%s.%N)"
  # Always run cd'd into $CWD (claude has no --dir/--workspace flag of its own).
  if timeout "${TIMEOUT_S}s" bash -c 'cd "$1" && shift && exec "$@"' bash "$CWD" "${cmd[@]}" >"$out" 2>"$err"; then
    ec=0
  else
    ec=$?
  fi
  end="$(date +%s.%N)"

  ATTEMPT_BINARY="$binary"
  ATTEMPT_CMD_JSON="$cmd_json_tmp"
  ATTEMPT_STDOUT="$(cat "$out")"
  ATTEMPT_STDERR="$(cat "$err")"
  ATTEMPT_EXIT="$ec"
  ATTEMPT_DURATION="$(awk -v s="$start" -v e="$end" 'BEGIN{printf "%.3f", e-s}')"
  rm -f "$out" "$err"

  if [ "$ec" -eq 0 ]; then
    ATTEMPT_STATUS="ok"
    return 0
  fi
  ATTEMPT_STATUS="error"
  return 1
}

write_result() {
  local status="$1" cli="$2" model="$3" fallback_used="$4" simulated="$5"
  jq -n \
    --arg task_id "$TASK_ID" \
    --arg cli "$cli" \
    --arg model "$model" \
    --arg status "$status" \
    --argjson exit_code "${ATTEMPT_EXIT:-null}" \
    --arg stdout "${ATTEMPT_STDOUT:-}" \
    --arg stderr "${ATTEMPT_STDERR:-}" \
    --argjson fallback "$fallback_used" \
    --argjson simulated "$simulated" \
    --arg binary "${ATTEMPT_BINARY:-}" \
    --argjson command "${ATTEMPT_CMD_JSON:-[]}" \
    --argjson duration_seconds "${ATTEMPT_DURATION:-0}" \
    --arg result_file "$RESULT_FILE" \
    '{task_id:$task_id, cli:$cli, model:$model, status:$status, exit_code:$exit_code,
      stdout:$stdout, stderr:$stderr, fallback:$fallback, simulated:$simulated,
      binary:$binary, command:$command, duration_seconds:$duration_seconds,
      result_file:$result_file}' \
    > "$RESULT_FILE"
}

run_simulated() {
  local reason="$1"
  ATTEMPT_BINARY="/bin/echo"
  ATTEMPT_CMD_JSON='["/bin/echo","<simulated>"]'
  ATTEMPT_STDOUT="$(/bin/echo "[SIMULATED — $reason] $PROMPT")"
  ATTEMPT_STDERR=""
  ATTEMPT_EXIT=0
  ATTEMPT_DURATION="0"
  write_result "simulated" "$PRI_CLI" "$PRI_MODEL" "false" "true"
}

if [ "$FORCE_SIMULATE" = "true" ]; then
  run_simulated "modo --simulate explícito"
  echo "$RESULT_FILE"
  exit 0
fi

if try_cli "$PRI_CLI" "$PRI_MODEL" "$PRI_SLUG" "$PRI_VARIANT"; then
  write_result "ok" "$PRI_CLI" "$PRI_MODEL" "false" "false"
  echo "$RESULT_FILE"
  exit 0
fi
PRI_ATTEMPT_STATUS="$ATTEMPT_STATUS"

if [ "$HAS_FALLBACK" = "true" ]; then
  if try_cli "$FB_CLI" "$FB_MODEL" "$FB_SLUG" "$FB_VARIANT"; then
    write_result "ok" "$FB_CLI" "$FB_MODEL" "true" "false"
    echo "$RESULT_FILE"
    exit 0
  fi
fi

if [ "$HAS_FALLBACK" = "true" ]; then
  run_simulated "primário $PRI_CLI/$PRI_MODEL ($PRI_ATTEMPT_STATUS) e alternativa $FB_CLI/$FB_MODEL ($ATTEMPT_STATUS) falharam"
else
  run_simulated "primário $PRI_CLI/$PRI_MODEL ($PRI_ATTEMPT_STATUS) falhou, sem alternativa configurada"
fi
echo "$RESULT_FILE"
exit 1
