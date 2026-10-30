#!/bin/sh
# Test installation against the existing unprivileged ac-shell-test account.
# Run this as your regular sudo-capable Ubuntu account (e.g. kyiv).
set -eu
TARGET=ac-shell-test
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
INSTALLER="$HERE/../ac-shell-setup.sh"

[ "$(id -u)" -ne 0 ] || { echo 'ERROR: do not run this orchestrator as root' >&2; exit 1; }
command -v sudo >/dev/null 2>&1 || { echo 'ERROR: sudo is required' >&2; exit 1; }
[ -f "$INSTALLER" ] || { echo 'ERROR: missing ac-shell-setup.sh' >&2; exit 1; }
entry=$(getent passwd "$TARGET") || { echo "ERROR: user $TARGET not found" >&2; exit 1; }
TARGET_HOME=$(printf '%s\n' "$entry" | cut -d: -f6)
[ "$TARGET_HOME" = "/home/$TARGET" ] || { echo "ERROR: unexpected test home $TARGET_HOME" >&2; exit 1; }
[ -d "$TARGET_HOME" ] || { echo "ERROR: test home does not exist" >&2; exit 1; }

missing=''
for pkg in zsh git curl ca-certificates python3 fzf zoxide ripgrep fd-find mosh; do
  if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -qx 'install ok installed'; then
    missing="$missing $pkg"
  fi
done
if [ -n "$missing" ]; then
  echo "ERROR: missing host packages:$missing" >&2
  echo "Install as your admin user, then rerun: sudo apt-get update && sudo apt-get install$missing" >&2
  exit 1
fi

# The test user cannot sudo; package management is intentionally out of scope.
for path in "$TARGET_HOME/.zshrc" "$TARGET_HOME/.config/starship.toml" "$TARGET_HOME/.oh-my-zsh" "$TARGET_HOME/.local/bin/starship"; do
  if sudo test -e "$path"; then
    echo "ERROR: existing installation at $path; refusing to overwrite a test user's files" >&2
    exit 1
  fi
done

sudo install -o "$TARGET" -g "$TARGET" -m 0755 "$INSTALLER" "$TARGET_HOME/ac-shell-setup.sh"

run_as_test_user() {
  sudo -u "$TARGET" -H env -u STARSHIP_CONFIG -u ZDOTDIR \
    sh "$TARGET_HOME/ac-shell-setup.sh" "$@"
}

echo '=== LAB: PLAN ==='
run_as_test_user plan
echo '=== LAB: INSTALL (latest stable) ==='
run_as_test_user install --latest
echo '=== LAB: VERIFY ==='
run_as_test_user verify
echo '=== LAB: SECOND INSTALL (must honor lock, no downgrade) ==='
run_as_test_user install
echo '=== LAB: SECOND VERIFY ==='
run_as_test_user verify
echo '=== LAB: LOGIN SHELL CHECK (unchanged) ==='
getent passwd "$TARGET" | cut -d: -f1,6,7
sudo -u "$TARGET" -H env -u STARSHIP_CONFIG -u ZDOTDIR \
  zsh -ic 'print -r -- "INTERACTIVE_ZSH_OK"; print -r -- "HISTSIZE=$HISTSIZE SAVEHIST=$SAVEHIST"; [[ -o sharehistory && -o autocd && -o extendedhistory ]] || exit 7' 
echo 'LAB_PASS'
