import { homedir } from 'node:os';
import { join, basename } from 'node:path';
import { readdir, readFile, stat } from 'node:fs/promises';
import type { ExtensionAPI } from '@earendil-works/pi-coding-agent';

type SessionSummary = {
  file: string;
  id: string;
  cwd: string;
  title: string;
  updatedAt: number;
};

const DEFAULT_LIMIT = 25;

function session_root() {
  return process.env.PI_CODING_AGENT_SESSION_DIR ?? join(process.env.PI_CODING_AGENT_DIR ?? join(homedir(), '.pi', 'agent'), 'sessions');
}

function text_content(content: unknown): string | undefined {
  if (typeof content === 'string') return content;
  if (!Array.isArray(content)) return undefined;

  return content
    .map((part) => (part && typeof part === 'object' && (part as { type?: string }).type === 'text' ? (part as { text?: string }).text ?? '' : ''))
    .join('')
    .trim();
}

function shorten(text: string, max = 80) {
  const single_line = text.replace(/\s+/g, ' ').trim();
  return single_line.length > max ? `${single_line.slice(0, max - 1)}…` : single_line;
}

function format_age(timestamp: number) {
  const seconds = Math.max(0, Math.floor((Date.now() - timestamp) / 1000));
  if (seconds < 60) return `${seconds}s ago`;
  const minutes = Math.floor(seconds / 60);
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.floor(minutes / 60);
  if (hours < 48) return `${hours}h ago`;
  return `${Math.floor(hours / 24)}d ago`;
}

async function find_session_files(dir: string): Promise<string[]> {
  const entries = await readdir(dir, { withFileTypes: true });
  const nested = await Promise.all(
    entries.map(async (entry) => {
      const path = join(dir, entry.name);
      if (entry.isDirectory()) return find_session_files(path);
      if (entry.isFile() && entry.name.endsWith('.jsonl')) return [path];
      return [];
    }),
  );

  return nested.flat();
}

async function summarize_session(file: string): Promise<SessionSummary | undefined> {
  try {
    const [contents, stats] = await Promise.all([readFile(file, 'utf8'), stat(file)]);
    let id = basename(file, '.jsonl');
    let cwd = '';
    let title = '';

    for (const line of contents.split('\n')) {
      if (!line.trim()) continue;
      const entry = JSON.parse(line) as any;

      if (entry.type === 'session') {
        id = entry.id ?? id;
        cwd = entry.cwd ?? cwd;
      } else if (entry.type === 'session_name' && typeof entry.name === 'string') {
        title = entry.name;
      } else if (!title && entry.type === 'message' && entry.message?.role === 'user') {
        title = text_content(entry.message.content) ?? '';
      }

      if (cwd && title) break;
    }

    return {
      file,
      id,
      cwd: cwd || 'unknown cwd',
      title: shorten(title || '(empty session)'),
      updatedAt: stats.mtimeMs,
    };
  } catch {
    return undefined;
  }
}

export default function (pi: ExtensionAPI) {
  pi.registerCommand('sessions', {
    description: 'Browse recent Pi sessions across projects',
    handler: async (args, ctx) => {
      await ctx.waitForIdle();

      const limit = Number(args.trim()) || DEFAULT_LIMIT;
      const root = session_root();
      const summaries = (await Promise.all((await find_session_files(root)).map(summarize_session)))
        .filter((session): session is SessionSummary => Boolean(session))
        .sort((a, b) => b.updatedAt - a.updatedAt)
        .slice(0, Math.max(1, limit));

      if (summaries.length === 0) {
        ctx.ui.notify('No saved Pi sessions found.', 'info');
        return;
      }

      const labels = summaries.map((session) => `${format_age(session.updatedAt)}  ${session.title}  —  ${session.cwd}`);
      const selected = await ctx.ui.select('Recent Pi sessions', labels);
      if (!selected) return;

      const session = summaries[labels.indexOf(selected)];
      if (!session) return;

      await ctx.switchSession(session.file, {
        withSession: async (newCtx) => {
          newCtx.ui.notify(`Switched to ${session.id.slice(0, 8)} (${session.cwd})`, 'success');
        },
      });
    },
  });
}
