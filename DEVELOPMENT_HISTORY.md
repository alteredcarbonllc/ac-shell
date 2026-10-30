# Development history and verification ledger

**Language:** English · [Українська](docs/uk/DEVELOPMENT_HISTORY.md) · [Русский](docs/ru/DEVELOPMENT_HISTORY.md)

Source: direct command output from the user on Ubuntu 26.04.1 LTS laptop, 30–31 Oct 2026. These are *recorded results*, not claims of new tests performed inside GitHub.

## 01 — Baseline audit (30 Oct)

- Detected Ubuntu 26.04.1, Zsh 5.9, Oh My Zsh at audited revision `0eeaa529bb1442c2934930a5820f596e678458d4`, Starship 1.26.0.
- Detected `fzf` 0.67.0, `zoxide` 0.9.8, Git 2.53.0, Python 3.14.4, `rg`, `fdfind`, `mosh`.
- Prompt format and active plugin list determined with follow-up audit. No private dotfiles copied.

## 02 — Follow-up audit (30 Oct)

- Active plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`. `you-should-use` present but inactive.
- Starship: `$hostname$time$all`, explicit date `%d.%m.%Y %H:%M:%S`, two lines; cyan hostname, yellow time, green arrow.
- History: `HISTSIZE=50000`, `SAVEHIST=10000`, duplicate filtering, shared and extended history, AUTO_CD.

## 03 — Installer v4 and separate user (30–31 Oct)

- Fixed offline-test environment inheritance from `STARSHIP_CONFIG`/`ZDOTDIR`.
- Test user `ac-shell-test` (UID 1002) initially had `/bin/bash`, no sudo membership.
- User ran `sh test-shell.sh`: `OFFLINE_TESTS_OK`.
- User ran `sh run-local-user-lab.sh`: Oh My Zsh and both plugins installed from upstream; Starship **1.27.0** verified, configs and lock written.
- Second install reused repositories/config and preserved version lock; verification printed `VERIFY_OK` and overall **`LAB_PASS`**.
- Initial interactive Zsh run from another user's Downloads directory warned about Starship directory scanning. Starting from `/home/ac-shell-test` cleared the warning.
- User changed login shell and verified `USER=ac-shell-test`, `SHELL=/usr/bin/zsh`, `CURRENT_SHELL=-zsh`, `HOME=/home/ac-shell-test`, and Starship 1.27.0.

## 04 — Clean VM (31 Oct)

- Host: QEMU/KVM available, 4 CPU threads, `/home` nearly full. Isolated lab stored on `/var/lib/ac-shell-lab` (root filesystem), not on `/home`.
- Existing Woodpecker/ejabberd QEMU VM remained running and untouched.
- Guest: Ubuntu 24.04 release cloud image, official SHA-256 matched (`ubuntu-24.04-server-cloudimg-amd64.img: OK`). 1 vCPU, 1 GiB RAM, 8 GiB sparse qcow2, SSH port `127.0.0.1:22224`.
- Guest initially timed out during SSH banner while boot/configuration continued. Subsequent test waited for cloud-init and succeeded.
- Guest installed Starship 1.27.0 and Git plugins in **latest mode**, `verify` passed; second non-latest install reused all existing state; interactive Zsh/history check passed; final output **`LAB_VM_PASS`**.
- VM `status` originally attempted `qemu-img info` without read-sharing, yielding a shared write-lock warning while VM was running. The public lab script uses `qemu-img info -U` for read-only status on live VM; this fix remains to be tested on the user's host.

## 05 — Public repository preparation (31 Oct)

- Created a publication-ready source tree with documentation, `.gitignore`, and GitHub Actions offline test matrix.
- No secrets, SSH private keys, local images, personal `.zshrc` or `starship.toml` are included.
- Cross-version GitHub Actions, default (non-latest) clean installation, arm64 integration and recovery/rollback remain unverified.

## 06 — Public initial commit and GitHub Actions (31 Oct)

- Created public repository `alteredcarbonllc/ac-shell`, initial main commit [`3dd5f0b`](https://github.com/alteredcarbonllc/ac-shell/commit/3dd5f0b41dcb558b2dfc667c3487a691328cf297) contains the 12 source, test and documentation files.
- [GitHub Actions run #1](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141291341) triggered by that push, completed with `success`.
- All three matrix jobs passed: `Offline ubuntu-22.04`, `Offline ubuntu-24.04`, `Offline ubuntu-26.04`, including syntax and offline regression tests.
- [GitHub Actions run #2](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141430383), triggered by documentation commit `09ecd09`, also completed with `success`.
- CI currently **does not** perform a full network installation or login-shell integration test. The confirmed complete network install remains the separate Ubuntu 24.04 QEMU/KVM VM test (`LAB_VM_PASS`).

## 07 — MIT license and three-language documentation (31 Oct)

- Owner approved **MIT License** for project-owned code and documentation, with `Copyright (c) 2026 Altered Carbon LLC`.
- English documents remain at repository root; Ukrainian translations are in `docs/uk/` and Russian translations in `docs/ru/`. The authoritative `LICENSE` remains in English.
- All documentation entry points include language navigation. Installer functionality is unchanged.
- The `v0.1.0` tag is **not** created yet; a published-tag installation test remains pending.

## 08 — Pinned installation in existing Ubuntu 24.04 lab VM (31 Oct)

- On the **already running** Ubuntu 24.04 QEMU/KVM guest, created a **fresh** ordinary user `ac-shell-pinned` with no prior shell configuration.
- Transferred the exact `ac-shell-setup.sh` from the repository checkout, then ran `plan`, `install` **without `--latest`**, and `verify` under the new user.
- Confirmed Starship **1.27.0**, audited Oh My Zsh commit `0eeaa529bb1442c2934930a5820f596e678458d4`, autosuggestions commit `0e810e5afa27acbd074398eefbe28d13005dbc15`, and syntax-highlighting commit `5eb677bb0fa9a3e60f0eff031dc13926e093df92`.
- Repeated `install` and `verify`: repositories reused, dotfiles unchanged, no downgrade, `VERIFY_OK`.
- Interactive `zsh -ic` returned `PINNED_ZSH_OK`; overall user-observed result **`PINNED_LAB_PASS`**.
- Scope: clean **user account inside an existing configured VM**, not a newly rebuilt OS or an installation downloaded from a published Git tag. The pinned-tag one-command end-to-end test remains pending.

## 09 — Published v0.1.0 tag and installation from GitHub (31 Oct)

- Published annotated Git tag `v0.1.0` (tag object `15dad8d0a932d5fffb42d28e5950312be785856b`, peeled commit `b88ed432da8f1264d6c7ae712a542cf90e63076a`); the tag was **not moved** after publication.
- Downloaded `ac-shell-setup.sh` from `https://raw.githubusercontent.com/alteredcarbonllc/ac-shell/v0.1.0/ac-shell-setup.sh` and compared it byte-for-byte with `git show v0.1.0:ac-shell-setup.sh`: `TAGGED_INSTALLER_MATCH=YES`.
- Downloaded install script SHA-256: `4925bdcba07bea531442347d1bcaa8159f3c48c17435140517d0635632be41f9`.
- Created **fresh** `ac-shell-release` account in the already-running Ubuntu 24.04 lab guest. Downloaded the installer from the published tag as this account, executed `install` (pinned), then `verify`, yielding `VERIFY_OK`.
- Confirmed Starship 1.27.0, all pinned Oh My Zsh/plugin revisions, unchanged configuration template, Zsh `RELEASE_ZSH_OK`, history values `HISTSIZE=50000 SAVEHIST=10000`, and overall **`RELEASE_TAG_LAB_PASS`**.
- Login shell was switched inside the disposable guest using administrative `usermod`; the installer's interactive `--set-default-shell` (`chsh`) pathway and the entire README one-liner have **not** been tested end to end.
- This validates a **published Git tag and installer**, not yet the separately created **GitHub Release** record.

## Next actions

- Publish the GitHub Release record for the existing immutable `v0.1.0` tag using the prepared multilingual release notes.
- Independently test the installer's `--set-default-shell` / `chsh` flow under a disposable account; do not imply it passed earlier.
- Consider adding a CI end-to-end network-installation matrix and authenticated source checksums in a subsequent release.
- Keep separate infrastructure mapping in `ac-infrastructure` only after a separate approved change, not as a side effect of this project.
