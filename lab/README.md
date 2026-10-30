# Optional laboratory runners

## Existing separate user

`run-local-user-lab.sh` uses an already-created `ac-shell-test` Ubuntu user with an **empty configuration** and preinstalled host packages. It refuses to touch an already-provisioned user, does not modify the host's login shell, and does not run host apt operations.

```sh
sh lab/run-local-user-lab.sh
```

## QEMU/KVM clean Ubuntu 24.04

Requires `qemu-system-x86_64`, `qemu-img`, `cloud-localds`, SSH, curl, KVM and at least ~1.5 GiB MemAvailable / 10 GiB free disk (hard check). The host script owns only `/var/lib/ac-shell-lab` and port `127.0.0.1:22224`; it never deletes disks or kills other VMs. Do **not** use if an unrelated lab already uses that directory or port.

```sh
sudo install -d -m 0700 -o "$(id -un)" -g "$(id -gn)" /var/lib/ac-shell-lab
sh lab/ac-shell-vm-lab.sh prepare
sh lab/ac-shell-vm-lab.sh start
sh lab/ac-shell-vm-lab.sh test
sh lab/ac-shell-vm-lab.sh status
```

To request graceful shutdown: `sh lab/ac-shell-vm-lab.sh stop`. Shutdown is asynchronous; inspect status after the guest stops. **No automatic cleanup.** Disk/image deletion is always a separate deliberate administrative action.

The host runner verifies Canonical's published `SHA256SUMS`, not the GPG-signed checksums; signed provenance verification is a future improvement. The private lab SSH key remains under `/var/lib/ac-shell-lab` and is never checked into Git.

A first SSH connection may fail while cloud-init runs; `test` explicitly waits for cloud-init before installation.
