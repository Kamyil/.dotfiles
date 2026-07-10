import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent';

const levels = ['off', 'minimal', 'low', 'medium', 'high', 'xhigh'] as const;
type ThinkingLevel = (typeof levels)[number];

function next_level(current: string): ThinkingLevel {
  const index = levels.indexOf(current as ThinkingLevel);
  return levels[(index + 1) % levels.length];
}

function set_status(pi: ExtensionAPI, ctx: ExtensionContext) {
  ctx.ui.setStatus('thinking', `thinking ${pi.getThinkingLevel()}`);
}

function set_level(pi: ExtensionAPI, ctx: ExtensionContext, level: ThinkingLevel) {
  const before = pi.getThinkingLevel();
  pi.setThinkingLevel(level);
  const after = pi.getThinkingLevel();
  set_status(pi, ctx);

  if (after !== level) {
    ctx.ui.notify(`Thinking: ${before} → ${after} (clamped by current model)`, 'info');
    return;
  }

  ctx.ui.notify(`Thinking: ${before} → ${after}`, 'info');
}

export default function (pi: ExtensionAPI) {
  pi.on('session_start', async (_event, ctx) => {
    set_status(pi, ctx);
  });

  pi.on('thinking_level_select', async (_event, ctx) => {
    set_status(pi, ctx);
  });

  pi.registerCommand('thinking', {
    description: 'Cycle or set thinking level: off|minimal|low|medium|high|xhigh',
    handler: async (args, ctx) => {
      const requested = args.trim() as ThinkingLevel;
      if (requested) {
        if (!levels.includes(requested)) {
          ctx.ui.notify(`Unknown thinking level: ${requested}`, 'error');
          return;
        }
        set_level(pi, ctx, requested);
        return;
      }

      set_level(pi, ctx, next_level(pi.getThinkingLevel()));
    },
  });

  pi.registerShortcut('ctrl+t', {
    description: 'Cycle thinking level',
    handler: async (ctx) => {
      set_level(pi, ctx, next_level(pi.getThinkingLevel()));
    },
  });
}
