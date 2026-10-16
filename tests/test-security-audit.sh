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

    check "Audit output includes SSH security checks" \
    grep -q -- "---- SSH Security Checks ----" "$TEMP_OUTPUT"
      
    check "Audit output includes sensitive file permission checks" \
    grep -q -- "---- Sensitive File Permission Checks ----" "$TEMP_OUTPUT"

check "Audit checks /etc/passwd permissions" \
    grep -q "/etc/passwd:" "$TEMP_OUTPUT"

check "Audit checks /etc/shadow permissions" \
    grep -q "/etc/shadow:" "$TEMP_OUTPUT"

check "Audit checks SSH configuration permissions" \
    grep -q "/etc/ssh/sshd_config:" "$TEMP_OUTPUT"

check "Audit output contains PASS, FAIL and REVIEW counts" \
    grep -Eq 'PASS: [0-9]+' "$TEMP_OUTPUT" &&
    grep -Eq 'FAIL: [0-9]+' "$TEMP_OUTPUT" &&
    grep -Eq 'REVIEW: [0-9]+' "$TEMP_OUTPUT"

echo

# Set up mock SSH commands for controlled tests.
MOCK_BIN=$(mktemp -d)

cat > "$MOCK_BIN/sshd" <<'MOCK_SSHD'
#!/usr/bin/env bash

if [ "${MOCK_SSHD_FAIL:-0}" = "1" ]; then
    exit 1
fi

printf 'permitrootlogin %s\n' "${MOCK_ROOT_LOGIN:-yes}"
printf 'passwordauthentication %s\n' "${MOCK_PASSWORD_AUTH:-yes}"
MOCK_SSHD

cat > "$MOCK_BIN/sudo" <<'MOCK_SUDO'
#!/usr/bin/env bash
if [ "${1:-}" = "-n" ]; then
    shift
fi
exec "$@"
MOCK_SUDO

chmod +x "$MOCK_BIN/sshd" "$MOCK_BIN/sudo"

run_mocked_ssh_audit() {
    MOCK_ROOT_LOGIN="$1" \
    MOCK_PASSWORD_AUTH="$2" \
    MOCK_SSHD_FAIL="${3:-0}" \
    PATH="$MOCK_BIN:$PATH" \
        bash "$SCRIPT" > "$TEMP_OUTPUT" 2>&1
}

echo
echo "---- SSH Behaviour Tests ----"

run_mocked_ssh_audit no no
check "Disabled root login produces PASS" \
    grep -Fq "[PASS] SSH root login is disabled" "$TEMP_OUTPUT"

run_mocked_ssh_audit yes no
check "Enabled root login produces FAIL" \
    grep -Fq "[FAIL] SSH root login is enabled" "$TEMP_OUTPUT"

run_mocked_ssh_audit no yes
check "Enabled password authentication produces REVIEW" \
    grep -Fq "[REVIEW] SSH password authentication is enabled" "$TEMP_OUTPUT"

run_mocked_ssh_audit no no 1
check "Unavailable SSH configuration produces REVIEW" \
    grep -Fq "[REVIEW] Effective SSH configuration could not be evaluated" "$TEMP_OUTPUT"

rm -rf "$MOCK_BIN"

echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi