# Altered Carbon Shell (`ac-shell`)

**Language:** English · [Українська](docs/uk/README.md) · [Русский](docs/ru/README.md)

Reproducible **Ubuntu user shell** based on the audited Altered Carbon laptop environment (30 October 2026). Written as a portable `sh` installer, with Oh My Zsh and a Starship prompt.

**Repository status:** versioned Git tag [`v0.1.0`](https://github.com/alteredcarbonllc/ac-shell/tree/v0.1.0) published and tested in a disposable Ubuntu 24.04 guest; the separately listed GitHub Release entry is pending. Successful full Ubuntu 24.04 QEMU/KVM lab run (30–31 Oct 2026; `LAB_VM_PASS`). The first two GitHub Actions runs ([#1](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141291341), [#2](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141430383)) passed syntax/offline regression tests on Ubuntu 22.04 / 24.04 / 26.04. CI has **not** yet tested end-to-end network installation. Other operating systems are not yet supported. This is a user-shell installer, **not** a server bootstrap/deployment framework.

## One-command installation (published v0.1.0 tag)

From a regular, sudo-capable Ubuntu account, install a **reviewable, versioned script**; do not run the installer itself as root:

```sh
sudo apt-get update && sudo apt-get install -y curl ca-certificates && curl -fL --proto '=https' --tlsv1.2 -o ac-shell-v0.1.0.sh https://raw.githubusercontent.com/alteredcarbonllc/ac-shell/v0.1.0/ac-shell-setup.sh && printf '%s  %s\n' '4925bdcba07bea531442347d1bcaa8159f3c48c17435140517d0635632be41f9' ac-shell-v0.1.0.sh | sha256sum -c - && sh ac-shell-v0.1.0.sh install --set-default-shell
```

`v0.1.0` above is a **published, annotated Git tag** pinned to commit `b88ed432da8f1264d6c7ae712a542cf90e63076a`. The downloaded installer was confirmed byte-for-byte against that tag (SHA-256 `4925bdcba07bea531442347d1bcaa8159f3c48c17435140517d0635632be41f9`); a fresh guest user passed `RELEASE_TAG_LAB_PASS`. The complete one-liner including `--set-default-shell` / `chsh` has **not** yet been separately tested; the guest login shell was changed with `usermod`. Pin the version (or exact commit) so the installer cannot silently change. The pinned SHA-256 in the command prevents execution if the downloaded script differs from the tested `v0.1.0` file. The command is maintained in `main`; the historical tag's files are frozen. Inspect `ac-shell-v0.1.0.sh` before running when using a new release. Re-login after changing the login shell; `exec zsh` starts the new prompt only in the current terminal.

For **newest stable versions at first installation**, replace the final command with `sh ac-shell-v0.1.0.sh install --latest --set-default-shell`. This retrieves the latest stable Starship release and current default-branch revisions of Oh My Zsh and plugins, then records the exact resolved versions. Repeated installs do not automatically upgrade; use pinned mode on production for reproducibility.

If you already cloned the repository:

```sh
sh test-shell.sh
sh ac-shell-setup.sh plan
sh ac-shell-setup.sh install --set-default-shell
sh ac-shell-setup.sh verify
```

See [INSTALL.md](INSTALL.md) for safety, options and limitations, [DEVELOPMENT_HISTORY.md](DEVELOPMENT_HISTORY.md) for test evidence, [SECURITY.md](SECURITY.md) for dependencies and reporting, [RELEASE.md](RELEASE.md) for release procedures, and [lab/README.md](lab/README.md) for disposable lab testing.

## Reproduced features

- Zsh + Oh My Zsh; only **active** audited plugins: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- Starship `format = '$hostname$time$all'`; cyan hostname; yellow `DD.MM.YYYY HH:MM:SS`; standard modules including git/Python/duration as applicable; green `➜`; two-line prompt; package module disabled.
- `HISTSIZE=50000`, `SAVEHIST=10000`, `HIST_IGNORE_DUPS`, `SHARE_HISTORY`, `EXTENDED_HISTORY`, `AUTO_CD`; `CORRECT` disabled.
- Apt packages for Zsh/Git, and available helper tools `fzf`, `zoxide`, `ripgrep`, `fd-find`, `mosh`. Unconfirmed fzf/zoxide hooks are **not** enabled. `you-should-use` was installed on the laptop but inactive and is excluded.
- Personal aliases, secrets, custom sourced scripts, local font files and system Python version are deliberately **not** copied.

The hostname and current directory depend on the machine; the exact visual appearance also depends on terminal font/emoji support. The Python version shown in the prompt is the Python actually available, not a version forced by this project.

## Source layout

```text
ac-shell-setup.sh                  POSIX sh installer / plan / verify / render
 test-shell.sh                      Offline regression suite
 test-docs.py                        Multilingual docs and links check
 lab/run-local-user-lab.sh         Test installation under a dedicated existing user
 lab/ac-shell-vm-lab.sh            Isolated QEMU/KVM Ubuntu 24.04 lab
 .github/workflows/offline-tests.yml  Offline CI across Ubuntu 22.04/24.04/26.04
```

## License

Project-owned code and documentation are released under the **MIT License** (Copyright © 2026 Altered Carbon LLC). See the canonical [LICENSE](LICENSE) text. Third-party dependencies retain their own licenses.
