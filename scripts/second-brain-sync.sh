#!/usr/bin/env bash
# Commit, rebase and push ~/second-brain against its upstream (Malinka).
# Run on a timer by nix/home/second-brain-sync.nix; safe to run by hand.
# Unreachable remote: exits quietly and retries next run.
# Conflict: aborts the rebase, keeps local commits, and sends a notification.
set -euo pipefail

repo="${SECOND_BRAIN_DIR:-$HOME/second-brain}"

export GIT_TERMINAL_PROMPT=0
export GIT_SSH_COMMAND="ssh -o BatchMode=yes -o ConnectTimeout=10"

log() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*"; }

notify() {
	log "$1"
	case "$(uname -s)" in
	Darwin)
		/usr/bin/osascript -e "display notification \"$1\" with title \"second-brain sync\"" >/dev/null 2>&1 || true
		;;
	*)
		command -v notify-send >/dev/null 2>&1 && notify-send -u critical "second-brain sync" "$1" || true
		;;
	esac
}

[ -d "$repo/.git" ] || {
	log "no git repository at $repo, skipping"
	exit 0
}
cd "$repo"

git_dir="$(git rev-parse --absolute-git-dir)"
lock="$git_dir/second-brain-sync.lock"
mkdir "$lock" 2>/dev/null || {
	log "another sync is running"
	exit 0
}
trap 'rmdir "$lock"' EXIT

if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ] || [ -f "$git_dir/MERGE_HEAD" ]; then
	notify "Rebase or merge in progress in $repo. Finish it by hand."
	exit 1
fi

branch="$(git symbolic-ref --quiet --short HEAD)" || {
	notify "Detached HEAD in $repo. Check out a branch."
	exit 1
}
upstream="$(git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}')" || {
	notify "Branch $branch has no upstream."
	exit 1
}
remote="${upstream%%/*}"

git add --all
if ! git diff --cached --quiet; then
	git commit --quiet --no-verify -m "sync: $(uname -n) $(date '+%Y-%m-%d %H:%M')"
	log "committed local changes"
fi

if ! git fetch --quiet "$remote"; then
	log "$remote unreachable, will retry"
	exit 0
fi

if ! git rebase --quiet "$upstream"; then
	git rebase --abort || true
	notify "Conflict with $upstream. Local commits kept; resolve by hand."
	exit 1
fi

if [ "$(git rev-list --count "$upstream..HEAD")" -gt 0 ]; then
	git push --quiet "$remote" "HEAD:$branch"
	log "pushed to $upstream"
fi
