import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

const dangerous_patterns = [
  /\bsudo\b/,
  /\brm\s+(-[^\s]*[rf][^\s]*|--recursive|--force)/,
  /\bchmod\s+(-R\s+)?777\b/,
  /\bchown\s+-R\b/,
  /\bmkfs\b/,
  /\bdd\s+.*\bof=/,
  /\bgit\s+(reset\s+--hard|clean\s+-[dfx])/,
  /\bgit\s+push\s+--force/,
  /\bnixos-rebuild\s+switch\b/,
  /\bdarwin-rebuild\s+switch\b/,
];

export default function (pi: ExtensionAPI) {
  pi.on('tool_call', async (event, ctx) => {
    if (event.toolName !== 'bash') return;

    const input = event.input as { command?: string };
    const command = input.command ?? '';
    if (!dangerous_patterns.some((pattern) => pattern.test(command))) return;

    if (!ctx.hasUI) {
      return { block: true, reason: 'Blocked dangerous command in non-interactive mode.' };
    }

    const ok = await ctx.ui.confirm('Confirm Command', `Run this command?\n\n${command}`);
    if (!ok) return { block: true, reason: 'User denied command.' };
  });
}
