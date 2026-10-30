# Initial release checklist

**Language:** English · [Українська](docs/uk/RELEASE.md) · [Русский](docs/ru/RELEASE.md)

The repository is public, but versioned release `v0.1.0` **has not been published**.

1. **Done:** Create public `alteredcarbonllc/ac-shell`, push the reviewed source tree to `main`.
2. **Done:** Confirm GitHub Actions run [#1](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141291341) and [#2](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141430383) succeeded on `ubuntu-22.04`, `ubuntu-24.04`, and `ubuntu-26.04`. This is **offline regression testing**, not end-to-end network installation.
3. **Done:** Select MIT License for project-owned code and documentation. Review third-party dependency licenses separately.
4. **Pending:** Review installer, documentation, security limitations and local/remote Git synchronization.
5. **Pending:** Create a signed (preferred) or annotated `v0.1.0` tag from a reviewed commit; push it and verify the tagged raw installer URL.
6. **Pending:** Test a fresh, unprivileged Ubuntu user's one-line installation **from the published tag**.
7. Record exact test results, failures and commit hashes in [DEVELOPMENT_HISTORY.md](DEVELOPMENT_HISTORY.md).

Do not advertise the tagged one-command installation as functional until the tag exists and the command has been tested.
