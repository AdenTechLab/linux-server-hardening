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
    local recommendation="${3:-}"

    printf '[%s] %s\n' "$status" "$message"

    if [ -n "$recommendation" ]; then
        printf '  Recommendation: %s\n' "$recommendation"
    fi

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

    OS_NAME=$(
        awk -F= '$1 == "PRETTY_NAME" {
            sub(/^"/, "", $2)
            sub(/"$/, "", $2)
            print $2
            exit
        }' /etc/os-release 2>/dev/null
    )
    echo "OS: ${OS_NAME:-Unknown}"
    echo

    echo "---- Audit Checks ----"

        echo
   
    echo "---- SSH Security Checks ----"

    if command -v sshd >/dev/null 2>&1; then

    SSH_EFFECTIVE_CONFIG=$(sudo -n sshd -T 2>/dev/null) ||
    SSH_EFFECTIVE_CONFIG=$(sshd -T 2>/dev/null) ||
    SSH_EFFECTIVE_CONFIG=""
    
        if [ -z "$SSH_EFFECTIVE_CONFIG" ]; then
            report REVIEW "Effective SSH configuration could not be evaluated"
        else
            ROOT_LOGIN=$(printf '%s\n' "$SSH_EFFECTIVE_CONFIG" |
                awk '$1 == "permitrootlogin" {print $2; exit}')

            PASSWORD_AUTH=$(printf '%s\n' "$SSH_EFFECTIVE_CONFIG" |
                awk '$1 == "passwordauthentication" {print $2; exit}')

            case "$ROOT_LOGIN" in
                no)
                    report PASS "SSH root login is disabled"
                    ;;
                prohibit-password|without-password)
                    report REVIEW "SSH root login is allowed with key-based authentication"
                    ;;
                yes)
                    report FAIL "SSH root login is enabled" \
                    "Consider setting PermitRootLogin no after confirming an alternative administrative access method."
                    ;;
                *)
                    report REVIEW "SSH root login setting could not be determined"
                    ;;
            esac

            case "$PASSWORD_AUTH" in
                no)
                    report PASS "SSH password authentication is disabled"
                    ;;
                yes)
                    report REVIEW "SSH password authentication is enabled" \
    "Review whether key-based authentication can be used and password login safely disabled."
                    ;;
                *)
                    report REVIEW "SSH password authentication setting could not be determined"
                    ;;
            esac
        fi
    else
        report REVIEW "SSH server tools are unavailable in this environment"
    fi

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

    echo "---- Sensitive File Permission Checks ----"

       check_file_permissions() {
        local file="$1"
        local description="$2"
        local allowed_mode="$3"
        local actual_mode
        local mode_value
        local disallowed_bits

        if [ ! -e "$file" ]; then
            report REVIEW "$description: file is unavailable"
            return
        fi

        actual_mode=$(stat -c '%a' "$file" 2>/dev/null) || {
            report REVIEW "$description: permissions cannot be inspected"
            return
        }

        mode_value=$((8#$actual_mode))
        disallowed_bits=$((mode_value & ~allowed_mode))

        if [ "$disallowed_bits" -ne 0 ]; then
            report REVIEW "$description: permissions may be too broad (mode $actual_mode)"
        else
            report PASS "$description: permissions meet the basic policy (mode $actual_mode)"
        fi
    }

    check_file_permissions "/etc/passwd" "/etc/passwd" 0644
    check_file_permissions "/etc/shadow" "/etc/shadow" 0640
    check_file_permissions "/etc/ssh/sshd_config" "/etc/ssh/sshd_config" 0600

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
