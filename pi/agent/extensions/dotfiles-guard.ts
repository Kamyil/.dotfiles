import path from 'node:path';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

const repo_roots = [
  '/Users/kamil/.dotfiles',
  '/home/kamil/.dotfiles',
];

const protected_fragments = [
  '/.env',
  '/.git/',
  '/node_modules/',
  '/.direnv/',
  '/result',
];

function normalize(target: string, cwd: string) {
  return path.resolve(target.startsWith('~') ? target.replace(/^~/, process.env.HOME ?? '') : path.isAbsolute(target) ? target : path.join(cwd, target));
}

function is_write_tool(tool_name: string) {
  return tool_name === 'write' || tool_name === 'edit';
}

export default function (pi: ExtensionAPI) {
  pi.on('tool_call', async (event, ctx) => {
    if (!is_write_tool(event.toolName)) return;

    const input = event.input as { path?: string; filePath?: string };
    const raw_path = input.path ?? input.filePath;
    if (!raw_path) return;

    const full_path = normalize(raw_path, ctx.cwd);
    const in_dotfiles = repo_roots.some((root) => full_path === root || full_path.startsWith(`${root}/`));
    const protected_path = protected_fragments.some((fragment) => full_path.includes(fragment));

    if (protected_path) {
      return { block: true, reason: `Refusing to edit protected path: ${full_path}` };
    }

    if (ctx.cwd.includes('/.dotfiles') && !in_dotfiles) {
      if (!ctx.hasUI) return { block: true, reason: `Refusing to edit outside dotfiles: ${full_path}` };

      const ok = await ctx.ui.confirm('Outside Dotfiles', `Allow edit outside dotfiles?\n\n${full_path}`);
      if (!ok) return { block: true, reason: `User denied edit outside dotfiles: ${full_path}` };
    }
  });
}
