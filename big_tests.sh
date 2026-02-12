#!/bin/bash
set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
RESET="\033[0m"

PUSH_SWAP="${PUSH_SWAP:-./push_swap}"
CHECKER="${CHECKER:-./checker_linux}"

MODE="checker"        # checker | funcheck | valgrind
ITER=50               # tests per size
SIZES="6,10,20,50,100,200,300,500,700,1000"
MINV=-1000000
MAXV=1000000
QUIET=0

# Benchmarks (subject)
BENCH_100_MAX=699     # "fewer than 700" :contentReference[oaicite:4]{index=4}
BENCH_500_MAX=5500    # "no more than 5500" :contentReference[oaicite:5]{index=5}
RUN_BENCH=1

ok(){ echo -e "${GREEN}OK${RESET}"; }
ko(){ echo -e "${RED}KO${RESET}"; }

usage(){
  cat <<EOF
Usage: $0 [options]

Options:
  --checker             Validate with checker (default)
  --funcheck            Run funcheck on push_swap
  --valgrind            Run valgrind on push_swap
  --iter N              Tests per size (default: $ITER)
  --sizes "a,b,c"       Sizes list (default: $SIZES)
  --range MIN MAX       Random values range (default: $MINV..$MAXV)
  --no-bench            Disable benchmark block (100/500 thresholds)
  --quiet               Less output
  -h, --help            Help

Env override:
  PUSH_SWAP=./push_swap
  CHECKER=./checker_linux
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --checker) MODE="checker"; shift ;;
    --funcheck) MODE="funcheck"; shift ;;
    --valgrind) MODE="valgrind"; shift ;;
    --iter) ITER="$2"; shift 2 ;;
    --sizes) SIZES="$2"; shift 2 ;;
    --range) MINV="$2"; MAXV="$3"; shift 3 ;;
    --no-bench) RUN_BENCH=0; shift ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

[[ -x "$PUSH_SWAP" ]] || { echo "push_swap not found/executable: $PUSH_SWAP"; exit 1; }
if [[ "$MODE" == "checker" ]]; then
  [[ -x "$CHECKER" ]] || { echo "checker not found/executable: $CHECKER"; exit 1; }
fi

# -------------------------
# Unique random generator (no shuf)
# -------------------------
gen_unique_args() {
  local n="$1"
  local -A seen=()
  local arr=()
  local span=$((MAXV - MINV + 1))
  [[ $span -gt 0 ]] || { echo "Bad range: $MINV..$MAXV" >&2; exit 1; }

  while [[ ${#arr[@]} -lt "$n" ]]; do
    local r=$(( (RANDOM << 15) | RANDOM ))  # ~0..1e9
    local v=$(( MINV + (r % span) ))
    if [[ -z "${seen[$v]+x}" ]]; then
      seen[$v]=1
      arr+=("$v")
    fi
  done
  echo "${arr[*]}"
}

# -------------------------
# Output validator:
# - Only allowed instructions (subject list) :contentReference[oaicite:6]{index=6}
# - One instruction per line, nothing else :contentReference[oaicite:7]{index=7}
# -------------------------
validate_ops_format() {
  local ops="$1"
  # Empty is fine (already sorted) :contentReference[oaicite:8]{index=8}
  [[ -z "$ops" ]] && return 0

  # Reject any CR (Windows line endings), tabs, spaces at line ends, etc.
  if printf "%s" "$ops" | grep -q $'\r'; then return 1; fi

  # Each line must match exactly one instruction
  if ! printf "%s\n" "$ops" | grep -Eq '^(sa|sb|ss|pa|pb|ra|rb|rr|rra|rrb|rrr)$' ; then
    return 1
  fi

  # Ensure there is no extra whitespace (exact match already enforces this)
  return 0
}

# -------------------------
# Runners
# -------------------------
run_checker_one() {
  local args_str="$1"

  # split string to array for official usage: ./push_swap $ARG | ./checker $ARG :contentReference[oaicite:9]{index=9}
  # shellcheck disable=SC2206
  local args=( $args_str )

  local ops res
  ops=$("$PUSH_SWAP" "${args[@]}" 2>/dev/null)

  if ! validate_ops_format "$ops"; then
    echo -e "${RED}KO${RESET} invalid ops format"
    [[ $QUIET -eq 1 ]] || {
      echo "Args: ${args[*]}"
      echo "First output lines:"
      printf "%s\n" "$ops" | head -n 30
    }
    return 1
  fi

  res=$(printf "%s\n" "$ops" | "$CHECKER" "${args[@]}" 2>/dev/null || true)
  if [[ "$res" != "OK" ]]; then
    echo -e "${RED}KO${RESET} checker != OK"
    [[ $QUIET -eq 1 ]] || {
      echo "Args: ${args[*]}"
      echo "Checker: $res"
      echo "First ops:"
      printf "%s\n" "$ops" | head -n 30
    }
    return 1
  fi

  # number of operations
  printf "%s\n" "$ops" | wc -l | tr -d ' '
}

run_funcheck_one() {
  local args_str="$1"
  # shellcheck disable=SC2086
  funcheck "$PUSH_SWAP" $args_str >/tmp/fc_out.$$ 2>&1 || {
    echo -e "${RED}KO${RESET} funcheck failed"
    [[ $QUIET -eq 1 ]] || { echo "Args: $args_str"; head -n 80 /tmp/fc_out.$$; }
    rm -f /tmp/fc_out.$$
    return 1
  }
  rm -f /tmp/fc_out.$$
  echo 0
}

run_valgrind_one() {
  local args_str="$1"
  # shellcheck disable=SC2086
  valgrind --leak-check=full --show-leak-kinds=all \
           --errors-for-leak-kinds=all --error-exitcode=42 \
           "$PUSH_SWAP" $args_str >/tmp/vg_out.$$ 2>&1
  local code=$?
  if [[ $code -eq 42 ]]; then
    echo -e "${RED}KO${RESET} valgrind error"
    [[ $QUIET -eq 1 ]] || {
      echo "Args: $args_str"
      grep -nE "ERROR SUMMARY: [1-9]|definitely lost: *[1-9]|indirectly lost: *[1-9]|possibly lost: *[1-9]|Invalid read|Invalid write|Use of uninitialised|Conditional jump" /tmp/vg_out.$$ | head -n 120
    }
    rm -f /tmp/vg_out.$$
    return 1
  fi
  rm -f /tmp/vg_out.$$
  echo 0
}

run_one() {
  local args_str="$1"
  if [[ "$MODE" == "checker" ]]; then
    run_checker_one "$args_str"
  elif [[ "$MODE" == "funcheck" ]]; then
    run_funcheck_one "$args_str"
  else
    run_valgrind_one "$args_str"
  fi
}

# -------------------------
# Benchmarks block (subject) :contentReference[oaicite:10]{index=10}
# -------------------------
run_benchmark() {
  [[ "$MODE" != "checker" ]] && return 0

  echo -e "\n=============================================="
  echo " Benchmarks (subject thresholds)"
  echo "  - 100 numbers: < 700 ops"
  echo "  - 500 numbers: <= 5500 ops"
  echo "=============================================="

  bench_case() {
    local n="$1"
    local max_ops="$2"
    local label="$3"
    local args
    args="$(gen_unique_args "$n")"
    local ops_count
    ops_count="$(run_checker_one "$args")" || return 1

    printf "%-26s ops=%-6s limit=%s  " "$label" "$ops_count" "$max_ops"
    if [[ "$ops_count" -le "$max_ops" ]]; then
      ok
    else
      echo -e "${RED}KO${RESET}"
      [[ $QUIET -eq 1 ]] || echo "  (Above threshold)"
      return 1
    fi
  }

  local bench_fail=0
  bench_case 100 "$BENCH_100_MAX" "Benchmark 100" || bench_fail=1
  bench_case 500 "$BENCH_500_MAX" "Benchmark 500" || bench_fail=1

  return $bench_fail
}

# -------------------------
# Run
# -------------------------
[[ $QUIET -eq 1 ]] || {
  echo "============================================================"
  echo " push_swap stress | mode=$MODE | iter=$ITER"
  echo " sizes=[$SIZES] range=${MINV}..${MAXV}"
  echo "============================================================"
}

IFS=',' read -r -a SIZE_ARR <<< "$SIZES"

TOTAL=0
FAIL=0

for n in "${SIZE_ARR[@]}"; do
  [[ $QUIET -eq 1 ]] || echo -e "\n--- Size $n ($ITER tests) ---"
  local_min=""
  local_max=0
  local_sum=0
  local_ok=0

  for ((t=1; t<=ITER; t++)); do
    args="$(gen_unique_args "$n")"
    TOTAL=$((TOTAL+1))

    [[ $QUIET -eq 1 ]] || printf "Test %4d/%d: " "$t" "$ITER"

    if out_ops="$(run_one "$args")"; then
      local_ok=$((local_ok+1))
      if [[ "$MODE" == "checker" ]]; then
        local_sum=$((local_sum + out_ops))
        [[ -z "$local_min" || "$out_ops" -lt "$local_min" ]] && local_min="$out_ops"
        [[ "$out_ops" -gt "$local_max" ]] && local_max="$out_ops"
        [[ $QUIET -eq 1 ]] || echo -e "${GREEN}OK${RESET} ops=$out_ops"
      else
        [[ $QUIET -eq 1 ]] || ok
      fi
    else
      FAIL=$((FAIL+1))
      [[ $QUIET -eq 1 ]] || echo -e "${RED}KO${RESET}"
    fi
  done

  if [[ "$MODE" == "checker" ]]; then
    avg=0
    [[ $local_ok -gt 0 ]] && avg=$((local_sum / local_ok))
    echo "Size $n: OK=$local_ok/$ITER | ops min=${local_min:-N/A} max=$local_max avg=$avg"
  else
    echo "Size $n: OK=$local_ok/$ITER"
  fi
done

if [[ $RUN_BENCH -eq 1 ]]; then
  run_benchmark || FAIL=$((FAIL+1))
fi

echo -e "\n============================================================"
echo "Done. Total tests=$TOTAL | Failures=$FAIL"
echo "============================================================"
exit $((FAIL == 0 ? 0 : 1))
