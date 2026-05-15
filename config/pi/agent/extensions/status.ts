import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

const exec_file = promisify(execFile);

async function git_status(cwd: string) {
  try {
    const branch = (await exec_file('git', ['branch', '--show-current'], { cwd })).stdout.trim();
    const porcelain = (await exec_file('git', ['status', '--porcelain'], { cwd })).stdout.trim();
    return `${branch || 'detached'}${porcelain ? ' dirty' : ' clean'}`;
  } catch {
    return 'no git';
  }
}

export default function (pi: ExtensionAPI) {
  async function update(ctx: { cwd: string; ui: { setStatus: (key: string, value: string) => void } }) {
    ctx.ui.setStatus('git', await git_status(ctx.cwd));
  }

  pi.on('session_start', async (_event, ctx) => {
    await update(ctx);
  });

  pi.on('agent_end', async (_event, ctx) => {
    await update(ctx);
  });
}
