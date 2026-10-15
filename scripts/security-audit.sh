
#!/usr/bin/env bash

set -u

mkdir -p evidence
REPORT_FILE="evidence/security-audit-$(date +%F-%H%M%S).txt"

PASS=0
FAIL=0
REVIEW=0

report() {
    local status="$1"
    local message="$2"

    printf '[%s] %s\n' "$status" "$message"

    case "$status" in
        PASS) PASS=$((PASS + 1)) ;;
        FAIL) FAIL=$((FAIL + 1)) ;;
        REVIEW) REVIEW=$((REVIEW + 1)) ;;
    esac
}

{
    echo "======================================"
    echo " Linux Server Hardening Audit"
    echo "======================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "User: $(id -un)"
    echo "OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
    echo

    echo "---- Audit Checks ----"

    if command -v bash >/dev/null 2>&1; then
        report PASS "Bash is available"
    else
        report FAIL "Bash is unavailable"
    fi

    if command -v ss >/dev/null 2>&1; then
        report PASS "Network socket inspection tool is available"
    else
        report REVIEW "ss is unavailable"
    fi

    if command -v sshd >/dev/null 2>&1; then
        if sshd -T >/dev/null 2>&1; then
            report PASS "SSH configuration can be evaluated"
        else
            report REVIEW "SSH configuration could not be evaluated"
        fi
    else
        report REVIEW "SSH server is not available in this environment"
    fi

    if command -v ufw >/dev/null 2>&1; then
        firewall_output=$(ufw status 2>&1 || true)

        if printf '%s\n' "$firewall_output" | grep -q "Status: active"; then
            report PASS "UFW reports that the firewall is active"
        elif printf '%s\n' "$firewall_output" | grep -q "Status: inactive"; then
            report FAIL "UFW reports that the firewall is inactive"
        else
            report REVIEW "Firewall status could not be confirmed"
        fi
    else
        report REVIEW "UFW is unavailable in this environment"
    fi

    if [ -r /etc/os-release ]; then
        report PASS "Operating system information is readable"
    else
        report FAIL "Operating system information is unavailable"
    fi

    echo
    echo "---- Summary ----"
    echo "PASS: $PASS"
    echo "FAIL: $FAIL"
    echo "REVIEW: $REVIEW"
    echo
    echo "Note: This audit runs in the current environment."
    echo "Container results do not establish host security."
} | tee "$REPORT_FILE"

echo
echo "Report saved to: $REPORT_FILE"
