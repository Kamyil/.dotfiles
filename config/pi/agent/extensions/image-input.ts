import { execFile } from 'node:child_process';
import { readFile, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { promisify } from 'node:util';
import type { ExtensionAPI, ExtensionContext } from '@earendil-works/pi-coding-agent';

const exec_file = promisify(execFile);

const clipboard_swift = String.raw`
import AppKit
import Foundation

let output = CommandLine.arguments[1]
let pasteboard = NSPasteboard.general

if let png = pasteboard.data(forType: .png) {
  try png.write(to: URL(fileURLWithPath: output))
  exit(0)
}

if let tiff = pasteboard.data(forType: .tiff),
   let bitmap = NSBitmapImageRep(data: tiff),
   let png = bitmap.representation(using: .png, properties: [:]) {
  try png.write(to: URL(fileURLWithPath: output))
  exit(0)
}

if let image = NSImage(pasteboard: pasteboard),
   let tiff = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiff),
   let png = bitmap.representation(using: .png, properties: [:]) {
  try png.write(to: URL(fileURLWithPath: output))
  exit(0)
}

fputs("clipboard does not contain an image\n", stderr)
exit(1)
`;

async function clipboard_image(path: string) {
  await exec_file('swift', ['-e', clipboard_swift, path], { timeout: 15000, maxBuffer: 1024 * 1024 });
}

async function interactive_screenshot(path: string) {
  await exec_file('screencapture', ['-i', path], { timeout: 120000, maxBuffer: 1024 * 1024 });
}

type PastedImage = { type: 'image'; source: { type: 'base64'; mediaType: 'image/png'; data: string } };

const pasted_images = new Map<string, PastedImage>();
let pasted_image_count = 0;

async function attach_image_to_editor(ctx: ExtensionContext, mode: 'clipboard' | 'screenshot') {
  const path = join(tmpdir(), `pi-${mode}-${Date.now()}.png`);

  try {
    if (mode === 'clipboard') await clipboard_image(path);
    else await interactive_screenshot(path);

    const data = await readFile(path, 'base64');
    const id = String(++pasted_image_count);
    pasted_images.set(id, { type: 'image', source: { type: 'base64', mediaType: 'image/png', data } });
    ctx.ui.pasteToEditor(`[Image ${id}] `);
    ctx.ui.notify(`Attached ${mode} image as [Image ${id}]`, 'success');
  } catch (error) {
    ctx.ui.notify(`${mode === 'clipboard' ? 'Clipboard image paste' : 'Screenshot'} failed: ${error instanceof Error ? error.message : String(error)}`, 'error');
  } finally {
    await rm(path, { force: true });
  }
}

export default function (pi: ExtensionAPI) {
  pi.on('input', async (event) => {
    if (event.source !== 'interactive') return { action: 'continue' };

    const markers = [...event.text.matchAll(/\[Image (\d+)\]/g)];
    if (markers.length === 0) return { action: 'continue' };

    const images = [...(event.images ?? [])];
    for (const marker of markers) {
      const image = pasted_images.get(marker[1]);
      if (image) images.push(image);
    }

    if (images.length === event.images?.length) return { action: 'continue' };

    for (const marker of markers) pasted_images.delete(marker[1]);

    return {
      action: 'transform',
      text: event.text.replace(/\[Image (\d+)\]/g, '').trim(),
      images,
    };
  });
  pi.registerCommand('paste-image', {
    description: 'Attach the current macOS clipboard image to the prompt',
    handler: async (_args, ctx) => attach_image_to_editor(ctx, 'clipboard'),
  });

  pi.registerCommand('screenshot', {
    description: 'Select a screen region and attach it to the prompt',
    handler: async (_args, ctx) => attach_image_to_editor(ctx, 'screenshot'),
  });

  pi.registerShortcut('ctrl+v', {
    description: 'Attach clipboard image to prompt',
    handler: async (ctx) => attach_image_to_editor(ctx, 'clipboard'),
  });

  pi.registerShortcut('f9', {
    description: 'Attach clipboard image to prompt',
    handler: async (ctx) => attach_image_to_editor(ctx, 'clipboard'),
  });

  pi.registerShortcut('ctrl+alt+s', {
    description: 'Select screenshot region and attach to prompt',
    handler: async (ctx) => attach_image_to_editor(ctx, 'screenshot'),
  });
}
