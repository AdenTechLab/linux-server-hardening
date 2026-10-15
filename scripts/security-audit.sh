
#!/usr/bin/env bash
set -u

mkdir -p evidence
REPORT_FILE="evidence/security-audit-$(date +%F-%H%M%S).txt"

echo "Linux Server Hardening - Security Audit"
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(id -un)"
echo "OS: $(. /etc/os-release && echo "$PRETTY_NAME")"
echo

{
    echo "=== SSH Configuration ==="
    if command -v sshd >/dev/null 2>&1; then
        sshd -T 2>/dev/null |
            grep -E '^(permitrootlogin|passwordauthentication|pubkeyauthentication) ' ||
            echo "SSH settings unavailable"
    else
        echo "SSH server not available in this container"
    fi

    echo
    echo "=== Firewall ==="
    if command -v ufw >/dev/null 2>&1; then
        ufw status verbose 2>&1
    else
        echo "UFW is not installed"
    fi

    echo
    echo "=== Listening Ports ==="
    ss -tuln 2>&1

    echo
    echo "=== Failed Services ==="
    if command -v systemctl >/dev/null 2>&1; then
        systemctl --failed --no-pager 2>&1
    else
        echo "systemctl is unavailable"
    fi

    echo
    echo "=== Package Updates ==="
    apt list --upgradable 2>/dev/null || true

    echo
    echo "=== User Privileges ==="
    id
} | tee "$REPORT_FILE"

echo
echo "Audit complete."
echo "Report saved to: $REPORT_FILE"
