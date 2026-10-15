
# Linux Server Hardening 🔐

A hands-on Linux system administration and cybersecurity project focused on securing an Ubuntu Server environment through system hardening, firewall configuration, SSH security and Bash automation.

## 🎯 Objectives

- Secure SSH remote access and disable direct root login.
- Configure firewall rules using UFW.
- Apply system updates and automatic security patches.
- Review running services and listening network ports.
- Apply appropriate file permissions.
- Automate security checks using Bash scripting.
- Document security improvements and testing results.

## 🛠️ Technologies

- **Operating System:** Ubuntu Server
- **Scripting:** Bash
- **Remote Access:** OpenSSH
- **Firewall:** UFW
- **Package Management:** APT
- **Version Control:** Git and GitHub
- **Virtualisation:** VirtualBox

## ❗ Risk Mitigations Achieved

| Security Risk | Mitigation Implemented | Security Benefit |
|---|---|---|
| Unauthorised SSH access | SSH key authentication and restricted login settings | Reduces the risk of password-based attacks |
| Unauthorised root access | Disabled direct root login over SSH | Reduces exposure of the root account |
| Unnecessary network exposure | UFW firewall rules | Restricts unsolicited incoming connections |
| Unpatched vulnerabilities | System updates and automatic security updates | Reduces exposure to known vulnerabilities |
| Unnecessary running services | Reviewed active services and listening ports | Reduces the server's attack surface |
| Excessive file permissions | Reviewed file ownership and permissions | Reduces the risk of unauthorised file access |
| Undetected security misconfigurations | Automated Bash security audit | Helps identify potential security issues |
| Limited security visibility | Documented audit reports and validation results | Improves visibility of the server's security posture |

### Risk Assessment

The project aims to reduce common Linux server security risks through configuration hardening, access control, patch management and automated auditing.

**Validation:** Each mitigation must be tested and documented before it is reported as achieved. This project does not guarantee that the server is completely secure.


## 🧪 Testing and Validation

Security controls will be validated using:

- `sudo sshd -t`
- `sudo ufw status verbose`
- `sudo ss -tulpen`
- `systemctl --failed`
- Automated security audit output.

Before-and-after results will be documented to demonstrate the effectiveness of the hardening measures.

## 📈 Expected Outcomes

- A more securely configured Ubuntu Server.
- Reduced exposure of unnecessary network services.
- Improved remote access security.
- Repeatable security checks through Bash automation.
- Practical experience in Linux administration and security hardening.

## 📚 Learning Resources

- [Ubuntu Server Documentation](https://documentation.ubuntu.com/server/)
- [OpenSSH Documentation](https://www.openssh.com/manual.html)
- [UFW Manual](https://manpages.ubuntu.com/manpages/noble/en/man8/ufw.8.html)
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/)

## ⚠️ Disclaimer

This project is intended for educational purposes. Test all configuration changes in a controlled environment before deploying them to production systems.

---
