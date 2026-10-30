#!/bin/sh
# Offline tests for non-installing codepaths; no package installation/network.
set -eu
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
installer="$script_dir/ac-shell-setup.sh"
work=$(mktemp -d)
trap 'rm -rf "$work"' 0
sh -n "$installer"
sh "$installer" render-starship > "$work/starship.toml"
sh "$installer" render-zshrc > "$work/zshrc"
sh "$installer" render-starship | cmp -s - "$work/starship.toml"
sh "$installer" render-zshrc | cmp -s - "$work/zshrc"
grep -Fqx "format = '\$hostname\$time\$all'" "$work/starship.toml"
grep -Fqx 'time_format = '\''%d.%m.%Y %H:%M:%S'\''' "$work/starship.toml"
grep -Fqx 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' "$work/zshrc"
! grep -q 'plugins=.*you-should-use' "$work/zshrc"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$work/starship.toml" <<'PY'
import sys
try:
    import tomllib
except ImportError:
    raise SystemExit(0)
with open(sys.argv[1], 'rb') as f:
    c = tomllib.load(f)
assert c['format'] == '$hostname$time$all'
assert c['time']['disabled'] is False
assert c['time']['time_format'] == '%d.%m.%Y %H:%M:%S'
assert c['hostname']['trim_at'] == ''
assert c['package']['disabled'] is True
PY
fi
mkdir "$work/home"
env -u ZDOTDIR -u STARSHIP_CONFIG HOME="$work/home" sh "$installer" plan > "$work/plan.txt"
[ -z "$(ls -A "$work/home")" ]
grep -Fqx 'No changes made. Run install to apply.' "$work/plan.txt"
if env -u ZDOTDIR -u STARSHIP_CONFIG HOME="$work/home" sh "$installer" verify > "$work/verify.txt" 2>&1; then
  echo 'FAIL: verify unexpectedly accepted an empty home' >&2
  exit 1
fi
grep -Fqx 'VERIFY_FAILED' "$work/verify.txt"
# Prevent regression: exported nondefault variables must not poison isolated test.
STARSHIP_CONFIG=/tmp/foreign-config ZDOTDIR=/tmp/foreign-zdot sh "$installer" render-starship >/dev/null
printf '%s\n' 'OFFLINE_TESTS_OK' 
