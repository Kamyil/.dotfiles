import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent';

function format_tokens(tokens: number): string {
  if (tokens >= 1_000_000) return `${(tokens / 1_000_000).toFixed(1)}m`;
  if (tokens >= 10_000) return `${Math.round(tokens / 1_000)}k`;
  if (tokens >= 1_000) return `${(tokens / 1_000).toFixed(1)}k`;
  return String(tokens);
}

function update_context_status(ctx: ExtensionContext) {
  const usage = typeof (ctx as any).getContextUsage === 'function' ? (ctx as any).getContextUsage() : undefined;
  const theme = ctx.ui.theme;

  if (!usage) {
    ctx.ui.setStatus('context', undefined);
    return;
  }

  const input_tokens = Number(usage.inputTokens || usage.tokens || 0);
  const output_tokens = Number(usage.outputTokens || 0);
  const context_length = Number(usage.contextLength || 0);
  const percent = context_length > 0 ? Math.round((input_tokens / context_length) * 100) : 0;
  const tone = percent >= 85 ? 'error' : percent >= 65 ? 'warning' : 'mdCode';

  const parts = [
    theme.fg('accent', '󰍛 ctx'),
    theme.fg(tone, context_length > 0 ? `${format_tokens(input_tokens)}/${format_tokens(context_length)}` : format_tokens(input_tokens)),
    theme.fg(tone, `${percent}%`),
  ];

  if (output_tokens > 0) parts.push(theme.fg('muted', `out ${format_tokens(output_tokens)}`));

  ctx.ui.setStatus('context', parts.join(theme.fg('dim', ' · ')));
}

export default function (pi: ExtensionAPI) {
  pi.on('session_start', async (_event, ctx) => update_context_status(ctx));
  pi.on('message_end', async (_event, ctx) => update_context_status(ctx));
  pi.on('agent_end', async (_event, ctx) => update_context_status(ctx));
  pi.on('model_select', async (_event, ctx) => update_context_status(ctx));
}
