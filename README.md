# Altered Carbon Shell (`ac-shell`)

Reproducible **Ubuntu user shell** based on the audited Altered Carbon laptop environment (30 October 2026). Written as a portable `sh` installer, with Oh My Zsh and a Starship prompt.

**Repository status:** public-release candidate. Successful full Ubuntu 24.04 QEMU/KVM lab run (30–31 Oct 2026); GitHub Actions across Ubuntu 22.04 / 24.04 / 26.04 are configured but require execution after publication. Other operating systems are not yet supported. This is a user-shell installer, **not** a server bootstrap/deployment framework.

## One-command installation (after first release)

From a regular, sudo-capable Ubuntu account, install a **reviewable, versioned script**; do not run the installer itself as root:

```sh
sudo apt-get update && sudo apt-get install -y curl && curl -fL --proto '=https' --tlsv1.2 -o ac-shell-setup.sh https://raw.githubusercontent.com/alteredcarbonllc/ac-shell/v0.1.0/ac-shell-setup.sh && sh ac-shell-setup.sh install --set-default-shell
```

`v0.1.0` above is the **planned tag, not a published release yet**. Once published, pin the version (or exact commit) so the installer cannot silently change. Inspect `ac-shell-setup.sh` before running when using a new release. Re-login after changing the login shell; `exec zsh` starts the new prompt only in the current terminal.

For **newest stable versions at first installation**, replace the final command with `sh ac-shell-setup.sh install --latest --set-default-shell`. This retrieves the latest stable Starship release and current default-branch revisions of Oh My Zsh and plugins, then records the exact resolved versions. Repeated installs do not automatically upgrade; use pinned mode on production for reproducibility.

If you already cloned the repository:

```sh
sh test-shell.sh
sh ac-shell-setup.sh plan
sh ac-shell-setup.sh install --set-default-shell
sh ac-shell-setup.sh verify
```

See [INSTALL.md](INSTALL.md) for safety, options and limitations, [DEVELOPMENT_HISTORY.md](DEVELOPMENT_HISTORY.md) for test evidence, and [SECURITY.md](SECURITY.md) for dependencies and reporting.

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
 lab/run-local-user-lab.sh         Test installation under a dedicated existing user
 lab/ac-shell-vm-lab.sh            Isolated QEMU/KVM Ubuntu 24.04 lab
 .github/workflows/offline-tests.yml  Offline CI across Ubuntu 22.04/24.04/26.04
```

**Visibility vs licensing:** public repository visibility does not automatically grant an open-source license. A license has **not** yet been selected; the owner must choose it before encouraging redistribution or external contributions.
