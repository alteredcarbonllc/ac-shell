# Development history and verification ledger

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
- CI currently **does not** perform a full network installation or login-shell integration test. The confirmed complete network install remains the separate Ubuntu 24.04 QEMU/KVM VM test (`LAB_VM_PASS`).

## Next actions

- Choose LICENSE explicitly; do not imply a license from public visibility.
- Publish a reviewed `v0.1.0` tag only when ready; test pinned one-line installation after tag.
- Keep separate infrastructure mapping in `ac-infrastructure` only after a separate approved change, not as a side effect of this project.
