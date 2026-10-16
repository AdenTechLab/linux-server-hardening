#!/usr/bin/env bash

set -u

SCRIPT="scripts/security-audit.sh"
PASS=0
FAIL=0
TEMP_OUTPUT=$(mktemp)
MOCK_BIN=$(mktemp -d)
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -f "$TEMP_OUTPUT"
    rm -rf "$MOCK_BIN" "$TEMP_DIR"
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

# Set up mock SSH commands for controlled tests.
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

# Create temporary files for permission behaviour tests.
SAFE_FILE="$TEMP_DIR/safe-file"
BROAD_FILE="$TEMP_DIR/broad-file"
STAT_FAIL_FILE="$TEMP_DIR/stat-fail-file"
MISSING_FILE="$TEMP_DIR/missing-file"

touch "$SAFE_FILE" "$BROAD_FILE" "$STAT_FAIL_FILE"
chmod 644 "$SAFE_FILE"
chmod 666 "$BROAD_FILE"
chmod 644 "$STAT_FAIL_FILE"

# Mock stat so permission checks can be tested predictably.
REAL_STAT=$(command -v stat)
export REAL_STAT

cat > "$MOCK_BIN/stat" <<'MOCK_STAT'
#!/usr/bin/env bash

for argument in "$@"; do
    case "$argument" in
        */stat-fail-file)
            exit 1
            ;;
        */safe-file)
            printf '644\n'
            exit 0
            ;;
        */broad-file)
            printf '666\n'
            exit 0
            ;;
    esac
done

exec "$REAL_STAT" "$@"
MOCK_STAT

chmod +x "$MOCK_BIN/stat"

run_permission_audit() {
    PASSWD_FILE="$1" \
    SHADOW_FILE="$2" \
    SSH_CONFIG_FILE="$3" \
    MOCK_ROOT_LOGIN=no \
    MOCK_PASSWORD_AUTH=no \
    PATH="$MOCK_BIN:$PATH" \
        bash "$SCRIPT" > "$TEMP_OUTPUT" 2>&1
}

echo
echo "---- File Permission Behaviour Tests ----"

run_permission_audit "$SAFE_FILE" "$SAFE_FILE" "$SAFE_FILE"
check "Acceptable file permissions produce PASS" \
    grep -Fq "permissions meet the basic policy (mode 644)" "$TEMP_OUTPUT"

run_permission_audit "$BROAD_FILE" "$SAFE_FILE" "$SAFE_FILE"
check "Overly broad file permissions produce REVIEW" \
    grep -Fq "permissions may be too broad (mode 666)" "$TEMP_OUTPUT"

run_permission_audit "$MISSING_FILE" "$SAFE_FILE" "$SAFE_FILE"
check "Missing file produces REVIEW" \
    grep -Fq "/etc/passwd: file is unavailable" "$TEMP_OUTPUT"

run_permission_audit "$STAT_FAIL_FILE" "$SAFE_FILE" "$SAFE_FILE"
check "Permission inspection failure produces REVIEW" \
    grep -Fq "/etc/passwd: permissions cannot be inspected" "$TEMP_OUTPUT"

# Mock UFW so firewall tests never change real firewall settings.
cat > "$MOCK_BIN/ufw" <<'MOCK_UFW'
#!/usr/bin/env bash

if [ "${1:-}" = "status" ]; then
    printf 'Status: %s\n' "${MOCK_UFW_STATUS:-unknown}"
    exit 0
fi

echo "Unsupported mock UFW command"
exit 1
MOCK_UFW

chmod +x "$MOCK_BIN/ufw"

run_firewall_audit() {
    PASSWD_FILE="$SAFE_FILE" \
    SHADOW_FILE="$SAFE_FILE" \
    SSH_CONFIG_FILE="$SAFE_FILE" \
    MOCK_ROOT_LOGIN=no \
    MOCK_PASSWORD_AUTH=no \
    MOCK_UFW_STATUS="$1" \
    PATH="$MOCK_BIN:$PATH" \
        bash "$SCRIPT" > "$TEMP_OUTPUT" 2>&1
}

echo
echo "---- Firewall Behaviour Tests ----"

run_firewall_audit active
check "Active firewall produces PASS" \
    grep -Fq "[PASS] UFW reports that the firewall is active" "$TEMP_OUTPUT"

run_firewall_audit inactive
check "Inactive firewall produces FAIL" \
    grep -Fq "[FAIL] UFW reports that the firewall is inactive" "$TEMP_OUTPUT"

run_firewall_audit unknown
check "Unknown firewall status produces REVIEW" \
    grep -Fq "[REVIEW] Firewall status could not be confirmed" "$TEMP_OUTPUT"

echo
echo "Results: $PASS passed, $FAIL failed"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
