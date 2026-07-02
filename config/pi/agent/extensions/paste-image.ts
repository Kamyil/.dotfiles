import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execFile } from "node:child_process";
import { promises as fs } from "node:fs";
import { tmpdir } from "node:os";
import path from "node:path";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);

async function readMacClipboardPng(): Promise<string> {
	const tmpfile = path.join(tmpdir(), `pi-clipboard-${process.pid}-${Date.now()}.png`);

	try {
		// Same approach OpenCode uses: ask macOS for the legacy PNGf clipboard flavor
		// and write those bytes directly. Pi's Swift/AppKit path can miss this flavor.
		await execFileAsync("osascript", [
			"-e",
			'set imageData to the clipboard as "PNGf"',
			"-e",
			`set fileRef to open for access POSIX file "${tmpfile}" with write permission`,
			"-e",
			"set eof fileRef to 0",
			"-e",
			"write imageData to fileRef",
			"-e",
			"close access fileRef",
		]);

		const buffer = await fs.readFile(tmpfile);
		if (buffer.length === 0) throw new Error("clipboard image was empty");
		return buffer.toString("base64");
	} finally {
		await fs.rm(tmpfile, { force: true }).catch(() => undefined);
	}
}

export default function (pi: ExtensionAPI) {
	// Work around Pi/Codex seeing clipboard-pasted images with mimeType undefined.
	pi.on("input", async (event) => {
		const images = (event as any).images;
		if (!Array.isArray(images) || images.length === 0) return { action: "continue" };

		const normalized = images.map((image: any) => ({
			type: "image",
			data: image.data ?? image.source?.data,
			mimeType: image.mimeType ?? image.source?.mediaType ?? image.mediaType ?? "image/png",
		}));

		return { action: "transform", text: event.text, images: normalized } as any;
	});

	pi.registerCommand("paste-image", {
		description: "Paste macOS clipboard image as PNG and send it with a prompt",
		handler: async (args, ctx) => {
			if (process.platform !== "darwin") {
				ctx.ui.notify("/paste-image currently supports macOS only", "warning");
				return;
			}

			if (!ctx.isIdle()) {
				ctx.ui.notify("Agent is busy. Try again after the current turn finishes.", "warning");
				return;
			}

			try {
				const data = await readMacClipboardPng();
				const text = args.trim() || "Describe this image.";

				pi.sendUserMessage([
					{ type: "text", text },
					{ type: "image", data, mimeType: "image/png" },
				]);
			} catch (error) {
				const message = error instanceof Error ? error.message : String(error);
				ctx.ui.notify(`Clipboard image paste failed: ${message}`, "error");
			}
		},
	});
}
