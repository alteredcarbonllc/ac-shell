# Initial release checklist

**Language:** English · [Українська](docs/uk/RELEASE.md) · [Русский](docs/ru/RELEASE.md)

The **annotated Git tag** `v0.1.0` and the [GitHub Release](https://github.com/alteredcarbonllc/ac-shell/releases/tag/v0.1.0) are published. The published-tag installer passed its lab test.

1. **Done:** Create public `alteredcarbonllc/ac-shell`, push the reviewed source tree to `main`.
2. **Done:** Confirm GitHub Actions run [#1](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141291341) and [#2](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141430383) succeeded on `ubuntu-22.04`, `ubuntu-24.04`, and `ubuntu-26.04`. This is **offline regression testing**, not end-to-end network installation.
3. **Done:** Select MIT License for project-owned code and documentation. Review third-party dependency licenses separately.
4. **Done:** Confirm Ubuntu 24.04 VM `LAB_VM_PASS`, clean-user pinned test `PINNED_LAB_PASS`, and published-tag installation `RELEASE_TAG_LAB_PASS` (without testing `chsh`).
5. **Done:** Publish annotated `v0.1.0` tag pointing at commit `b88ed432da8f1264d6c7ae712a542cf90e63076a`. The tagged installer was byte-for-byte verified with SHA-256 `4925bdcba07bea531442347d1bcaa8159f3c48c17435140517d0635632be41f9`.
6. **Done (limited):** Downloaded and installed the published-tag script under a fresh VM user; `verify` and interactive Zsh passed. **Pending:** Test the full README one-liner including `--set-default-shell` / interactive `chsh` and missing-dependency provisioning on a clean system.
7. **Done:** Publish the [GitHub Release](https://github.com/alteredcarbonllc/ac-shell/releases/tag/v0.1.0) for the annotated tag. **Pending:** synchronize its live description with the [three-language notes including the SHA-256 installation command](releases/v0.1.0.md); do not move the tag.
8. Record exact test results, failures and commit hashes in [DEVELOPMENT_HISTORY.md](DEVELOPMENT_HISTORY.md).

The tagged script's download/install path is verified; do not claim interactive `chsh` or the entire one-liner is verified until those additional tests pass.
