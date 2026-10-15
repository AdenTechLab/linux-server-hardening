#!/usr/bin/env bash

set -u

SCRIPT="scripts/security-audit.sh"
PASS=0
FAIL=0
TEMP_OUTPUT=$(mktemp)

cleanup() {
    rm -f "$TEMP_OUTPUT"
}
trap cleanup EXIT

check() {
    local description="$1"
    shift

    if "$@"; then
        echo "[PASS] $description"
        PASS=$((PASS + 1))
    else
        echo "[FAIL] $description"
        FAIL=$((FAIL + 1))
    fi
}

echo "Linux Server Hardening - Automated Tests"
echo "========================================"

check "Audit script exists" test -f "$SCRIPT"
check "Audit script is readable" test -r "$SCRIPT"
check "Audit script has a Bash shebang" \
    grep -q '^#!/usr/bin/env bash' "$SCRIPT"
check "Audit script passes syntax validation" \
    bash -n "$SCRIPT"

echo
echo "Running audit script..."

if bash "$SCRIPT" > "$TEMP_OUTPUT" 2>&1; then
    check "Audit script executes successfully" true
else
    check "Audit script executes successfully" false
fi

check "Audit output contains a summary" \
    grep -q -- "---- Summary ----" "$TEMP_OUTPUT"

check "Audit output contains PASS, FAIL and REVIEW counts" \
    grep -Eq 'PASS: [0-9]+' "$TEMP_OUTPUT" &&
    grep -Eq 'FAIL: [0-9]+' "$TEMP_OUTPUT" &&
    grep -Eq 'REVIEW: [0-9]+' "$TEMP_OUTPUT"

echo
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi