/**
 * Workspace Model Boundary & Ancestor Settings Extension
 *
 * Enforces strict workspace model isolation:
 * - ~/Work: strictly uses OpenAI models (defaults to openai-codex/gpt-5.6-sol, thinking: medium).
 *           Blocks opencode-go models from running in work repositories.
 * - ~/Dev:  strictly uses OpenCode Go models (defaults to opencode-go/deepseek-v4.1-flash, thinking: high).
 *           Prevents accidental OpenAI token burn in personal projects.
 *
 * Runs on startup, new sessions, reloads, and resumes.
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
	return args.some(
		(arg) =>
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

function resolveModel(modelRegistry: any, modelSpec: string, defaultProvider?: string): any {
	let provider = defaultProvider;
	let modelId = modelSpec;

	if (modelSpec.includes("/")) {
		const slashIdx = modelSpec.indexOf("/");
		provider = modelSpec.slice(0, slashIdx);
		modelId = modelSpec.slice(slashIdx + 1);
	}

	if (provider && modelId) {
		const direct = modelRegistry.find(provider, modelId);
		if (direct) return direct;
	}

	const all = modelRegistry.getAll();
	return (
		all.find((m: any) => m.id === modelId && (!provider || m.provider === provider)) ??
		all.find((m: any) => m.id === modelId)
	);
}

export default function ancestorSettingsExtension(pi: ExtensionAPI): void {
	pi.on("session_start", async (_event, ctx: ExtensionContext) => {
		if (hasExplicitCliModelOverride()) {
			return;
		}

		let realCwd: string;
		let homeDir: string;
		try {
			realCwd = fs.realpathSync.native(ctx.cwd);
			homeDir = fs.realpathSync.native(os.homedir());
		} catch {
			realCwd = path.resolve(ctx.cwd);
			homeDir = os.homedir();
		}

		const workDir = path.join(homeDir, "Work");
		const devDir = path.join(homeDir, "Dev");

		const inWork = realCwd === workDir || realCwd.startsWith(workDir + path.sep);
		const inDev = realCwd === devDir || realCwd.startsWith(devDir + path.sep);

		const localSettingsPath = path.join(ctx.cwd, ".pi", "settings.json");
		const hasLocal = fs.existsSync(localSettingsPath);

		let settings: Record<string, any> | undefined;

		if (hasLocal) {
			try {
				settings = JSON.parse(fs.readFileSync(localSettingsPath, "utf-8"));
			} catch {}
		} else {
			const ancestor = findAncestorSettings(ctx.cwd);
			if (ancestor) {
				settings = ancestor.settings;
			}
		}

		const currentModel = ctx.model;

		// 1. WORK WORKSPACE: strictly enforce OpenAI models (on startup and resume)
		if (inWork) {
			const targetSpec = settings?.defaultModel || "openai-codex/gpt-5.6-sol";
			const targetProvider = settings?.defaultProvider || "openai-codex";
			const target = resolveModel(ctx.modelRegistry, targetSpec, targetProvider);

			if (target && (!currentModel || currentModel.provider !== target.provider || currentModel.id !== target.id)) {
				await pi.setModel(target);
				const thinking =
					settings?.modelThinkingLevels?.[`${target.provider}/${target.id}`] ||
					settings?.defaultThinkingLevel ||
					"medium";
				try {
					pi.setThinkingLevel(thinking as any);
				} catch {}
				ctx.ui?.notify?.(`Work Workspace: active model set to ${target.provider}/${target.id}`, "info");
			}
			return;
		}

		// 2. DEV WORKSPACE: strictly enforce OpenCode Go models to save OpenAI tokens (on startup and resume)
		if (inDev) {
			const targetSpec = settings?.defaultModel || "opencode-go/deepseek-v4.1-flash";
			const targetProvider = settings?.defaultProvider || "opencode-go";
			const target = resolveModel(ctx.modelRegistry, targetSpec, targetProvider);

			if (target && (!currentModel || currentModel.provider !== target.provider || currentModel.id !== target.id)) {
				await pi.setModel(target);
				const thinking =
					settings?.modelThinkingLevels?.[`${target.provider}/${target.id}`] ||
					settings?.defaultThinkingLevel ||
					"high";
				try {
					pi.setThinkingLevel(thinking as any);
				} catch {}
				ctx.ui?.notify?.(`Dev Workspace: active model set to ${target.provider}/${target.id}`, "info");
			}
			return;
		}
	});
}
