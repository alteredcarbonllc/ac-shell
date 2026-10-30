#!/bin/sh
# Altered Carbon Shell: isolated Ubuntu 24.04 cloud-image VM smoke laboratory.
# Run as normal host user. Does not manage any VM outside /var/lib/ac-shell-lab.
set -eu
umask 077

ROOT=/var/lib/ac-shell-lab
VM_NAME=ac-shell-lab-v1
PORT=22224
RAM_MIB=1024
IMAGE=ubuntu-24.04-server-cloudimg-amd64.img
IMAGE_URL=https://cloud-images.ubuntu.com/releases/noble/release
HERE=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)

say() { printf '%s\n' "$*"; }
fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
usage() {
  cat <<'EOF'
Altered Carbon Shell isolated QEMU lab
  sh ac-shell-vm-lab.sh prepare    # download & checksum Ubuntu image, build disk and cloud-init seed
  sh ac-shell-vm-lab.sh start      # start only ac-shell-lab-v1 on 127.0.0.1:22224
  sh ac-shell-vm-lab.sh status     # report VM state (read-only)
  sh ac-shell-vm-lab.sh ssh        # SSH to lab (first boot may require time)
  sh ac-shell-vm-lab.sh test       # transfer and run ac-shell v4 in disposable guest
  sh ac-shell-vm-lab.sh stop       # request guest ACPI poweroff; no forced kill

Before prepare, create the dedicated directory from your normal account:
  sudo install -d -m 0700 -o "$(id -un)" -g "$(id -gn)" /var/lib/ac-shell-lab

Requirements on host: qemu-system-x86_64, qemu-img, cloud-localds,
  curl, sha256sum, ssh, ssh-keygen, scp, python3. No libvirt required.
Guest uses 1 vCPU, 1024 MiB RAM, 8 GiB sparse qcow2, Ubuntu 24.04.
Guest gets a dedicated SSH key and guest-only passwordless sudo.
This script never deletes disk images or other VM files.
EOF
}

check_root() {
  [ "$(id -u)" -ne 0 ] || fail 'run as kyiv (ordinary user), NOT root'
  [ -d "$ROOT" ] || fail "create $ROOT first using the documented sudo install -d command"
  owner=$(stat -c '%u' "$ROOT")
  [ "$owner" = "$(id -u)" ] || fail "$ROOT is not owned by this user"
  [ ! -L "$ROOT" ] || fail "$ROOT must not be a symlink"
  [ "$(stat -c '%a' "$ROOT")" = 700 ] || fail "$ROOT must have mode 700"
}
require() {
  for prog in "$@"; do
    command -v "$prog" >/dev/null 2>&1 || fail "missing command: $prog"
  done
}

is_running() {
  [ -f "$ROOT/qemu.pid" ] || return 1
  pid=$(cat "$ROOT/qemu.pid")
  case "$pid" in ''|*[!0-9]*) return 1 ;; esac
  [ -r "/proc/$pid/cmdline" ] || return 1
  # Ensure we never act on any unrelated QEMU process after stale PID reuse.
  tr '\000' '\n' < "/proc/$pid/cmdline" | grep -Fx -- "$VM_NAME" >/dev/null 2>&1
}

ssh_common() {
  [ -f "$ROOT/id_ed25519" ] || fail 'lab key not found; run prepare'
  # Argument vector is forwarded unchanged; no user-provided shell expansion.
  ssh -i "$ROOT/id_ed25519" \
    -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="$ROOT/known_hosts" \
    -o ConnectTimeout=10 -p "$PORT" lab@127.0.0.1 "$@"
}

prepare() {
  require curl sha256sum qemu-img cloud-localds ssh-keygen awk df
  if [ -e "$ROOT/system.qcow2" ] || [ -e "$ROOT/seed.img" ]; then
    fail 'disk/seed already exists; refusing to overwrite (use status or start)'
  fi
  free_kb=$(df -Pk "$ROOT" | awk 'NR==2 {print $4}')
  [ "$free_kb" -ge 10485760 ] || fail 'less than 10 GiB filesystem free; refusing to create lab'

  say '=== FETCH OFFICIAL UBUNTU RELEASE + SHA256 ==='
  curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
    "$IMAGE_URL/SHA256SUMS" -o "$ROOT/SHA256SUMS.part"
  mv "$ROOT/SHA256SUMS.part" "$ROOT/SHA256SUMS"
  if [ ! -s "$ROOT/$IMAGE" ]; then
    curl --fail --location --retry 3 --proto '=https' --tlsv1.2 \
      "$IMAGE_URL/$IMAGE" -o "$ROOT/$IMAGE.part"
    mv "$ROOT/$IMAGE.part" "$ROOT/$IMAGE"
  fi
  awk -v file="$IMAGE" '{name=$2; sub(/^\*/, "", name); if (name==file) {print; found=1}} END {if(!found)exit 1}' \
    "$ROOT/SHA256SUMS" > "$ROOT/selected-image.sha256" || fail 'checksum for chosen image missing'
  (cd "$ROOT" && sha256sum --check selected-image.sha256) || fail 'image checksum mismatch; refusing VM creation'

  if [ ! -f "$ROOT/id_ed25519" ]; then
    ssh-keygen -q -t ed25519 -N '' -C ac-shell-lab -f "$ROOT/id_ed25519"
  fi
  [ -f "$ROOT/id_ed25519.pub" ] || fail 'SSH public key absent'
  key=$(cat "$ROOT/id_ed25519.pub")
  case "$key" in ssh-ed25519\ *) : ;; *) fail 'unexpected SSH key type' ;; esac

  say '=== CLOUD-INIT: CREATE DISPOSABLE LAB USER ==='
  cat > "$ROOT/meta-data" <<'EOF'
instance-id: ac-shell-lab-noble-v1
local-hostname: ac-shell-lab
EOF
  cat > "$ROOT/user-data" <<'EOF'
#cloud-config
hostname: ac-shell-lab
manage_etc_hosts: true
disable_root: true
ssh_pwauth: false
users:
  - name: lab
    gecos: AC Shell Laboratory
    shell: /bin/bash
    lock_passwd: true
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    ssh_authorized_keys:
EOF
  printf '      - %s\n' "$key" >> "$ROOT/user-data"
  cat >> "$ROOT/user-data" <<'EOF'
package_update: true
package_upgrade: false
packages:
  - openssh-server
  - openssh-client
  - sudo
  - git
  - zsh
  - curl
  - ca-certificates
  - python3
  - fzf
  - zoxide
  - ripgrep
  - fd-find
  - mosh
  - unzip
EOF
  cloud-localds "$ROOT/seed.img" "$ROOT/user-data" "$ROOT/meta-data"
  qemu-img create -f qcow2 -F qcow2 -b "$ROOT/$IMAGE" "$ROOT/system.qcow2" 8G
  say 'PREPARE_OK'
  say "LAB_DIR=$ROOT"
  say 'NEXT: sh ac-shell-vm-lab.sh start'
}

start() {
  require qemu-system-x86_64 ss awk tr grep
  [ -s "$ROOT/system.qcow2" ] && [ -s "$ROOT/seed.img" ] || fail 'run prepare first'
  [ -r /dev/kvm ] && [ -w /dev/kvm ] || fail 'KVM unavailable to this user'
  if is_running; then
    say "ALREADY_RUNNING pid=$(cat "$ROOT/qemu.pid")"
    return
  fi
  if ss -H -lnt "( sport = :$PORT )" | grep -q .; then
    fail "TCP port $PORT is already in use"
  fi
  avail_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo)
  [ "$avail_kb" -ge 1572864 ] || fail 'less than 1.5 GiB available RAM; close other workloads first'
  # Remove only stale control files inside our OWN lab after confirming it's stopped.
  rm -f -- "$ROOT/monitor.sock" "$ROOT/qemu.pid"
  qemu-system-x86_64 \
    -name "$VM_NAME" -machine q35,accel=kvm -cpu host \
    -smp 1 -m "$RAM_MIB" \
    -drive "file=$ROOT/system.qcow2,if=virtio,format=qcow2" \
    -drive "file=$ROOT/seed.img,if=virtio,format=raw,readonly=on" \
    -netdev "user,id=net0,hostfwd=tcp:127.0.0.1:$PORT-:22" \
    -device virtio-net-pci,netdev=net0 \
    -display none -serial "file:$ROOT/console.log" \
    -monitor "unix:$ROOT/monitor.sock,server=on,wait=off" \
    -pidfile "$ROOT/qemu.pid" -daemonize
  is_running || fail 'QEMU did not remain running; inspect console.log'
  say "START_OK pid=$(cat "$ROOT/qemu.pid") ssh=127.0.0.1:$PORT"
  say 'Cloud-init will configure guest SSH and apt packages on first boot.'
  say 'NEXT: sh ac-shell-vm-lab.sh status'
}

status() {
  require qemu-img
  if is_running; then
    say "VM_RUNNING pid=$(cat "$ROOT/qemu.pid")"
  else
    say 'VM_NOT_RUNNING'
  fi
  if [ -f "$ROOT/system.qcow2" ]; then
    if is_running; then
      qemu-img info -U "$ROOT/system.qcow2" | grep -E '^(file format:|virtual size:|disk size:|backing file:)' || true
    else
      qemu-img info "$ROOT/system.qcow2" | grep -E '^(file format:|virtual size:|disk size:|backing file:)' || true
    fi
  fi
  df -h "$ROOT"
  say 'For guest access: sh ac-shell-vm-lab.sh ssh'
}

run_test() {
  require ssh scp
  source_script="$HERE/../ac-shell-setup.sh"
  [ -f "$source_script" ] || fail 'cannot find ../ac-shell-setup.sh in this source checkout' 
  is_running || fail 'start lab VM first'
  say '=== WAIT FOR GUEST CLOUD-INIT ==='
  ssh_common 'cloud-init status --wait && dpkg-query -W zsh git curl fzf zoxide ripgrep fd-find mosh >/dev/null'
  say '=== COPY INSTALLER (TO GUEST ONLY) ==='
  scp -q -i "$ROOT/id_ed25519" \
    -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile="$ROOT/known_hosts" -P "$PORT" \
    "$source_script" lab@127.0.0.1:ac-shell-setup.sh
  say '=== GUEST INSTALL + VERIFY + REINSTALL + VERIFY ==='
  ssh_common 'sh -s' <<'GUEST'
set -eu
sh "$HOME/ac-shell-setup.sh" plan
sh "$HOME/ac-shell-setup.sh" install --latest
sh "$HOME/ac-shell-setup.sh" verify
sh "$HOME/ac-shell-setup.sh" install
sh "$HOME/ac-shell-setup.sh" verify
sudo usermod --shell /usr/bin/zsh lab
test "$(getent passwd lab | cut -d: -f7)" = /usr/bin/zsh
zsh -ic 'print -r -- "GUEST_INTERACTIVE_ZSH_OK"; print -r -- "HISTSIZE=$HISTSIZE SAVEHIST=$SAVEHIST"; [[ -o sharehistory && -o autocd && -o extendedhistory ]]'
echo LAB_VM_PASS
GUEST
}

stop() {
  require python3
  is_running || fail 'lab VM is not running'
  [ -S "$ROOT/monitor.sock" ] || fail 'lab monitor socket unavailable'
  python3 - "$ROOT/monitor.sock" <<'PY'
import socket, sys
s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
s.settimeout(5)
s.connect(sys.argv[1])
s.sendall(b'system_powerdown\n')
s.close()
PY
  say 'POWERDOWN_REQUESTED (ACPI); use status to confirm shutdown'
}

case "${1:-help}" in
  help|-h|--help) usage ;;
  prepare) check_root; prepare ;;
  start) check_root; start ;;
  status) check_root; status ;;
  ssh) check_root; shift; ssh_common "$@" ;;
  test) check_root; run_test ;;
  stop) check_root; stop ;;
  *) usage; exit 2 ;;
esac
