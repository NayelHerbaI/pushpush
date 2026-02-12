#!/bin/bash

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

PUSH_SWAP="./push_swap"
CHECKER="./checker_linux"

MODE="checker"      # checker | funcheck | valgrind
RANDOM_N=0
DO_PERMS=0
QUIET=0

ok() { echo -e "${GREEN}OK${RESET}"; }
ko() { echo -e "${RED}KO${RESET}"; }

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --funcheck          Run funcheck on each test (no checker validation)
  --valgrind          Run valgrind on each test and fail on any error/leak
  --random N          Add N random tests (size 0..5, mixed signs)
  --perms             Test all permutations of 5 numbers (1 2 3 4 5)
  --quiet             Less output
  -h, --help          Show this help

Default mode: checker (valid tests checked with checker_linux).
EOF
}

# -------------------------
# CLI parsing
# -------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --funcheck) MODE="funcheck"; shift ;;
    --valgrind) MODE="valgrind"; shift ;;
    --random) RANDOM_N="$2"; shift 2 ;;
    --perms) DO_PERMS=1; shift ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# -------------------------
# Helpers
# -------------------------
print_title() {
  [[ $QUIET -eq 1 ]] && return
  echo "=============================================="
  echo " push_swap boss tests | mode: $MODE"
  echo "=============================================="
}

# Expect no output at all (stdout+stderr empty)
expect_no_output() {
  local desc="$1"
  shift
  local out
  out=$("$@" 2>&1)
  printf "%-42s" "$desc"
  if [[ -z "$out" ]]; then ok; else
    ko
    [[ $QUIET -eq 1 ]] || { echo "  Expected: (no output)"; echo "  Got: $out"; }
  fi
}

# Expect "Error" on stderr (newline may be trimmed by bash), stdout empty
expect_error_stderr_only() {
  local desc="$1"
  shift
  local stdout stderr
  stdout=$("$@" 2>/tmp/ps_err.$$)
  stderr=$(cat /tmp/ps_err.$$)
  rm -f /tmp/ps_err.$$
  printf "%-42s" "$desc"

  if [[ -z "$stdout" && ( "$stderr" == "Error" || "$stderr" == $'Error\n' ) ]]; then
    ok
  else
    ko
    [[ $QUIET -eq 1 ]] || {
      echo "  Expected: stderr contains 'Error' and stdout empty"
      echo "  Got stdout: '$stdout'"
      echo "  Got stderr: '$stderr'"
    }
  fi
}

# Checker mode: expect OK
expect_checker_ok() {
  local desc="$1"
  local arg_for_ps="$2"
  local arg_for_checker="$3"

  printf "%-42s" "$desc"
  local res
  res=$(eval "$PUSH_SWAP $arg_for_ps" | eval "$CHECKER $arg_for_checker" 2>/dev/null)
  if [[ "$res" == "OK" ]]; then
    ok
  else
    ko
    [[ $QUIET -eq 1 ]] || {
      echo "  Checker says: $res"
      echo "  First ops:"
      eval "$PUSH_SWAP $arg_for_ps" 2>/dev/null | head -n 20
    }
  fi
}

# Funcheck mode: run funcheck and expect exit 0
run_funcheck() {
  local desc="$1"
  shift
  printf "%-42s" "$desc"
  funcheck "$@" >/tmp/fun_out.$$ 2>&1
  local code=$?
  if [[ $code -eq 0 ]]; then
    ok
  else
    ko
    [[ $QUIET -eq 1 ]] || { echo "  funcheck exit=$code"; head -n 40 /tmp/fun_out.$$; }
  fi
  rm -f /tmp/fun_out.$$
}

# Valgrind mode: fail on any error/leak
run_valgrind() {
  local desc="$1"
  shift
  printf "%-42s" "$desc"

  valgrind --leak-check=full --show-leak-kinds=all \
           --errors-for-leak-kinds=all --error-exitcode=42 \
           "$@" >/tmp/vg_out.$$ 2>&1
  local code=$?

  # Si valgrind a trouvé un vrai problème, il exit avec 42
  if [[ $code -eq 42 ]]; then
    ko
    [[ $QUIET -eq 1 ]] || {
      echo "  valgrind error-exitcode triggered"
      grep -nE "ERROR SUMMARY: [1-9]|definitely lost: *[1-9]|indirectly lost: *[1-9]|possibly lost: *[1-9]|Invalid read|Invalid write|Use of uninitialised|Conditional jump" /tmp/vg_out.$$ | head -n 80
    }
    rm -f /tmp/vg_out.$$
    return
  fi

  # Sinon, double-check par parsing strict (au cas où)
  if grep -qE "ERROR SUMMARY: [1-9]" /tmp/vg_out.$$ \
     || grep -qE "definitely lost: *[1-9]" /tmp/vg_out.$$ \
     || grep -qE "indirectly lost: *[1-9]" /tmp/vg_out.$$ \
     || grep -qE "possibly lost: *[1-9]" /tmp/vg_out.$$; then
    ko
    [[ $QUIET -eq 1 ]] || {
      grep -nE "ERROR SUMMARY:|definitely lost:|indirectly lost:|possibly lost:" /tmp/vg_out.$$ | head -n 80
    }
  else
    ok
  fi

  rm -f /tmp/vg_out.$$
}


# Dispatch runner for a valid test (args as one string)
run_valid_test() {
  local label="$1"
  local args="$2"
  if [[ "$MODE" == "checker" ]]; then
    expect_checker_ok "$label" "$args" "$args"
  elif [[ "$MODE" == "funcheck" ]]; then
    # run push_swap only (checker would be polluted)
    run_funcheck "$label" "$PUSH_SWAP" $args
  else
    run_valgrind "$label" "$PUSH_SWAP" $args
  fi
}

# Dispatch runner for a quoted valid test
run_valid_test_quoted() {
  local label="$1"
  local args="$2"
  if [[ "$MODE" == "checker" ]]; then
    expect_checker_ok "$label" "\"$args\"" "\"$args\""
  elif [[ "$MODE" == "funcheck" ]]; then
    run_funcheck "$label" "$PUSH_SWAP" "$args"
  else
    run_valgrind "$label" "$PUSH_SWAP" "$args"
  fi
}

# Random generator: size 0..5, unique ints, mix negatives
gen_random_args() {
  local n=$((RANDOM % 6))
  if [[ $n -eq 0 ]]; then echo ""; return; fi

  # generate unique numbers from -50..50 (excluding duplicates)
  local arr=()
  while [[ ${#arr[@]} -lt $n ]]; do
    local v=$((RANDOM % 101 - 50))
    local dup=0
    for x in "${arr[@]}"; do [[ "$x" == "$v" ]] && dup=1; done
    [[ $dup -eq 0 ]] && arr+=("$v")
  done
  echo "${arr[*]}"
}

# All permutations of "1 2 3 4 5" (120)
run_perms_5() {
  local base=(1 2 3 4 5)
  local count=0

  permute() {
    local -n arr_ref=$1
    local l=$2

    if [[ $l -eq ${#arr_ref[@]} ]]; then
      local args="${arr_ref[*]}"
      run_valid_test "Perm5 #$count (no quotes)" "$args"
      run_valid_test_quoted "Perm5 #$count (quotes)" "$args"
      count=$((count+1))
      return
    fi

    local i tmp
    for ((i=l; i<${#arr_ref[@]}; i++)); do
      tmp=${arr_ref[l]}; arr_ref[l]=${arr_ref[i]}; arr_ref[i]=$tmp
      permute base $((l+1))          # <-- IMPORTANT: base, pas arr_ref
      tmp=${arr_ref[l]}; arr_ref[l]=${arr_ref[i]}; arr_ref[i]=$tmp
    done
  }

  permute base 0
}


# -------------------------
# Run tests
# -------------------------
print_title

# Basics about expected behavior
expect_no_output "No args: ./push_swap" "$PUSH_SWAP"

# Error cases (only meaningful in checker mode OR for stderr behavior)
# In funcheck/valgrind mode we still can check that it errors, but we focus on memory; keep anyway.
expect_error_stderr_only 'Empty string: ./push_swap ""' "$PUSH_SWAP" ""
expect_error_stderr_only 'Spaces: ./push_swap "   "' "$PUSH_SWAP" "   "
expect_error_stderr_only 'Invalid: ./push_swap "1 a 2"' "$PUSH_SWAP" "1 a 2"
expect_error_stderr_only 'Dup: ./push_swap "1 2 2"' "$PUSH_SWAP" "1 2 2"
expect_error_stderr_only 'Overflow: ./push_swap "2147483648"' "$PUSH_SWAP" "2147483648"
expect_error_stderr_only 'Minus alone: ./push_swap "-"' "$PUSH_SWAP" "-"

[[ $QUIET -eq 1 ]] || echo "----------------------------------------------"
[[ $QUIET -eq 1 ]] || echo "Valid cases"

valid_tests=(
  "1"
  "2 1"
  "3 2 1"
  "90 -123 12"
  "5 4 3 2 1"
  "5 2 1 3 4"
)

for ARG in "${valid_tests[@]}"; do
  run_valid_test        "Valid (no quotes): $ARG" "$ARG"
  run_valid_test_quoted "Valid (quotes):    $ARG" "$ARG"
done

# Optional: all permutations of 5
if [[ $DO_PERMS -eq 1 ]]; then
  [[ $QUIET -eq 1 ]] || echo "----------------------------------------------"
  [[ $QUIET -eq 1 ]] || echo "Permutations of 5 (1..5)"
  run_perms_5
fi

# Optional: random tests
if [[ $RANDOM_N -gt 0 ]]; then
  [[ $QUIET -eq 1 ]] || echo "----------------------------------------------"
  [[ $QUIET -eq 1 ]] || echo "Random tests: $RANDOM_N"
  for ((k=1; k<=RANDOM_N; k++)); do
    ARG=$(gen_random_args)
    if [[ -z "$ARG" ]]; then
      expect_no_output "Random #$k (no args)" "$PUSH_SWAP"
      continue
    fi
    run_valid_test        "Random #$k (no quotes)" "$ARG"
    run_valid_test_quoted "Random #$k (quotes)" "$ARG"
  done
fi

[[ $QUIET -eq 1 ]] || echo "=============================================="
[[ $QUIET -eq 1 ]] || echo "Done."
[[ $QUIET -eq 1 ]] || echo "=============================================="
