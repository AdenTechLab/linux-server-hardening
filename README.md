# Linux Server Hardening 🔐

A hands-on Linux system administration and cybersecurity project focused on hardening an Ubuntu Server environment through SSH security, file permission auditing, security configuration checks and Bash automation.

The project includes an automated security audit script, test validation and static analysis to help identify potential Linux server misconfigurations.

## 🎯 Objectives

- Strengthen SSH security and restrict direct root login.
- Configure firewall rules using UFW.
- Apply system updates and automatic security patches.
- Review running services and listening network ports.
- Audit sensitive system file permissions.
- Automate security checks using Bash scripting.
- Validate script functionality through automated tests.
- Document security findings and remediation steps.

## 🛠️ Technologies

- **Operating System:** Ubuntu Server
- **Scripting:** Bash
- **Remote Access:** OpenSSH
- **Firewall:** UFW
- **Package Management:** APT
- **Testing:** Automated shell script tests
- **Static Analysis:** ShellCheck
- **Version Control:** Git and GitHub
- **Virtualisation:** VirtualBox

## 🔍 Security Audit Automation

The Bash security audit script checks important areas of Linux server security and generates a summary of its findings.

Current audit capabilities include:

- SSH security configuration checks.
- Sensitive file permission checks.
- `/etc/passwd` permission validation.
- `/etc/shadow` permission validation.
- SSH configuration file permission checks.
- Summary reporting with `PASS`, `FAIL` and `REVIEW` counts.

These checks help identify potential security misconfigurations that may require further investigation or remediation.

## 🧪 Testing and Validation

The audit script has been tested to verify its functionality and reporting behaviour.

| Validation Check | Result |
|---|---|
| Audit script executes successfully | PASS |
| Audit output includes a summary | PASS |
| SSH security checks are included | PASS |
| Sensitive file permission checks are included | PASS |
| `/etc/passwd` permissions are checked | PASS |
| `/etc/shadow` permissions are checked | PASS |
| SSH configuration permissions are checked | PASS |
| PASS, FAIL and REVIEW counts are reported | PASS |
| Automated test suite | 12 passed, 0 failed |
| ShellCheck static analysis | PASS |

**Testing status:** The automated test suite and ShellCheck validation have passed. These results confirm the checks tested are working as expected, but do not independently prove that the server is fully secure.

## 🔐 Risk Mitigation

| Security Risk | Planned or Implemented Control | Security Benefit |
|---|---|---|
| Unauthorised SSH access | SSH configuration auditing and secure authentication settings | Helps reduce the risk of unauthorised access |
| Direct root login | Review and disable SSH root login where appropriate | Reduces exposure of the root account |
| Unnecessary network exposure | UFW firewall configuration | Restricts unwanted incoming connections |
| Unpatched vulnerabilities | System updates and automatic security updates | Reduces exposure to known vulnerabilities |
| Unnecessary running services | Review active services and listening ports | Helps reduce the attack surface |
| Excessive file permissions | Audit sensitive system file permissions | Helps prevent unauthorised access |
| Undetected misconfigurations | Automated Bash security audit | Improves consistency of security checks |
| Limited security visibility | Audit summaries and test results | Makes potential security issues easier to identify |

*Note: Controls must be configured and verified on the target server before they can be reported as fully implemented.*

## 🖥️ Manual Security Validation

The following commands can be used to validate additional security controls on an Ubuntu Server.

**Validate SSH configuration**

```bash
sudo sshd -t
```

**Check firewall configuration**

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

**Run the automated audit**

Use the repository's audit script to generate a security summary and review any `FAIL` or `REVIEW` findings.

## 🚀 Future Improvements

- Remediate and revalidate identified SSH security findings.
- Remove duplicate SSH evaluation logic.
- Expand automated tests to cover additional security scenarios.
- Integrate automated checks into GitHub Actions.
- Add before-and-after security audit examples.
- Document remediation steps and verification evidence.
- Expand checks for firewall rules, system updates and exposed services.

## 📈 Project Outcomes

This project demonstrates practical experience with:

- Linux command-line administration.
- Bash scripting and automation.
- SSH security configuration.
- Linux file permissions.
- Security auditing and misconfiguration detection.
- Automated testing and static analysis.
- Git, GitHub and version control workflows.
- Security-focused troubleshooting and documentation.

These skills are relevant to entry-level DevOps, Cloud Engineering, Linux Administration and Cybersecurity roles.

## 📚 Learning Resources

- [Ubuntu Server Documentation](https://documentation.ubuntu.com/server/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [UFW Manual](https://manpages.ubuntu.com/manpages/noble/en/man8/ufw.8.html)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)
- [ShellCheck](https://www.shellcheck.net/)

## ⚠️ Disclaimer

This project is intended for educational purposes. Test configuration changes in a controlled environment before applying them to production systems. Always maintain an alternative access method before changing SSH or firewall settings.

A successful audit does not guarantee that a system is completely secure. Findings should be reviewed in context and verified against the intended security requirements.

---

**Project status:** In progress. The Bash audit script has passed its current automated tests and ShellCheck validation. Additional hardening, remediation and continuous integration work remain.