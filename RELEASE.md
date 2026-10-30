# Publication checklist (initial release)

The initial public repo is a source **release candidate**. Do not publish `v0.1.0` or advertise the one-line installation URL until the first Actions run succeeds and the owner has reviewed licensing.

1. Create the new **public** `alteredcarbonllc/ac-shell` repository, push the audited tree.
2. Inspect `.github/workflows/offline-tests.yml` and watch the matrix across `ubuntu-22.04`, `ubuntu-24.04`, `ubuntu-26.04`.
3. Review dependencies, third-party license terms and select a license (not chosen by this package).
4. Create signed (preferred) or annotated `v0.1.0` tag from a reviewed commit, push the tag, and verify GitHub raw URL returns the expected script.
5. Test the one-command deployment on a **fresh, unprivileged** Ubuntu user.
6. Keep exact test results and follow-up failures in `DEVELOPMENT_HISTORY.md`, with commit references.
