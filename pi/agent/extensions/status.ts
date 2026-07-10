import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

const exec_file = promisify(execFile);

type GitStatus = {
  branch: string;
  staged: number;
  unstaged: number;
  untracked: number;
  ahead: number;
  behind: number;
};

async function git_status(cwd: string): Promise<GitStatus | undefined> {
  try {
    const { stdout } = await exec_file('git', ['status', '--porcelain=v1', '--branch'], { cwd });
    const lines = stdout.trim().split('\n').filter(Boolean);
    const header = lines.shift() ?? '';
    const branch = header.match(/^## ([^\.]+)/)?.[1] || 'detached';
    const ahead = Number(header.match(/ahead (\d+)/)?.[1] ?? 0);
    const behind = Number(header.match(/behind (\d+)/)?.[1] ?? 0);

    let staged = 0;
    let unstaged = 0;
    let untracked = 0;

    for (const line of lines) {
      const index = line[0];
      const worktree = line[1];

      if (index === '?' && worktree === '?') {
        untracked++;
        continue;
      }

      if (index !== ' ' && index !== '?') staged++;
      if (worktree !== ' ' && worktree !== '?') unstaged++;
    }

    return { branch, staged, unstaged, untracked, ahead, behind };
  } catch {
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  async function update(ctx: { cwd: string; ui: { theme: any; setStatus: (key: string, value: string | undefined) => void } }) {
    const status = await git_status(ctx.cwd);
    const theme = ctx.ui.theme;

    if (!status) {
      ctx.ui.setStatus('git', theme.fg('muted', 'no git'));
      return;
    }

    const parts = [theme.fg('accent', ` ${status.branch}`)];

    if (status.ahead > 0) parts.push(theme.fg('mdLink', `↑${status.ahead}`));
    if (status.behind > 0) parts.push(theme.fg('thinkingHigh', `↓${status.behind}`));
    if (status.staged > 0) parts.push(theme.fg('success', `+${status.staged}`));
    if (status.unstaged > 0) parts.push(theme.fg('warning', `~${status.unstaged}`));
    if (status.untracked > 0) parts.push(theme.fg('mdCode', `?${status.untracked}`));
    if (parts.length === 1) parts.push(theme.fg('success', '✓'));

    ctx.ui.setStatus('git', parts.join(theme.fg('dim', ' ')));
  }

  pi.on('session_start', async (_event, ctx) => {
    await update(ctx);
  });

  pi.on('agent_end', async (_event, ctx) => {
    await update(ctx);
  });
}
