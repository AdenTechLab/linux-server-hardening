#!/usr/bin/env bash

set -u

SCRIPT="scripts/security-audit.sh"
PASS=0
FAIL=0

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
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
