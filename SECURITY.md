# Security considerations

- The script operates as the target **unprivileged** user; `sudo` is used for missing Ubuntu apt dependencies only. Do not run the installer as root.
- `--latest` is intentionally **not** an unattended updater. It resolves upstream software once for new accounts and records versions. Production should prefer reviewed, pinned releases.
- Starship archive integrity: SHA-256 from the same upstream GitHub release endpoint over HTTPS (not an independently signed release assertion). Oh My Zsh/plugin Git revisions are recorded and verified.
- A `curl` download is still executable code: inspect the script and pin an immutable reviewed commit or release when deploying on sensitive hosts. The README one-liner fetches the script first instead of using `curl | sh`.
- Existing configurations are protected unless `--replace` is given. Backups are made of changed configs and locally installed Starship binary. Full transaction rollback is not implemented.
- **Never commit** private shell dotfiles, SSH keys, access tokens, TOTP, environment files, API credentials, cloud-image disks or logs that may contain secrets.
- Lab VM SSH is forwarded only to localhost, and its passwordless-sudo user exists only inside the disposable VM. Do not expose the VM SSH port publicly.
- This installer should not be coupled to identity, mail, VPN, or any production service restart.

If a security flaw is found before public issue reporting is configured, contact the repository owner privately through the organization’s established security channel. Do not post credentials or exploit material in public issues.
