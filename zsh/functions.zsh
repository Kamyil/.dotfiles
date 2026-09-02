# Live-editable shell functions shared by macOS and NixOS.

_dotfiles_theme_load() {
  local state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-theme"
  if [[ ! -r "$state_dir/current/theme.zsh" ]]; then
    command "$HOME/.dotfiles/scripts/theme" kanagawa-paper >/dev/null
  fi
  source "$state_dir/current/theme.zsh"
  export FZF_DEFAULT_OPTS=" \
  --multi \
  --height=70% \
  --margin=5%,2%,2%,5% \
  --layout=reverse \
  --border=top \
  --info=inline \
  --prompt='$>' \
  --pointer='→' \
  --marker='♡' \
  --header='CTRL-c or ESC to quit' \
  --preview 'bat --style=numbers --color=always --line-range :500 {}' \
  $FZF_THEME_OPTS"
  export FZF_POKKE_OPTS="$FZF_THEME_OPTS"
}

theme() {
  command "$HOME/.dotfiles/scripts/theme" "${1:-toggle}" || return
  _dotfiles_theme_load
}

_dotfiles_theme_load

gpom() {
  local remote_head branch
  remote_head="$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  branch="${remote_head#origin/}"

  if [[ "$branch" != main && "$branch" != master ]]; then
    if git ls-remote --exit-code --heads origin main >/dev/null 2>&1; then
      branch=main
    elif git ls-remote --exit-code --heads origin master >/dev/null 2>&1; then
      branch=master
    else
      print -u2 "gpom: origin has neither a main nor master branch"
      return 1
    fi
  fi

  git pull origin "$branch" "$@"
}

_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd) fzf "$@" --preview 'tree -C {} | head -200' ;;
    *) fzf "$@" ;;
  esac
}

weather() {
  curl "wttr.in/$1?lang=pl"
}

unalias wgu wgd 2>/dev/null

_dotfiles_wireguard_interface() {
  local action=$1
  local iface=$2

  if [[ -z "$iface" ]]; then
    if command -v fzf >/dev/null 2>&1; then
      iface=$(print -rl -- /etc/wireguard/*.conf(N:t:r) /usr/local/etc/wireguard/*.conf(N:t:r) | sort -u | fzf --prompt="WireGuard $action > ")
    else
      print -u2 "Usage: wg${action[1]} <interface>"
      return 1
    fi
  fi

  [[ -n "$iface" ]] || return 1
  print -r -- "$iface"
}

wgu() {
  local iface
  iface=$(_dotfiles_wireguard_interface up "$1") || return
  sudo WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick up "$iface" || return
  if [[ "$iface" == malinka ]]; then
    sudo /usr/bin/touch /var/run/wireguard/malinka.desired-active
  fi
}

wgd() {
  local iface
  iface=$(_dotfiles_wireguard_interface down "$1") || return
  if [[ "$iface" == malinka ]]; then
    # User intent wins even when runtime cleanup is already partially broken.
    sudo /bin/rm -f /var/run/wireguard/malinka.desired-active
  fi
  sudo WG_QUICK_USERSPACE_IMPLEMENTATION=wireguard-go wg-quick down "$iface"
}

SD_BASE_DIRS=(
  "$HOME/Work/Projects"
  "$HOME/Personal/Projects"
  "$HOME/.ssh"
)
SD_DEPTH=1
C_BASE_DIRS=("$HOME/.dotfiles")
C_CACHE_FILE="$HOME/.cache/dotfiles-config-files"

unalias c 2>/dev/null

sd() {
  local dirs=()
  local base dir selected

  for base in "${SD_BASE_DIRS[@]}"; do
    if [[ -d "$base" ]]; then
      while IFS= read -r dir; do
        dirs+=("$dir")
      done < <(find "$base" -mindepth 1 -maxdepth "$SD_DEPTH" -type d 2>/dev/null)
    fi
  done

  if [[ -f "$HOME/.zsh_company_dirs" ]]; then
    source "$HOME/.zsh_company_dirs"
    dirs+=("${COMPANY_DIRS[@]}")
  fi
  if [[ -f "$HOME/.zsh_personal_dirs" ]]; then
    source "$HOME/.zsh_personal_dirs"
    dirs+=("${PERSONAL_DIRS[@]}")
  fi

  selected=$(printf '%s\n' "${dirs[@]}" | fzf)
  [[ -n "$selected" ]] && cd "$selected"
}

c() {
  local cache="$C_CACHE_FILE"
  local cache_dir="${cache:h}"
  local selected
  mkdir -p "$cache_dir"

  refresh_cache() {
    local tmp="${cache}.tmp.$$"
    local base
    : > "$tmp" || return 1
    for base in "${C_BASE_DIRS[@]}"; do
      [[ -d "$base" ]] || continue
      find "$base" -type f ! -path '*/.git/*' ! -path '*/target/*' >> "$tmp" 2>/dev/null
    done
    mv "$tmp" "$cache"
  }

  if [[ ! -s "$cache" ]]; then
    refresh_cache || return 1
  else
    refresh_cache &
  fi

  selected=$(fzf < "$cache")
  [[ -n "$selected" ]] || return 0
  [[ -f "$selected" ]] || {
    print -u2 "Selected file no longer exists: $selected"
    return 1
  }
  cd "${selected:h}" || return
  nvim "${selected:t}"
}

sshf() {
  local selected_host
  selected_host=$(awk '/^Host / {print $2}' "$HOME/.ssh/config" | fzf)
  [[ -n "$selected_host" ]] && ssh "$selected_host"
}

remote_sshfs() {
  local ssh_alias remote_dir mount_point
  ssh_alias=$(awk '/^Host / {print $2}' "$HOME/.ssh/config" | fzf)
  if [[ -z "$ssh_alias" ]]; then
    print -u2 'No alias selected!'
    return 1
  fi

  remote_dir=$(ssh "$ssh_alias" 'find / -maxdepth 1 -type d' | fzf)
  if [[ -z "$remote_dir" ]]; then
    print -u2 'No directory selected!'
    return 1
  fi

  mount_point="$HOME/remote-repos/$ssh_alias"
  mkdir -p "$mount_point"
  print -r -- "Mounting $remote_dir..."
  sshfs -F "$HOME/.ssh/config" "$ssh_alias:$remote_dir" "$mount_point"
  print -r -- 'Attaching to Docker container...'
  ssh "$ssh_alias" "cd ${(q)remote_dir} && docker compose exec app bash"
  nvim "$mount_point"
  print -r -- "Unmounting $remote_dir..."
  unmount_sshfs "$mount_point"
}

sdn() { sd && nvim . }
sdo() { sd && omp }

db() {
  source "$HOME/.zsh_db_configs"
  local config_keys=("${(k)DB_CONFIGS[@]}")
  local selected_key
  selected_key=$(printf '%s\n' "${config_keys[@]}" | fzf)
  [[ -n "$selected_key" ]] && eval "${DB_CONFIGS[$selected_key]}"
}

work_sites() {
  source "$HOME/.zsh_company_websites"
  local company_website_keys=("${(k)COMPANY_WEBSITES[@]}")
  local selected_key
  selected_key=$(printf '%s\n' "${company_website_keys[@]}" | fzf)
  [[ -n "$selected_key" ]] && open_url "${COMPANY_WEBSITES[$selected_key]}"
}

switch_branch() {
  git fetch -a
  local selected_branch
  selected_branch=$(git branch --list | fzf)
  [[ -n "$selected_branch" ]] && git checkout "$selected_branch"
}

hisf() {
  local commands_history_entries selected_command_from_history
  commands_history_entries=$(history | sed 's/.[ ]*.[0-9]*.[ ]*//' | uniq)
  selected_command_from_history=$(printf '%s\n' "${commands_history_entries[@]}" | fzf)
  [[ -n "$selected_command_from_history" ]] && eval "$selected_command_from_history"
}

killf() {
  ps aux | fzf --preview='' --prompt='Select process to kill: ' | awk '{print $2}' | xargs -r kill -9
}

color_palette() {
  local i
  for i in {0..255}; do
    print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f ${${(M)$((i%6)):#3}:+$'\n'}"
  done
}

sb() {
  cd "$HOME/second-brain/" && nvim .
}
