#!/bin/sh
# Altered Carbon Shell v4 — reproduce the *audited* Ubuntu Zsh/Starship profile.
# POSIX sh entry point. Run as the target user, not via sudo.
set -eu
umask 077

VERSION=4
STARSHIP_VERSION=1.27.0
OMZ_REF=0eeaa529bb1442c2934930a5820f596e678458d4
AUTOSUGGESTIONS_REF=0e810e5
SYNTAX_HIGHLIGHT_REF=5eb677b

usage() {
  cat <<'EOF'
Altered Carbon Shell v4
  sh ac-shell-setup.sh plan
  sh ac-shell-setup.sh install [--latest] [--replace] [--set-default-shell]
  sh ac-shell-setup.sh verify
  sh ac-shell-setup.sh render-starship
  sh ac-shell-setup.sh render-zshrc

Run as the intended ordinary Ubuntu user, NOT with sudo.
--latest: on a NEW account, resolve the latest stable Starship release and
          latest default-branch revisions of Oh My Zsh and both plugins.
          Existing installations are not silently upgraded.
--replace: back up and replace existing .zshrc / starship.toml and a mismatched
           local Starship binary. Oh My Zsh/plugin Git repositories at a different
           revision are NEVER modified automatically.
--set-default-shell: use chsh to change the account's login shell to zsh.

The install avoids changing an existing unmanaged profile unless --replace is used.
It does not copy personal dotfiles, aliases, credentials, or external sourced files.
It installs fzf/zoxide tools but does not enable their unconfirmed shell hooks.
EOF
}

render_starship() {
  cat <<'EOF'
# AC-SHELL-MANAGED v4
# Audited Ubuntu reference: 2026-10-30, Starship 1.27.0 (patched)
format = '$hostname$time$all'
add_newline = true

[hostname]
ssh_only = false
format = '[$hostname]($style) '
style = 'bold cyan'
trim_at = ''
disabled = false

[time]
disabled = false
time_format = '%d.%m.%Y %H:%M:%S'
format = '[$time]($style) '
style = 'bold yellow'

[character]
success_symbol = '[➜](bold green)'

[package]
disabled = true
EOF
}

render_zshrc() {
  cat <<'EOF'
# AC-SHELL-MANAGED v4
# Replicates the *confirmed* active plugins and history options from Ubuntu laptop.
export PATH="$HOME/.local/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
zstyle ':omz:update' mode disabled
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source "$ZSH/oh-my-zsh.sh"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS SHARE_HISTORY EXTENDED_HISTORY AUTO_CD
unsetopt HIST_IGNORE_ALL_DUPS INC_APPEND_HISTORY CORRECT

# Leave fzf and zoxide integrations disabled until verified on the reference host.
eval "$(starship init zsh)"
EOF
}

MODE=${1:-help}
[ "$#" -eq 0 ] || shift
REPLACE=no
SET_DEFAULT_SHELL=no
LATEST=no
case "$MODE" in
  help|-h|--help) usage; exit 0 ;;
  render-starship) [ "$#" -eq 0 ] || { usage >&2; exit 2; }; render_starship; exit 0 ;;
  render-zshrc) [ "$#" -eq 0 ] || { usage >&2; exit 2; }; render_zshrc; exit 0 ;;
  plan|install|verify) : ;;
  *) usage >&2; exit 2 ;;
esac
for arg in "$@"; do
  case "$arg" in
    --replace) [ "$MODE" = install ] || { usage >&2; exit 2; }; REPLACE=yes ;;
    --latest) [ "$MODE" = install ] || { usage >&2; exit 2; }; LATEST=yes ;;
    --set-default-shell) [ "$MODE" = install ] || { usage >&2; exit 2; }; SET_DEFAULT_SHELL=yes ;;
    *) usage >&2; exit 2 ;;
  esac
done

fail() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
[ -n "${HOME:-}" ] && [ -d "$HOME" ] || fail 'HOME directory is unavailable'
RC="${ZDOTDIR:-$HOME}/.zshrc"
STAR="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
OMZ="$HOME/.oh-my-zsh"
PLUGINS="$OMZ/custom/plugins"
LOCAL_BIN="$HOME/.local/bin"
STARBIN="$LOCAL_BIN/starship"
AC_STATE="$HOME/.config/ac-shell"
LOCK="$AC_STATE/versions.tsv"
[ ! -L "$LOCK" ] || fail "symlink at version lock: $LOCK"

[ -z "${ZDOTDIR:-}" ] || [ "$ZDOTDIR" = "$HOME" ] || fail 'non-default ZDOTDIR; refusing to manage configuration'
[ -z "${STARSHIP_CONFIG:-}" ] || [ "$STARSHIP_CONFIG" = "$HOME/.config/starship.toml" ] || fail 'non-default STARSHIP_CONFIG; refusing to manage configuration'

if [ "$MODE" = plan ]; then
  printf 'Target user: %s\n' "$(id -un)"
  printf 'Zsh config: %s\nStarship config: %s\n' "$RC" "$STAR"
  for file in "$RC" "$STAR" "$STARBIN" "$OMZ"; do
    if [ -e "$file" ] || [ -L "$file" ]; then printf 'EXISTS: %s\n' "$file"; else printf 'NEW: %s\n' "$file"; fi
  done
  printf 'Pinned: Starship %s; Oh My Zsh %s; autosuggestions %s; highlighting %s\n' \
    "$STARSHIP_VERSION" "$OMZ_REF" "$AUTOSUGGESTIONS_REF" "$SYNTAX_HIGHLIGHT_REF"
  printf '%s\n' 'Optional: install --latest for newest stable Starship + current Oh My Zsh/plugin commits'
  printf '%s\n' 'Active plugins: git, zsh-autosuggestions, zsh-syntax-highlighting'
  printf '%s\n' 'No changes made. Run install to apply.'
  exit 0
fi

verify() {
  errors=0
  printf '%s\n' '=== AC-SHELL v4 VERIFY ==='
  expected_version=$(lock_value starship)
  if [ -x "$STARBIN" ]; then
    actual=$("$STARBIN" --version 2>/dev/null | awk 'NR==1 {print $2}')
    if [ -n "$expected_version" ] && [ "$actual" = "$expected_version" ]; then
      printf 'OK starship version: %s\n' "$actual"
    else
      printf 'FAIL starship version: expected %s, found %s\n' "${expected_version:-NO_LOCK}" "$actual"
      errors=1
    fi
  else
    printf 'FAIL: no executable at %s\n' "$STARBIN"; errors=1
  fi
  if [ -f "$RC" ] && render_zshrc | cmp -s - "$RC"; then
    printf '%s\n' 'OK .zshrc matches audited template'
  else
    printf '%s\n' 'FAIL .zshrc differs or is absent'; errors=1
  fi
  if [ -f "$STAR" ] && render_starship | cmp -s - "$STAR"; then
    printf '%s\n' 'OK starship.toml matches audited template'
  else
    printf '%s\n' 'FAIL starship.toml differs or is absent'; errors=1
  fi
  if command -v zsh >/dev/null 2>&1 && [ -f "$RC" ]; then
    if zsh -n "$RC"; then printf '%s\n' 'OK .zshrc syntax'; else errors=1; fi
  else
    printf '%s\n' 'FAIL zsh unavailable'; errors=1
  fi
  for pair in \
    "$OMZ|$(lock_value ohmyzsh)" \
    "$PLUGINS/zsh-autosuggestions|$(lock_value autosuggestions)" \
    "$PLUGINS/zsh-syntax-highlighting|$(lock_value syntaxhighlight)"; do
    path=${pair%%|*}
    ref=${pair#*|}
    if [ -d "$path/.git" ]; then
      have=$(git -C "$path" rev-parse HEAD 2>/dev/null || :)
      case "$have" in
        "$ref") if [ -n "$ref" ]; then printf 'OK revision: %s\n' "$path"; else printf 'FAIL empty lock: %s\n' "$path"; errors=1; fi ;;
        *) printf 'FAIL revision: %s (have %s, need %s)\n' "$path" "$have" "$ref"; errors=1 ;;
      esac
    else
      printf 'FAIL repo missing: %s\n' "$path"; errors=1
    fi
  done
  if command -v python3 >/dev/null 2>&1 && [ -f "$STAR" ]; then
    if python3 - "$STAR" <<'PY'
import sys
try:
    import tomllib
except ImportError:
    raise SystemExit(0)
with open(sys.argv[1], 'rb') as fh:
    tomllib.load(fh)
PY
    then printf '%s\n' 'OK Starship TOML syntax'; else errors=1; fi
  fi
  if [ "$errors" -ne 0 ]; then
    printf '%s\n' 'VERIFY_FAILED'
    return 1
  fi
  printf '%s\n' 'VERIFY_OK'
}

lock_value() {
  key=$1
  if [ -f "$LOCK" ]; then
    awk -F '\t' -v key="$key" '$1 == key { print $2; exit }' "$LOCK"
  fi
}

if [ "$MODE" = verify ]; then verify; exit $?; fi

[ "$(id -u)" -ne 0 ] || fail 'install as the desired non-root user; do not run via sudo'
# Latest chooses components at first install; do not silently update existing installations.
if [ "$LATEST" = yes ] && [ -e "$LOCK" ]; then
  echo 'EXISTING_INSTALLATION: --latest will not upgrade an installed account; verifying pinned components'
  verify
  exit $?
fi
# Re-installs always honor the recorded release, even if a later installer has
# a different default. This prevents accidental downgrade after --latest.
if [ -f "$LOCK" ]; then
  locked_version=$(lock_value starship)
  printf '%s\n' "$locked_version" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+$' || fail 'invalid Starship version in lock'
  STARSHIP_VERSION=$locked_version
fi
[ -r /etc/os-release ] || fail '/etc/os-release unavailable'
# shellcheck disable=SC1091
. /etc/os-release
[ "${ID:-}" = ubuntu ] || fail "Ubuntu only (found ${ID:-unknown})"
[ ! -L "$RC" ] && [ ! -L "$STAR" ] && [ ! -L "$STARBIN" ] && [ ! -L "$OMZ" ] || fail 'symlink at a managed destination; refusing'
for file in "$RC" "$STAR"; do
  if [ -e "$file" ] && [ "$REPLACE" != yes ]; then
    if ! grep -Eq '^# AC-SHELL-MANAGED v4$' "$file"; then
      fail "existing unmanaged config: $file (use --replace with backup after reviewing)"
    fi
  fi
done
if [ -e "$STARBIN" ] && [ "$REPLACE" != yes ]; then
  have=$("$STARBIN" --version 2>/dev/null | awk 'NR==1 {print $2}' || :)
  expected=$(lock_value starship)
  [ -n "$expected" ] && [ "$have" = "$expected" ] || fail "existing local Starship version $have; use --replace to back it up"
fi

# Do not touch pre-existing Oh My Zsh Git checkouts at unexpected revisions.
check_revision() {
  target=$1
  expected=$2
  if [ -e "$target" ] && [ -n "$expected" ]; then
    [ -d "$target/.git" ] || fail "existing non-Git directory $target"
    actual=$(git -C "$target" rev-parse HEAD 2>/dev/null || :)
    [ "$actual" = "$expected" ] || fail "revision mismatch: $target at $actual (expected $expected); inspect manually"
  fi
}
if [ "$LATEST" = yes ]; then
  # Avoid mixing a fresh --latest run with unmanaged existing repositories.
  for path in "$OMZ" "$PLUGINS/zsh-autosuggestions" "$PLUGINS/zsh-syntax-highlighting"; do
    [ ! -e "$path" ] && [ ! -L "$path" ] || fail "--latest requires fresh Git checkout: $path"
  done
else
  check_revision "$OMZ" "$(lock_value ohmyzsh || :)"
  check_revision "$PLUGINS/zsh-autosuggestions" "$(lock_value autosuggestions || :)"
  check_revision "$PLUGINS/zsh-syntax-highlighting" "$(lock_value syntaxhighlight || :)"
  # For new stable installations there is no lock yet; check against audited refs.
  if [ ! -f "$LOCK" ]; then
    # Audited short SHAs are accepted by prefix only for the initial install.
    for item in "$OMZ|$OMZ_REF" "$PLUGINS/zsh-autosuggestions|$AUTOSUGGESTIONS_REF" "$PLUGINS/zsh-syntax-highlighting|$SYNTAX_HIGHLIGHT_REF"; do
      path=${item%%|*}; prefix=${item#*|}
      if [ -e "$path" ]; then
        [ -d "$path/.git" ] || fail "existing non-Git directory: $path"
        actual=$(git -C "$path" rev-parse HEAD 2>/dev/null || :)
        case "$actual" in "$prefix"*) : ;; *) fail "revision mismatch: $path expected prefix $prefix" ;; esac
      fi
    done
  fi
fi

# Install dependencies only when missing. Extras are optional if not in a release.
CORE='zsh git curl ca-certificates python3'
EXTRAS='fzf zoxide ripgrep fd-find mosh'
missing_core=''
missing_extras=''
for pkg in $CORE; do
  if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -qx 'install ok installed'; then
    missing_core="$missing_core $pkg"
  fi
done
for pkg in $EXTRAS; do
  if ! dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -qx 'install ok installed'; then
    missing_extras="$missing_extras $pkg"
  fi
done
if [ -n "$missing_core$missing_extras" ]; then
  command -v sudo >/dev/null 2>&1 || fail 'sudo required to install apt packages; install the dependencies first'
  sudo apt-get update
  if [ -n "$missing_core" ]; then
    # Intentionally split whitespace-separated package names.
    # shellcheck disable=SC2086
    sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y $missing_core
  fi
  for pkg in $missing_extras; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      sudo env DEBIAN_FRONTEND=noninteractive apt-get install -y "$pkg"
    else
      printf 'WARNING: optional apt package unavailable: %s\n' "$pkg" >&2
    fi
  done
fi
command -v zsh >/dev/null 2>&1 || fail 'zsh not installed'
command -v git >/dev/null 2>&1 || fail 'git not installed'
command -v curl >/dev/null 2>&1 || fail 'curl not installed'

mkdir -p "$LOCAL_BIN" "$HOME/.config"
WORK=$(mktemp -d "$HOME/.ac-shell-v4.XXXXXXXX")
trap 'rm -rf "$WORK"' 0
trap 'exit 1' 1 2 3 15

# Fetch newest stable release in latest mode; fail closed if unavailable.
if [ "$LATEST" = yes ]; then
  curl --fail --location --silent --show-error --retry 3 --proto '=https' --tlsv1.2 \
    'https://api.github.com/repos/starship/starship/releases/latest' -o "$WORK/latest.json"
  STARSHIP_VERSION=$(python3 - "$WORK/latest.json" <<'PYLATEST'
import json, re, sys
with open(sys.argv[1], encoding='utf8') as fh:
    data = json.load(fh)
tag = data.get('tag_name', '')
if not re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+', tag) or data.get('prerelease') or data.get('draft'):
    raise SystemExit('ERROR: invalid/latest release is not stable')
print(tag[1:])
PYLATEST
  )
fi

clone_at_ref() {
  url=$1
  target=$2
  revision=$3
  key=$4
  if [ -d "$target/.git" ]; then
    printf 'REUSE: %s\n' "$target"
    return 0
  fi
  staged="$WORK/repo-$key"
  if [ "$LATEST" = yes ]; then
    git clone --quiet --depth 1 "$url" "$staged"
  else
    git clone --quiet "$url" "$staged"
    git -C "$staged" checkout --quiet --detach "$revision"
  fi
  actual=$(git -C "$staged" rev-parse HEAD)
  if [ "$LATEST" != yes ]; then
    case "$actual" in "$revision"*) : ;; *) fail "Git checkout mismatch for $url" ;; esac
  fi
  mkdir -p "$(dirname "$target")"
  mv "$staged" "$target"
  printf 'INSTALLED: %s (%s)\n' "$target" "$actual"
}
clone_at_ref 'https://github.com/ohmyzsh/ohmyzsh.git' "$OMZ" "$OMZ_REF" omz
clone_at_ref 'https://github.com/zsh-users/zsh-autosuggestions.git' "$PLUGINS/zsh-autosuggestions" "$AUTOSUGGESTIONS_REF" autosuggest
clone_at_ref 'https://github.com/zsh-users/zsh-syntax-highlighting.git' "$PLUGINS/zsh-syntax-highlighting" "$SYNTAX_HIGHLIGHT_REF" highlight
[ -f "$OMZ/oh-my-zsh.sh" ] || fail 'Oh My Zsh incomplete'
[ -f "$PLUGINS/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ] || fail 'autosuggestions missing'
[ -f "$PLUGINS/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ] || fail 'syntax highlighting missing'

# Official GitHub release archive + published SHA256; no curl|sh execution.
if [ ! -x "$STARBIN" ] || [ "$("$STARBIN" --version 2>/dev/null | awk 'NR==1 {print $2}' || :)" != "$STARSHIP_VERSION" ]; then
  case "$(uname -m)" in
    x86_64) TARGET='x86_64-unknown-linux-musl' ;;
    aarch64) TARGET='aarch64-unknown-linux-musl' ;;
    *) fail 'Starship install supports x86_64/aarch64 only' ;;
  esac
  url="https://github.com/starship/starship/releases/download/v$STARSHIP_VERSION/starship-$TARGET.tar.gz"
  curl --fail --location --silent --show-error --retry 3 --proto '=https' --tlsv1.2 "$url" -o "$WORK/starship.tar.gz"
  curl --fail --location --silent --show-error --retry 3 --proto '=https' --tlsv1.2 "$url.sha256" -o "$WORK/starship.tar.gz.sha256"
  checksum=$(tr -d '\r\n ' < "$WORK/starship.tar.gz.sha256")
  printf '%s\n' "$checksum" | grep -Eq '^[0-9a-fA-F]{64}$' || fail 'invalid upstream SHA256 checksum'
  printf '%s  %s\n' "$checksum" "$WORK/starship.tar.gz" | sha256sum -c --status || fail 'Starship SHA256 mismatch'
  tar -xzf "$WORK/starship.tar.gz" -C "$WORK" starship
  [ -f "$WORK/starship" ] || fail 'downloaded Starship archive lacks executable'
  chmod 755 "$WORK/starship"
  have=$("$WORK/starship" --version | awk 'NR==1 {print $2}')
  [ "$have" = "$STARSHIP_VERSION" ] || fail "downloaded Starship version $have != $STARSHIP_VERSION"
  if [ -e "$STARBIN" ]; then
    backup="$STARBIN.before-ac-shell-v4.$(date -u +%Y%m%dT%H%M%SZ).$$"
    cp -p "$STARBIN" "$backup"
    printf 'BACKUP: %s\n' "$backup"
  fi
  mv "$WORK/starship" "$STARBIN"
fi

render_zshrc > "$WORK/.zshrc"
render_starship > "$WORK/starship.toml"
zsh -n "$WORK/.zshrc" || fail 'generated .zshrc failed syntax validation'
python3 - "$WORK/starship.toml" <<'PY'
import sys
try:
    import tomllib
except ImportError:
    raise SystemExit(0)
with open(sys.argv[1], 'rb') as fh:
    tomllib.load(fh)
PY

apply_file() {
  src=$1
  dest=$2
  if [ -f "$dest" ] && cmp -s "$src" "$dest"; then
    printf 'UNCHANGED: %s\n' "$dest"
    return 0
  fi
  if [ -e "$dest" ]; then
    backup="$dest.before-ac-shell-v4.$(date -u +%Y%m%dT%H%M%SZ).$$"
    cp -p "$dest" "$backup"
    printf 'BACKUP: %s\n' "$backup"
  fi
  chmod 600 "$src"
  mv "$src" "$dest"
  printf 'WRITTEN: %s\n' "$dest"
}
apply_file "$WORK/.zshrc" "$RC"
apply_file "$WORK/starship.toml" "$STAR"

mkdir -p "$AC_STATE"
if [ ! -e "$LOCK" ]; then
  printf 'starship\t%s\nohmyzsh\t%s\nautosuggestions\t%s\nsyntaxhighlight\t%s\n' \
    "$STARSHIP_VERSION" \
    "$(git -C "$OMZ" rev-parse HEAD)" \
    "$(git -C "$PLUGINS/zsh-autosuggestions" rev-parse HEAD)" \
    "$(git -C "$PLUGINS/zsh-syntax-highlighting" rev-parse HEAD)" \
    > "$WORK/versions.tsv"
  chmod 600 "$WORK/versions.tsv"
  mv "$WORK/versions.tsv" "$LOCK"
  printf 'LOCK_WRITTEN: %s\n' "$LOCK"
fi

if [ "$SET_DEFAULT_SHELL" = yes ]; then
  command -v chsh >/dev/null 2>&1 || fail 'chsh unavailable; login shell unchanged'
  chsh -s "$(command -v zsh)" "$(id -un)"
  printf '%s\n' 'LOGIN_SHELL_CHANGE_REQUESTED'
else
  printf '%s\n' 'LOGIN_SHELL_UNCHANGED'
fi
verify
printf '%s\n' 'AC_SHELL_V4_INSTALLED=YES'
printf '%s\n' 'Start an interactive session: exec zsh'
