# Installation and operations

## Assumptions

- Ubuntu 22.04, 24.04 or 26.04; end-to-end clean installation verified only on Ubuntu 24.04 at this stage.
- Run as the **target non-root user**. `sudo` is invoked for missing apt packages; account needs administrative permission only if packages are missing. The installer refuses root.
- `curl` is needed for the standalone remote script; the one-line command in README installs it first. Network access is required to GitHub and Ubuntu apt repositories.
- Supported Starship release architectures: x86_64 and aarch64; QEMU VM integration tested on x86_64.
- New user with no unmanaged `.zshrc` or `starship.toml` is the safest target.

## Commands

```sh
sh ac-shell-setup.sh plan
sh ac-shell-setup.sh install
sh ac-shell-setup.sh install --latest
sh ac-shell-setup.sh install --set-default-shell
sh ac-shell-setup.sh verify
sh test-shell.sh
```

- `install` defaults to Starship **1.27.0** and pinned Oh My Zsh/plugin revisions. If already installed with a `versions.tsv` lock, it reuses the recorded version instead of downgrading.
- `--latest` on first install downloads the **latest stable**, resolves plugin Git HEADs and saves full commits; on an already locked account it **only verifies**, does **not** update.
- `--replace` explicitly permits backup and replacement of pre-existing `.zshrc`, `starship.toml`, and differing local Starship binary. It does **not** automatically rewrite mismatched existing Oh My Zsh/plugin Git repos.
- `--set-default-shell` invokes `chsh` and can require authentication. It must be explicitly requested. Re-login for it to take effect.
- `plan`, `verify`, and `render-*` do not install packages or change dotfiles.

## Managed paths

```text
~/.zshrc
~/.oh-my-zsh/
~/.config/starship.toml
~/.local/bin/starship
~/.config/ac-shell/versions.tsv
```

Starship archive SHA-256 is compared to the checksum distributed with that same upstream release over HTTPS; it is **not** independent release-signature verification. Git repositories are fetched via HTTPS and exact commits are recorded locally. For high-assurance production, pin trusted upstream archive hashes and signed tags in a separate release process.

The script rejects foreign `STARSHIP_CONFIG` and `ZDOTDIR`, managed-path symlinks and unapproved unmanaged configuration files. Changed files are backed up before overwriting. It does not support a full rollback/uninstall transaction yet. Avoid running it against critical administrators' existing heavily customized shells without taking a backup.

## Safe test sequence

1. `sh test-shell.sh` and `sh ac-shell-setup.sh plan` on the laptop.
2. `lab/run-local-user-lab.sh` on a disposable account named `ac-shell-test`. This test deliberately requires *no* existing installation and leaves the user's login shell unchanged.
3. `lab/ac-shell-vm-lab.sh prepare`, `start`, `test`, and `status` from a non-root host account on a QEMU/KVM machine (see [lab/README.md](lab/README.md)).
4. Only after verifying, deploy to another server using a pinned release.

**Don't run** the lab runner again against an already provisioned `ac-shell-test` user: it intentionally refuses existing installations. The VM runner's `test` action also assumes a fresh guest.

## Keeping up to date

`--latest` is *install-time selection*, not scheduled background upgrading. An explicit future `update` command, compatibility tests, and rollback are tracked separately; no unattended upgrades are implemented. Ordinary Ubuntu security updates should continue through the OS package manager.

## Out of scope

No root/system shell, no server bootstrap, no unattended deployment, no OS upgrades, no Devuan migration, no modification of other users' environments, no external identity/account-manager integration.
