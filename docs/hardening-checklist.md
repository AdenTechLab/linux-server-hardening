# Linux Server Hardening Checklist

## System Updates
- [ ] Update package lists.
- [ ] Install available security updates.
- [ ] Configure automatic security updates.

## SSH Security
- [ ] Review SSH configuration.
- [ ] Disable direct root login over SSH.
- [ ] Configure SSH key authentication.
- [ ] Validate configuration before applying changes.

## Firewall
- [ ] Review inbound network access requirements.
- [ ] Configure UFW firewall rules.
- [ ] Verify firewall status and active rules.

## System Review
- [ ] Review listening network ports.
- [ ] Identify unnecessary services.
- [ ] Review file permissions.

## Audit and Validation
- [ ] Run the Bash security audit script.
- [ ] Review generated audit output.
- [ ] Document findings and remediation.
- [ ] Record before-and-after results.

> Note: Mark items complete only after implementing and verifying
> the corresponding controls on a suitable Linux server.
