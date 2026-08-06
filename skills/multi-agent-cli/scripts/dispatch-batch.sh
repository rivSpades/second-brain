#!/usr/bin/env bash
# Dispatch several independent tasks in parallel via dispatch.sh, aggregate results.
# Usage: dispatch-batch.sh --cwd <path> --task <id>:<prompt> [--task <id>:<prompt> ...] [--simulate] [--timeout <seconds>]
#
# Each --task runs as its own dispatch.sh in the background; all share the same
# batch timestamp prefix (but each gets its own run dir), mirroring the
# ~/brain/.multi-agent-cli/<ts>-<hash8>/ convention used for single dispatches.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DISPATCH="$SCRIPT_DIR/dispatch.sh"
BRAIN_DIR="$HOME/brain"
RUNS_DIR="$BRAIN_DIR/.multi-agent-cli"

usage() {
  cat >&2 <<'EOF'
Usage: dispatch-batch.sh --cwd <path> --task <id>:<prompt> [--task <id>:<prompt> ...] [--simulate] [--timeout <seconds>]

Launches each --task in parallel via dispatch.sh, all sharing the same batch
timestamp prefix. Prints the path to _batch-summary.json on completion.
Exit code is non-zero if any task ended up simulated or errored.
EOF
}

CWD="$PWD"
FORCE_SIMULATE="false"
TIMEOUT_S=""
declare -a PAIRS=()

while [ $# -gt 0 ]; do
  case "$1" in
    --cwd) CWD="${2:-}"; shift 2 ;;
    --task) PAIRS+=("${2:-}"); shift 2 ;;
    --simulate) FORCE_SIMULATE="true"; shift ;;
    --timeout) TIMEOUT_S="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "unknown arg: $1" >&2; usage; exit 1 ;;
  esac
done

if [ "${#PAIRS[@]}" -eq 0 ]; then
  usage
  exit 1
fi

if [ ! -d "$CWD" ]; then
  echo "cwd inválido: $CWD" >&2
  exit 1
fi

declare -a EXTRA_ARGS=()
[ "$FORCE_SIMULATE" = "true" ] && EXTRA_ARGS+=(--simulate)
[ -n "$TIMEOUT_S" ] && EXTRA_ARGS+=(--timeout "$TIMEOUT_S")

TS="$(date +%Y%m%d-%H%M%S)"
BATCH_DIR="$RUNS_DIR/${TS}-batch"
mkdir -p "$BATCH_DIR"

declare -a TASK_IDS=()
declare -a OUT_FILES=()
declare -a PIDS=()

idx=0
for pair in "${PAIRS[@]}"; do
  tid="${pair%%:*}"
  prompt="${pair#*:}"
  if [ "$tid" = "$pair" ]; then
    echo "formato inválido (esperado id:prompt): $pair" >&2
    exit 1
  fi
  out_file="$BATCH_DIR/_task-${idx}.out"
  TASK_IDS+=("$tid")
  OUT_FILES+=("$out_file")
  (
    result_path="$("$DISPATCH" --task "$tid" --prompt "$prompt" --cwd "$CWD" --batch-ts "$TS" "${EXTRA_ARGS[@]}")"
    ec=$?
    printf '%s' "$result_path" > "$out_file"
    exit "$ec"
  ) &
  PIDS+=("$!")
  idx=$((idx + 1))
done

declare -a ECS=()
for pid in "${PIDS[@]}"; do
  wait "$pid"
  ECS+=("$?")
done

declare -a TASK_JSONS=()
overall_ec=0
for i in "${!TASK_IDS[@]}"; do
  tid="${TASK_IDS[$i]}"
  ec="${ECS[$i]}"
  [ "$ec" -ne 0 ] && overall_ec=1
  result_path="$(cat "${OUT_FILES[$i]}" 2>/dev/null || true)"
  if [ -n "$result_path" ] && [ -f "$result_path" ]; then
    obj="$(jq -c --arg task_id "$tid" --argjson dispatch_exit_code "$ec" \
      '{task_id:$task_id, dispatch_exit_code:$dispatch_exit_code, result_file:.result_file,
        status:.status, cli:.cli, model:.model, fallback:.fallback, simulated:.simulated}' \
      "$result_path")"
  else
    overall_ec=1
    obj="$(jq -c -n --arg task_id "$tid" --argjson dispatch_exit_code "$ec" \
      '{task_id:$task_id, dispatch_exit_code:$dispatch_exit_code, result_file:null, status:"no_result_file"}')"
  fi
  TASK_JSONS+=("$obj")
done

SUMMARY_FILE="$BATCH_DIR/_batch-summary.json"
printf '%s\n' "${TASK_JSONS[@]}" | jq -s --arg batch_ts "$TS" --arg cwd "$CWD" \
  '{batch_ts:$batch_ts, cwd:$cwd, tasks:.}' > "$SUMMARY_FILE"

echo "$SUMMARY_FILE"
exit "$overall_ec"
