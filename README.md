
# Linux Server Hardening 🔐

A hands-on Linux administration and cybersecurity project focused on identifying common security misconfigurations through Bash automation, SSH configuration auditing and sensitive file permission checks.

The project includes an automated security audit script, remediation recommendations, automated tests, ShellCheck validation and a GitHub Actions CI pipeline.

**Project status:** Active development  
**Automated tests:** 16 passed, 0 failed  
**CI status:** Passing

## 🎯 Objectives

- Audit SSH security settings and identify potentially insecure configurations.
- Review permissions on sensitive Linux system files.
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
- **Testing:** Automated Bash test suite
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

These checks identify potential misconfigurations. Permission requirements can vary by Linux distribution and security policy, so findings should be reviewed in context.

### Audit Reporting

The script produces a timestamped report in the `evidence/` directory and displays a summary containing:

- `PASS`: Checks that meet the implemented policy.
- `FAIL`: Findings identified as failing a security check.
- `REVIEW`: Checks requiring further investigation or that could not be fully verified.

Selected SSH findings include remediation recommendations. The script reports findings without automatically changing system configuration.

## 🧪 Automated Testing

The test suite is located at `tests/test-security-audit.sh`.

It currently contains **16 automated tests**, including checks for:

- Audit script existence and readability.
- Bash syntax validation.
- Successful script execution.
- Audit summary and finding counts.
- SSH security check reporting.
- Sensitive file permission check reporting.
- SSH behaviour under controlled test scenarios.

Four SSH behaviour tests use mocked commands to verify that:

1. Disabled root login produces `PASS`.
2. Enabled root login produces `FAIL`.
3. Enabled password authentication produces `REVIEW`.
4. Unavailable SSH configuration produces `REVIEW`.

Latest local test result:

```text
Results: 16 passed, 0 failed
```

These tests validate the behaviour covered by the test suite. They do not prove that every security control works correctly on every Linux distribution.

## ⚙️ Continuous Integration

The repository uses GitHub Actions to validate changes automatically.

The CI workflow includes:

- ShellCheck static analysis.
- Bash syntax validation.
- Automated test execution.

The workflow has passed on the latest verified run.

- **Repository:** [AdenTechLab/linux-server-hardening](https://github.com/AdenTechLab/linux-server-hardening)
- **Workflow:** `.github/workflows/security-audit.yml`

## 🔐 Risk Mitigation

| Security Risk | Implemented Control | Intended Benefit |
|---|---|---|
| SSH root login enabled | Effective SSH setting check | Identifies direct root-login exposure |
| SSH password authentication enabled | Effective SSH setting check | Highlights authentication settings requiring review |
| Excessive file permissions | Permission policy checks | Identifies potentially over-permissive system files |
| Undetected configuration issues | Automated Bash audit | Makes selected checks repeatable |
| Inconsistent validation | Automated tests and ShellCheck | Helps catch regressions and scripting errors |
| Limited visibility of findings | Summary report and recommendations | Makes results easier to review |

Additional controls, including firewall configuration, automatic security updates and running-service hardening, remain planned work rather than completed features.

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

These commands are manual validation examples. Including them in this README does not mean the project automatically performs all these checks.

## 🚀 Future Improvements

- Add automated tests for sensitive file permission policy decisions.
- Expand audit coverage for firewall configuration and listening services.
- Add checks for system updates and security patch status.
- Improve SSH checks for connection-specific `Match` configuration rules.
- Expand remediation recommendations for file permission findings.
- Add representative before-and-after audit reports.
- Document verification procedures for each implemented security control.

## 📈 Skills Demonstrated

This project demonstrates practical work with:

- Linux command-line administration.
- Bash scripting and automation.
- SSH security configuration.
- Linux file permissions.
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
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## ⚠️ Limitations and Disclaimer

This is an educational project developed and tested in a Codespaces container. Results from the container do not establish the security of the host system or a production server.

Some checks may return `REVIEW` when configuration files, tools or permissions are unavailable. Permission policies may also need adjustment for different distributions.

The audit provides selected checks and recommendations; it is not a comprehensive vulnerability scanner and does not guarantee that a system is secure. Findings should be investigated and verified against the target system's security requirements.

Test configuration changes in a controlled environment before applying them to production systems. Maintain an alternative administrative access method before changing SSH or firewall settings.
