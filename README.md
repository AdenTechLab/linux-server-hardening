
# Linux Server Hardening 🔐

A hands-on Linux administration and cybersecurity project focused on identifying common security misconfigurations through Bash automation, SSH configuration auditing, sensitive file permission checks, firewall status checks and package update auditing.

The project includes an automated security audit script, remediation recommendations, automated tests, ShellCheck validation and a GitHub Actions CI pipeline.

**Project status:** Core features implemented  
**Automated tests:** 26 passed, 0 failed  
**CI status:** Passing

## 🎯 Objectives

- Audit SSH security settings and identify potentially insecure configurations.
- Review permissions on sensitive Linux system files.
- Check firewall status and identify potentially inactive firewall protection.
- Identify available package updates using APT package lists.
- Generate clear `PASS`, `FAIL` and `REVIEW` findings.
- Provide remediation recommendations for selected security issues.
- Automate repeatable security checks using Bash.
- Validate script behaviour through automated testing.
- Integrate static analysis and testing into GitHub Actions.
- Document findings, limitations and future security improvements.

## 🛠️ Technologies

- **Operating system:** Ubuntu-based Codespaces environment
- **Scripting:** Bash
- **SSH:** OpenSSH
- **File permissions:** Linux permissions and `stat`
- **Firewall:** UFW
- **Package management:** APT
- **Testing:** Automated Bash test suite with mocked commands
- **Static analysis:** ShellCheck
- **Version control:** Git and GitHub
- **CI/CD:** GitHub Actions

## 🔍 Security Audit Features

The audit script, `scripts/security-audit.sh`, performs selected security checks in the environment where it runs.

### SSH Configuration Auditing

- Evaluates effective SSH settings using `sshd -T` when available.
- Checks whether SSH root login is disabled.
- Checks whether password authentication is enabled.
- Reports unavailable or unevaluable configuration as `REVIEW`.
- Provides remediation guidance for selected SSH findings.

### Sensitive File Permission Auditing

The script checks permissions on:

- `/etc/passwd`
- `/etc/shadow`
- `/etc/ssh/sshd_config`

It compares observed permission modes against basic project policies and flags permissions that may be too broad.

Permission requirements can vary by Linux distribution and security policy, so findings should be reviewed in context.

### Firewall Status Auditing

- Checks whether UFW reports an active or inactive firewall.
- Reports an active firewall as `PASS`.
- Reports an inactive firewall as `FAIL`.
- Reports an unknown or unconfirmed firewall status as `REVIEW`.
- Does not modify firewall rules automatically.

### Patch Status Auditing

- Checks APT package lists for available package updates.
- Reports available updates as `REVIEW`.
- Reports no updates in the available package lists as `PASS`.
- Reports an unsuccessful update-status check as `REVIEW`.
- Does not install updates or automatically modify installed packages.

**Important:** Patch status results depend on the existing APT package lists, which may be out of date. The audit does not refresh package lists or guarantee that all security updates have been identified.

### Audit Reporting

The script produces a timestamped report in the `evidence/` directory and displays a summary containing:

- `PASS`: Checks that meet the implemented policy.
- `FAIL`: Findings identified as failing a security check.
- `REVIEW`: Checks requiring further investigation or that could not be fully verified.

Selected findings include remediation recommendations. The script reports findings without automatically changing system configuration.

## 🧪 Automated Testing

The test suite is located at `tests/test-security-audit.sh`.

The project currently contains **26 automated tests**, covering:

- Audit script existence, readability and Bash syntax.
- Successful execution and audit summary reporting.
- SSH security behaviour using mocked commands.
- Sensitive file permission behaviour, including broad permissions, missing files and inspection failures.
- Firewall behaviour for active, inactive and unknown status.
- Patch status behaviour for available updates, no reported updates and failed checks.

The SSH behaviour tests verify that:

1. Disabled root login produces `PASS`.
2. Enabled root login produces `FAIL`.
3. Enabled password authentication produces `REVIEW`.
4. Unavailable SSH configuration produces `REVIEW`.

The firewall tests verify active, inactive and unknown status outcomes.

The patch status tests verify available updates, no reported updates and an unsuccessful status check.

The test suite uses controlled mock commands to test selected outcomes without installing system updates or changing real firewall settings.

Latest verified local test result:

```text
Results: 26 passed, 0 failed
```

These tests validate the scenarios covered by the test suite. They do not prove that every security control works correctly on every Linux distribution.

## ⚙️ Continuous Integration

The repository uses GitHub Actions to validate changes automatically.

The CI workflow includes:

- ShellCheck static analysis.
- Bash syntax validation.
- Automated test execution.

The latest verified workflow run passed.

- **Repository:** [AdenTechLab/linux-server-hardening](https://github.com/AdenTechLab/linux-server-hardening)
- **Workflow:** `.github/workflows/security-audit.yml`
- **Actions:** [View workflow runs](https://github.com/AdenTechLab/linux-server-hardening/actions)

## 🔐 Risk Mitigation

| Security Risk | Implemented Control | Intended Benefit |
|---|---|---|
| SSH root login enabled | Effective SSH setting check | Identifies direct root-login exposure |
| SSH password authentication enabled | Effective SSH setting check | Highlights authentication settings requiring review |
| Excessive file permissions | Permission policy checks | Identifies potentially over-permissive system files |
| Inactive UFW firewall | Firewall status check | Identifies a potentially unprotected host firewall |
| Available package updates | APT patch status check | Highlights systems that may require updates |
| Undetected configuration issues | Automated Bash audit | Makes selected checks repeatable |
| Inconsistent validation | Automated tests and ShellCheck | Helps catch regressions and scripting errors |
| Limited visibility of findings | Summary report and recommendations | Makes results easier to review |

The audit provides selected checks and does not automatically remediate detected issues.

## 🖥️ Manual Security Validation

The following commands can be used to investigate security settings on a suitable Ubuntu Server environment.

**Validate SSH configuration syntax**

```bash
sudo sshd -t
```

**Inspect effective SSH settings**

```bash
sudo sshd -T | grep -E '^(permitrootlogin|passwordauthentication) '
```

**Check firewall status**

```bash
sudo ufw status verbose
```

**Review listening network ports**

```bash
sudo ss -tulpen
```

**Check failed system services**

```bash
systemctl --failed
```

**Review available package updates**

```bash
apt list --upgradable
```

These commands are manual validation examples. Including them in this README does not mean the project automatically performs every command or check listed here.

## 🚀 Future Improvements

- Improve SSH checks for connection-specific `Match` configuration rules.
- Expand firewall checks to inspect individual rules.
- Add automated tests for additional file permission policy decisions.
- Expand checks for listening services and exposed network ports.
- Improve remediation recommendations for file permission findings.
- Add representative before-and-after audit reports.
- Document verification procedures for each implemented security control.
- Test the audit against a dedicated Ubuntu Server virtual machine.

## 📈 Skills Demonstrated

This project demonstrates practical work with:

- Linux command-line administration.
- Bash scripting and automation.
- SSH security configuration.
- Linux file permissions.
- Firewall and package update status checks.
- Security auditing and misconfiguration detection.
- Automated testing and static analysis.
- Git, GitHub and version control.
- CI/CD workflow configuration.
- Technical documentation and troubleshooting.

These skills are relevant to entry-level DevOps, Cloud Engineering, Linux Administration and Cybersecurity roles.

## 📚 Learning Resources

- [Ubuntu Server Documentation](https://documentation.ubuntu.com/server/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [UFW Manual](https://manpages.ubuntu.com/manpages/noble/en/man8/ufw.8.html)
- [APT Documentation](https://manpages.ubuntu.com/manpages/noble/en/man8/apt.8.html)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## ⚠️ Limitations and Disclaimer

This is an educational project developed and tested in a Codespaces container. Results from the container do not establish the security of the host system or a production server.

Some checks may return `REVIEW` when configuration files, tools or permissions are unavailable. Permission policies may also need adjustment for different distributions.

Patch status results depend on locally available APT package lists and may not reflect the latest published updates.

The audit provides selected checks and recommendations. It is not a comprehensive vulnerability scanner and does not guarantee that a system is secure. Findings should be investigated and verified against the target system's security requirements.

Test configuration changes in a controlled environment before applying them to production systems. Maintain an alternative administrative access method before changing SSH or firewall settings.
