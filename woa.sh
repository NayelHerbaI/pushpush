#!/bin/bash
set -euo pipefail

GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

PUSH_SWAP="${PUSH_SWAP:-./push_swap}"
CHECKER="${CHECKER:-./checker_linux}"

MODE="checker"     # checker | funcheck | valgrind
QUIET=0
FUZZ_N=200
VALID_N=200

MINV=-1000000
MAXV=1000000

ok(){ echo -e "${GREEN}OK${RESET}"; }
ko(){ echo -e "${RED}KO${RESET}"; }

usage(){
  cat <<EOF
Usage: $0 [options]
  --checker             Validate with checker (default)
  --funcheck            Run funcheck (no checker validation)
  --valgrind            Run valgrind (slow)
  --fuzz N              Number of fuzz invalid tests (default: $FUZZ_N)
  --valid N             Number of random valid tests (default: $VALID_N)
  --range MIN MAX       Range for random valid values (default: $MINV..$MAXV)
  --quiet               Less output
  -h, --help            Help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --checker) MODE="checker"; shift ;;
    --funcheck) MODE="funcheck"; shift ;;
    --valgrind) MODE="valgrind"; shift ;;
    --fuzz) FUZZ_N="$2"; shift 2 ;;
    --valid) VALID_N="$2"; shift 2 ;;
    --range) MINV="$2"; MAXV="$3"; shift 3 ;;
    --quiet) QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

[[ -x "$PUSH_SWAP" ]] || { echo "push_swap not found/executable: $PUSH_SWAP"; exit 1; }
if [[ "$MODE" == "checker" ]]; then
  [[ -x "$CHECKER" ]] || { echo "checker not found/executable: $CHECKER"; exit 1; }
fi

# ---------------------------------------
# Random unique args (no shuf dependency)
# ---------------------------------------
gen_unique_args() {
  local n="$1"
  local -A seen=()
  local arr=()

  local span=$((MAXV - MINV + 1))
  if [[ $span -le 0 ]]; then
    echo "Bad range: $MINV..$MAXV" >&2
    exit 1
  fi

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

# ---------------------------------------
# Normalize whitespace string -> tokens
# (Only to feed checker properly)
# ---------------------------------------
normalize_to_tokens() {
  local s="$1"
  # Convert tabs/newlines to spaces, squeeze spaces, trim.
  printf "%b" "$s" | tr '\t\n\r' '   ' | tr -s ' ' | sed 's/^ *//; s/ *$//'
}

# ---------------------------------------
# Error expectation (push_swap only)
# Subject: "Error\n" on stderr, stdout empty :contentReference[oaicite:4]{index=4}
# ---------------------------------------
expect_error_stderr_only() {
  local desc="$1"
  local input="$2"
  local stdout stderr

  stdout=$("$PUSH_SWAP" "$input" 2>/tmp/ps_err.$$ || true)
  stderr=$(cat /tmp/ps_err.$$ || true)
  rm -f /tmp/ps_err.$$

  printf "%-62s" "$desc"
  if [[ -z "$stdout" && ( "$stderr" == "Error" || "$stderr" == $'Error\n' ) ]]; then
    ok
    return 0
  fi
  ko
  [[ $QUIET -eq 1 ]] || {
    echo "  Input: [$input]"
    echo "  Expected: stderr='Error' and stdout empty"
    echo "  Got stdout: '$stdout'"
    echo "  Got stderr: '$stderr'"
  }
  return 1
}

# ---------------------------------------
# Official checker usage (split args)
# ARG="4 67 3"; ./push_swap $ARG | ./checker_linux $ARG :contentReference[oaicite:5]{index=5}
# ---------------------------------------
expect_checker_ok_split() {
  local desc="$1"
  shift
  printf "%-62s" "$desc"

  local ops res
  ops=$("$PUSH_SWAP" "$@" 2>/dev/null)
  res=$(printf "%s\n" "$ops" | "$CHECKER" "$@" 2>/dev/null || true)

  if [[ "$res" == "OK" ]]; then
    ok
    return 0
  fi
  ko
  [[ $QUIET -eq 1 ]] || {
    echo "  Args: [$*]"
    echo "  Checker: $res"
    echo "  First ops:"
    printf "%s\n" "$ops" | head -n 30
  }
  return 1
}

# ---------------------------------------
# Quoted input to push_swap (single argv),
# but checker gets split tokens (like $ARG non-quoted).
# This matches your parser behavior + checker expectations.
# ---------------------------------------
expect_checker_ok_singlearg() {
  local desc="$1"
  local input="$2"
  printf "%-62s" "$desc"

  local norm
  norm="$(normalize_to_tokens "$input")"
  if [[ -z "$norm" ]]; then
    ko
    [[ $QUIET -eq 1 ]] || echo "  Normalized tokens empty for: [$input]"
    return 1
  fi

  # shellcheck disable=SC2206
  local tokens=( $norm )

  # Capture stdout and stderr of push_swap separately
  local ops err res
  ops=$("$PUSH_SWAP" "$input" 2>/tmp/ps_single_err.$$ || true)
  err=$(cat /tmp/ps_single_err.$$ || true)
  rm -f /tmp/ps_single_err.$$

  res=$(printf "%s\n" "$ops" | "$CHECKER" "${tokens[@]}" 2>/tmp/ck_single_err.$$ || true)
  local ckerr
  ckerr=$(cat /tmp/ck_single_err.$$ || true)
  rm -f /tmp/ck_single_err.$$

  if [[ "$res" == "OK" ]]; then
    ok
    return 0
  fi

  ko
  [[ $QUIET -eq 1 ]] || {
    echo "  Raw input: [$input]"
    echo "  Tokens to checker: [${tokens[*]}]"
    echo "  push_swap stdout (ops):"
    printf "%s\n" "$ops" | head -n 30
    echo "  push_swap stderr:"
    printf "%s\n" "$err" | head -n 10
    echo "  checker stdout:"
    printf "%s\n" "$res" | head -n 10
    echo "  checker stderr:"
    printf "%s\n" "$ckerr" | head -n 10
  }
  return 1
}


# ---------------------------------------
# Funcheck / Valgrind runners (optional)
# ---------------------------------------
run_funcheck_singlearg() {
  local desc="$1"; local input="$2"
  printf "%-62s" "$desc"
  funcheck "$PUSH_SWAP" "$input" >/tmp/fc_out.$$ 2>&1 || {
    ko
    [[ $QUIET -eq 1 ]] || { echo "  Input: [$input]"; head -n 80 /tmp/fc_out.$$; }
    rm -f /tmp/fc_out.$$
    return 1
  }
  rm -f /tmp/fc_out.$$
  ok
  return 0
}

run_valgrind_singlearg() {
  local desc="$1"; local input="$2"
  printf "%-62s" "$desc"
  valgrind --leak-check=full --show-leak-kinds=all \
           --errors-for-leak-kinds=all --error-exitcode=42 \
           "$PUSH_SWAP" "$input" >/tmp/vg_out.$$ 2>&1
  local code=$?
  if [[ $code -eq 42 ]]; then
    ko
    [[ $QUIET -eq 1 ]] || {
      echo "  Input: [$input]"
      grep -nE "ERROR SUMMARY: [1-9]|definitely lost: *[1-9]|indirectly lost: *[1-9]|possibly lost: *[1-9]|Invalid read|Invalid write|Use of uninitialised|Conditional jump" /tmp/vg_out.$$ | head -n 120
    }
    rm -f /tmp/vg_out.$$
    return 1
  fi
  rm -f /tmp/vg_out.$$
  ok
  return 0
}

# ---------------------------------------
# Fuzz generators
# ---------------------------------------
rand_int() { echo $((RANDOM % 2000000 - 1000000)); }

gen_weird_token() {
  local patterns=(
    "" " " "   " "\t" "\n"
    "-" "+" "--1" "++1" "+-1" "-+1"
    "000" "0001" "-000" "+000"
    "1a" "a1" "1_2" "0x10" "NaN"
    "2147483648" "-2147483649"
    "999999999999999999999" "-999999999999999999999"
    "$(rand_int)"
    "$((RANDOM % 1000))"
  )
  printf "%b" "${patterns[$((RANDOM % ${#patterns[@]}))]}"
}

gen_fuzz_argstring() {
  local k=$((RANDOM % 20 + 1))
  local s=""
  for ((i=0; i<k; i++)); do
    local tok sep
    tok="$(gen_weird_token)"
    sep=" "
    [[ $((RANDOM % 4)) -eq 0 ]] && sep=$'\t'
    [[ $((RANDOM % 25)) -eq 0 ]] && sep=$'\n'
    s+="${tok}${sep}"
  done
  echo "$s" | sed 's/[[:space:]]*$//'
}

# ---------------------------------------
# Run tests
# ---------------------------------------
FAIL=0
TOTAL=0

echo "============================================================"
echo " woa.sh | mode=$MODE | fuzz=$FUZZ_N | valid=$VALID_N"
echo "============================================================"

# Inputs that MUST error (single-arg mode)
INVALIDS=(
  "" " " "   " $'\t' $'\n'
  "-" "+" "--" "++" "+-" "-+"
  "1 2 2" "0 +0" "0 -0" "000 0" "-000 0"
  "2147483648" "-2147483649"
  "999999999999999999999"
  "-999999999999999999999"
  "1 a 2" "01 1" "+1 1" "-1 -01"
)

echo "--- Fixed invalid parsing cases (expect Error) ---"
for s in "${INVALIDS[@]}"; do
  TOTAL=$((TOTAL+1))
  if ! expect_error_stderr_only "Invalid (single arg): \"$s\"" "$s"; then
    FAIL=$((FAIL+1))
  fi
done

# Valid parsing strings (single-arg to push_swap)
# These are VALID per your parser choice (spaces/tabs/newlines)
VALID_SINGLEARG=(
  "1  2   3"
  "  1 2 3  "
  "1 2 3 "
  " 1 2 3"
  $'1\t2\t3'
  $'  \t 1 \t 2 \t 3 \t  '
  $'1\n2\n3'
  "1        2       3"
  "          1       2       3        "
)

echo -e "\n--- Fixed VALID parsing cases (expect OK) ---"
for s in "${VALID_SINGLEARG[@]}"; do
  TOTAL=$((TOTAL+1))
  if [[ "$MODE" == "checker" ]]; then
    if ! expect_checker_ok_singlearg "Valid (single arg): \"$s\"" "$s"; then
      FAIL=$((FAIL+1))
    fi
  elif [[ "$MODE" == "funcheck" ]]; then
    if ! run_funcheck_singlearg "Valid funcheck (single arg)" "$s"; then
      FAIL=$((FAIL+1))
    fi
  else
    if ! run_valgrind_singlearg "Valid valgrind (single arg)" "$s"; then
      FAIL=$((FAIL+1))
    fi
  fi
done

echo -e "\n--- Fuzz invalids (expect Error) ---"
for ((i=1; i<=FUZZ_N; i++)); do
  TOTAL=$((TOTAL+1))
  fuzz="$(gen_fuzz_argstring)"
  if ! expect_error_stderr_only "Fuzz invalid #$i" "$fuzz"; then
    echo "  Fuzz string was: [$fuzz]"
    FAIL=$((FAIL+1))
  fi
done

echo -e "\n--- Random valid tests (official checker usage: split args) ---"
for ((i=1; i<=VALID_N; i++)); do
  n=$((RANDOM % 995 + 6)) # 6..1000
  args="$(gen_unique_args "$n")"
  TOTAL=$((TOTAL+1))

  # shellcheck disable=SC2206
  arr=( $args )

  if [[ "$MODE" == "checker" ]]; then
    if ! expect_checker_ok_split "Valid random #$i (n=$n)" "${arr[@]}"; then
      FAIL=$((FAIL+1))
    fi
  elif [[ "$MODE" == "funcheck" ]]; then
    printf "%-62s" "Valid funcheck #$i (n=$n)"
    # shellcheck disable=SC2086
    funcheck "$PUSH_SWAP" $args >/tmp/fc_out.$$ 2>&1 || { ko; [[ $QUIET -eq 1 ]] || head -n 80 /tmp/fc_out.$$; rm -f /tmp/fc_out.$$; FAIL=$((FAIL+1)); continue; }
    rm -f /tmp/fc_out.$$
    ok
  else
    printf "%-62s" "Valid valgrind #$i (n=$n)"
    # shellcheck disable=SC2086
    valgrind --leak-check=full --show-leak-kinds=all \
             --errors-for-leak-kinds=all --error-exitcode=42 \
             "$PUSH_SWAP" $args >/tmp/vg_out.$$ 2>&1
    code=$?
    if [[ $code -eq 42 ]]; then
      ko
      [[ $QUIET -eq 1 ]] || grep -nE "ERROR SUMMARY: [1-9]|definitely lost: *[1-9]|indirectly lost: *[1-9]|possibly lost: *[1-9]|Invalid read|Invalid write|Use of uninitialised|Conditional jump" /tmp/vg_out.$$ | head -n 120
      rm -f /tmp/vg_out.$$
      FAIL=$((FAIL+1))
    else
      rm -f /tmp/vg_out.$$
      ok
    fi
  fi
done

echo "============================================================"
echo "Done. Total=$TOTAL | Failures=$FAIL"
echo "============================================================"
exit $((FAIL == 0 ? 0 : 1))
