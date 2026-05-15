import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';
import { Type } from 'typebox';

export default function (pi: ExtensionAPI) {
  pi.registerCommand('reload-runtime', {
    description: 'Reload Pi extensions, skills, prompts, and themes',
    handler: async (_args, ctx) => {
      await ctx.reload();
      return;
    },
  });

  pi.registerTool({
    name: 'reload_runtime',
    label: 'Reload Runtime',
    description: 'Reload Pi extensions, skills, prompts, and themes after editing config.',
    parameters: Type.Object({}),
    async execute() {
      pi.sendUserMessage('/reload-runtime', { deliverAs: 'followUp' });
      return { content: [{ type: 'text', text: 'Queued /reload-runtime.' }] };
    },
  });
}
