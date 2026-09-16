/**
 * Ancestor Settings Extension
 *
 * Automatically discovers and applies settings from the nearest ancestor `.pi/settings.json`
 * when working in nested subdirectories/repositories that do not contain their own `.pi/` config.
 *
 * Traversal starts from parent directories of cwd and stops before reaching the user home directory.
 */

import * as fs from "node:fs";
import * as path from "node:path";
import * as os from "node:os";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

interface AncestorSettingsResult {
	filePath: string;
	dirPath: string;
	settings: Record<string, any>;
}

function hasExplicitCliModelOverride(): boolean {
	const args = process.argv;
	return args.some((arg) =>
		arg === "--model" ||
		arg === "-m" ||
		arg.startsWith("--model=") ||
		arg === "--provider" ||
		arg.startsWith("--provider=")
	);
}

function findAncestorSettings(startDir: string): AncestorSettingsResult | null {
	let home: string;
	try {
		home = fs.realpathSync.native(os.homedir());
	} catch {
		home = os.homedir();
	}

	let current = path.dirname(path.resolve(startDir));

	while (true) {
		if (!fs.existsSync(current)) break;

		let realCurrent: string;
		try {
			realCurrent = fs.realpathSync.native(current);
		} catch {
			realCurrent = current;
		}

		// Never traverse into or beyond user's home directory
		if (realCurrent === home) break;

		const candidate = path.join(current, ".pi", "settings.json");
		if (fs.existsSync(candidate)) {
			try {
				const content = fs.readFileSync(candidate, "utf-8");
				const parsed = JSON.parse(content);
				if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
					return {
						filePath: candidate,
						dirPath: current,
						settings: parsed,
					};
				}
			} catch {
				// Ignore parse errors and continue upward
			}
		}

		const parent = path.dirname(current);
		if (parent === current) break;
		current = parent;
	}

	return null;
}

export default function ancestorSettingsExtension(pi: ExtensionAPI): void {
	pi.on("session_start", async (event, ctx: ExtensionContext) => {
		// Only run on initial startup, new session, or runtime reload
		if (event.reason !== "startup" && event.reason !== "new" && event.reason !== "reload") {
			return;
		}

		// If user explicitly passed --model or --provider on CLI, preserve it
		if (hasExplicitCliModelOverride()) {
			return;
		}

		// If project already has its own .pi/settings.json, Pi core already loaded it
		const localSettings = path.join(ctx.cwd, ".pi", "settings.json");
		if (fs.existsSync(localSettings)) {
			return;
		}

		const ancestor = findAncestorSettings(ctx.cwd);
		if (!ancestor) {
			return;
		}

		const { filePath, settings } = ancestor;
		let appliedModel = false;
		let selectedModelId = "";

		// 1. Resolve and apply defaultModel
		if (settings.defaultModel && typeof settings.defaultModel === "string") {
			const rawModel = settings.defaultModel.trim();
			let targetProvider: string | undefined = settings.defaultProvider;
			let targetModelId = rawModel;

			if (rawModel.includes("/")) {
				const slashIdx = rawModel.indexOf("/");
				targetProvider = rawModel.slice(0, slashIdx);
				targetModelId = rawModel.slice(slashIdx + 1);
			}

			// Search in ModelRegistry
			let model = targetProvider
				? ctx.modelRegistry.find(targetProvider, targetModelId)
				: undefined;

			if (!model) {
				const allModels = ctx.modelRegistry.getAll();
				model = allModels.find(
					(m) => m.id === targetModelId && (!targetProvider || m.provider === targetProvider)
				) ?? allModels.find((m) => m.id === targetModelId);
			}

			if (model) {
				const currentModel = ctx.model;
				if (!currentModel || currentModel.provider !== model.provider || currentModel.id !== model.id) {
					const success = await pi.setModel(model);
					if (success) {
						appliedModel = true;
						selectedModelId = `${model.provider}/${model.id}`;
					}
				} else {
					appliedModel = true;
					selectedModelId = `${model.provider}/${model.id}`;
				}
			}
		}

		// 2. Resolve and apply thinking level
		let targetThinkingLevel: string | undefined;
		if (selectedModelId && settings.modelThinkingLevels?.[selectedModelId]) {
			targetThinkingLevel = settings.modelThinkingLevels[selectedModelId];
		} else if (settings.defaultThinkingLevel && typeof settings.defaultThinkingLevel === "string") {
			targetThinkingLevel = settings.defaultThinkingLevel;
		}

		const validThinkingLevels = new Set(["off", "minimal", "low", "medium", "high", "xhigh", "max"]);
		if (targetThinkingLevel && validThinkingLevels.has(targetThinkingLevel)) {
			try {
				pi.setThinkingLevel(targetThinkingLevel as any);
			} catch {
				// Ignore if thinking level not applicable
			}
		}

		// 3. User feedback
		if (appliedModel && ctx.ui?.notify) {
			const relPath = path.relative(os.homedir(), filePath);
			const displayPath = relPath.startsWith("..") ? filePath : `~/${relPath}`;
			ctx.ui.notify(`Inherited model ${selectedModelId} from ${displayPath}`, "info");
		}
	});
}
