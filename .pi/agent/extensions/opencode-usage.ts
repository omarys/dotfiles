/**
 * OpenCode Go usage check for the `opencode-go` provider.
 *
 * Slash commands:
 *   /usage      — account quota (rolling/weekly/monthly) scoped to the current model
 *   /usage-all  — the same account quota, shown once, plus a per-model matrix
 *                 (price $/MTok in/out, context window) for every model the Go
 *                 plan exposes (live /models list; pi's catalogue as offline fallback)
 *
 * Data sources:
 *   GET {baseUrl}/usage    — quota windows (account-wide, percents + resetsAt)
 *   GET {baseUrl}/models   — the model catalogue (public; same with or without key)
 *   Authorization: Bearer <opencode-go api key>
 *   pi model catalogue     — per-model pricing + context window (from ctx.modelRegistry)
 *
 * Response: { usage: { rolling, weekly, monthly: { status, percent, resetsAt } } }
 * and:      { object:"list", data: [{ id, created, owned_by }] }
 *
 * Informational only: never warns, blocks, or suggests actions. On API
 * failure it reports the reason and, if a previous successful fetch exists,
 * the cached numbers with their age.
 *
 * Install: add this file's path to settings.json "extensions", or copy it
 * into ~/.pi/agent/extensions/ (global) / .pi/extensions/ (project).
 */

import { getAgentDir } from "@earendil-works/pi-coding-agent";
import type { ExtensionAPI, ExtensionCommandContext } from "@earendil-works/pi-coding-agent";
import { join } from "node:path";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const FALLBACK_BASE_URL = "https://opencode.ai/zen/go/v1";
const GO_PROVIDER = "opencode-go";

type Window = { status?: string; percent?: number; resetsAt?: string };
type UsageBody = { usage?: Record<string, Window> };
type ModelsBody = { data?: Array<{ id?: string }> };

export function countdown(iso: string): string {
	const ms = new Date(iso).getTime() - Date.now();
	if (!Number.isFinite(ms) || ms <= 0) return "now";
	const m = Math.floor(ms / 60_000);
	if (m < 1) return "<1m";
	if (m < 60) return `${m}m`;
	const h = Math.floor(m / 60);
	if (h < 24) return `${h}h ${m % 60}m`;
	return `${Math.floor(h / 24)}d ${h % 24}h`;
}

function ageOf(at: number): string {
	const m = Math.floor((Date.now() - at) / 60_000);
	if (m < 1) return "just now";
	if (m < 60) return `${m}m ago`;
	const h = Math.floor(m / 60);
	if (h < 24) return `${h}h ago`;
	return `${Math.floor(h / 24)}d ago`;
}

export function row(label: string, w: Window | undefined): string {
	if (!w || typeof w.percent !== "number") return `| ${label} | n/a | — |`;
	const used = `${Math.round(w.percent)}%`;
	const reset = w.resetsAt ? `in ${countdown(w.resetsAt)}` : "—";
	const flag = w.status && w.status !== "ok" ? " ⚠" : "";
	return `| ${label} | ${used}${flag} | ${reset} |`;
}

function quotaRows(usage: Record<string, Window>): string[] {
	return [
		"| window | used | resets |",
		"|---|---|---|",
		row("rolling (5h)", usage.rolling),
		row("weekly", usage.weekly),
		row("monthly", usage.monthly),
	];
}

const CAPS = "Plan caps: $12/5h · $30/wk · $60/mo (API reports percent only).";

export function renderTable(usage: Record<string, Window>, model?: { provider: string; id: string }): string {
	return [
		`**OpenCode Go usage — \`${model ? model.id : "unknown"}\`**`,
		"",
		...quotaRows(usage),
		"",
		CAPS,
	].join("\n");
}

function fmtPrice(v: number | undefined): string {
	return typeof v === "number" ? `$${v}` : "—";
}

function fmtCtx(v: number | undefined): string {
	if (typeof v !== "number") return "—";
	if (v >= 1_000_000) return `${Math.round(v / 1_000_000)}M`;
	return `${Math.round(v / 1000)}K`;
}

function modelDetail(m: unknown): { input?: number; output?: number; ctx?: number } {
	const rec = m as { cost?: { input?: unknown; output?: unknown }; contextWindow?: unknown } | undefined;
	const num = (v: unknown) => (typeof v === "number" && Number.isFinite(v) ? v : undefined);
	return { input: num(rec?.cost?.input), output: num(rec?.cost?.output), ctx: num(rec?.contextWindow) };
}

export function renderMatrix(models: string[], catalog: Map<string, unknown>): string {
	const rows = models.map((id) => {
		const p = modelDetail(catalog.get(id));
		return `| ${id} | ${fmtPrice(p.input)} | ${fmtPrice(p.output)} | ${fmtCtx(p.ctx)} |`;
	});
	return ["| model | in ($/MTok) | out ($/MTok) | ctx |", "|---|---|---|---|", ...rows].join("\n");
}

export function renderAllTable(
	usage: Record<string, Window>,
	models: string[],
	catalog: Map<string, unknown>,
	note?: string,
	scopeLabel = `${models.length} models`,
): string {
	return [
		`**OpenCode Go — account quota (${scopeLabel})**`,
		"",
		...quotaRows(usage),
		"",
		"**Per-model** (price $/MTok, ctx from pi's model catalogue):",
		"",
		renderMatrix(models, catalog),
		...(note ? ["", note] : []),
		"",
		CAPS,
	].join("\n");
}

/**
 * Pick which model ids the matrix shows: the enabled set (pi's enabledModels /
 * --models) when one is configured, intersected with the live accessible list;
 * otherwise the live list; otherwise pi's catalogue (offline).
 */
export function resolveModels(
	enabled: string[],
	live: string[],
	catalogIds: string[],
): { models: string[]; note?: string; scopeLabel: string } {
	if (enabled.length > 0) {
		const set = new Set(enabled);
		const models = live.length > 0 ? live.filter((id) => set.has(id)) : [...set];
		return { models, scopeLabel: `${models.length} enabled model${models.length === 1 ? "" : "s"}` };
	}
	if (live.length > 0) return { models: live, scopeLabel: `${live.length} models` };
	if (catalogIds.length > 0)
		return {
			models: [...catalogIds],
			scopeLabel: `${catalogIds.length} models`,
			note: "Offline: showing pi's model catalogue instead of the live /models list.",
		};
	return { models: [], scopeLabel: "0 models" };
}

async function fetchGo(
	baseUrl: string,
	path: string,
	apiKey?: string,
): Promise<{ ok: true; body: UsageBody | ModelsBody } | { ok: false; detail: string }> {
	let res: Response;
	try {
		res = await fetch(`${baseUrl}${path}`, {
			headers: { ...(apiKey ? { Authorization: `Bearer ${apiKey}` } : {}), Accept: "application/json" },
			signal: AbortSignal.timeout(15_000),
		});
	} catch {
		return { ok: false, detail: `Could not reach ${baseUrl}${path} (network or timeout).` };
	}

	let body: UsageBody & ModelsBody & { error?: { type?: string; message?: string } } = {};
	try {
		body = await res.json();
	} catch {
		/* fall through to status handling */
	}

	if (!res.ok) {
		const errType = body?.error?.type;
		const detail =
			errType === "AuthError"
				? "API key rejected by opencode.ai. Re-run pi's provider login."
				: errType === "EntitlementError"
					? "This key has no OpenCode Go subscription."
					: `HTTP ${res.status}${body?.error?.message ? `: ${body.error.message}` : ""}`;
		return { ok: false, detail: `Usage check failed: ${detail}` };
	}
	return { ok: true, body };
}

export default function usageExtension(pi: ExtensionAPI) {
	const makeSession = (ctx: ExtensionCommandContext) => {
		const cachePath = join(getAgentDir(), "opencode-usage-cache.json");
		const cache = (): { data: unknown; at: number } | null => {
			try {
				const raw = JSON.parse(readFileSync(cachePath, "utf8"));
				return raw && typeof raw.at === "number" ? raw : null;
			} catch {
				return null;
			}
		};
		const saveCache = (data: unknown) => {
			try {
				mkdirSync(getAgentDir(), { recursive: true });
				writeFileSync(cachePath, JSON.stringify({ data, at: Date.now() }));
			} catch {
				/* cache is best-effort */
			}
		};
		const send = (text: string) => {
			try {
				pi.sendMessage({ customType: "opencode-usage", content: text, display: true });
			} catch {
				ctx.ui.notify(text.replace(/\n/g, " · "), "info");
			}
		};
		// Takes a renderer for the cached payload so each command shows its own shape on failure.
		const fail = (text: string, renderCached?: (data: unknown, model: ModelShape | undefined) => string) => {
			const c = cache();
			const lines = [text];
			if (c && c.data && typeof c.data === "object" && "usage" in c.data) {
				const d = c.data as { usage?: Record<string, Window> };
				if (d.usage?.rolling) {
					lines.push(`\nCached numbers (${ageOf(c.at)}):`);
					lines.push(renderCached ? renderCached(c.data, undefined) : `${renderTable(d.usage)}`);
				}
			}
			return send(lines.join("\n"));
		};
		return { cachePath, cache, saveCache, send, fail };
	};

	const resolveGo = async (
		ctx: ExtensionCommandContext,
	): Promise<{ ok: false; error: string } | { ok: true; apiKey: string; baseUrl: string }> => {
		const apiKey = await ctx.modelRegistry.getApiKeyForProvider(GO_PROVIDER);
		if (!apiKey)
			return {
				ok: false,
				error: "No API key found for `opencode-go`. Run pi's provider login (e.g. `/login` or `pi auth`) first.",
			};
		return {
			ok: true,
			apiKey,
			baseUrl: ctx.modelRegistry.getProvider(GO_PROVIDER)?.baseUrl ?? FALLBACK_BASE_URL,
		};
	};

	pi.registerCommand("usage", {
		description: "OpenCode Go plan usage for the current model (rolling/weekly/monthly)",
		handler: async (_args, ctx) => {
			const session = makeSession(ctx);

			const model = ctx.model;
			const provider = model?.provider;
			if (!model || !provider) return session.fail("No active model to report usage for.");
			if (provider !== GO_PROVIDER)
				return session.fail(`Usage reporting only covers the \`opencode-go\` provider; current model is \`${provider}/${model.id}\`.`);

			const go = await resolveGo(ctx);
			if (!go.ok) return session.fail(go.error);

			const res = await fetchGo(go.baseUrl, "/usage", go.apiKey);
			if (!res.ok) return session.fail(res.detail);

			const usage = (res.body as UsageBody).usage;
			if (!usage?.rolling) return session.fail("Unexpected response shape from the usage API.");

			session.saveCache(res.body);
			session.send(renderTable(usage, model));
		},
	});

	pi.registerCommand("usage-all", {
		description: "OpenCode Go account quota + per-model matrix (price, context) for every accessible model",
		handler: async (_args, ctx) => {
			const session = makeSession(ctx);

			const go = await resolveGo(ctx);
			if (!go.ok) return session.fail(go.error);

			const [usageRes, modelsRes] = await Promise.all([
				fetchGo(go.baseUrl, "/usage", go.apiKey),
				fetchGo(go.baseUrl, "/models"),
			]);

			if (!usageRes.ok) return session.fail(usageRes.detail, (data) => {
				const d = data as { usage?: Record<string, Window> };
				return d.usage?.rolling ? renderTable(d.usage) : "";
			});
			const usage = (usageRes.body as UsageBody).usage;
			if (!usage?.rolling) return session.fail("Unexpected response shape from the usage API.");

			// Catalog: pi's opencode-go model entries (id → price/context).
			const catalog = new Map<string, unknown>();
			for (const m of ctx.modelRegistry.getAll()) {
				if (m.provider === GO_PROVIDER) catalog.set(m.id, m);
			}

			// Enabled set: pi's scoped models (enabledModels / --models); empty means all usable.
			const enabled = (ctx.scopedModels ?? [])
				.filter((s) => s.model.provider === GO_PROVIDER)
				.map((s) => s.model.id);

			const liveIds = (
				modelsRes.ok ? ((modelsRes.body as ModelsBody).data ?? []).map((m) => m.id).filter(Boolean) : []
			) as string[];
			const { models, note, scopeLabel } = resolveModels(enabled, liveIds, [...catalog.keys()]);
			if (models.length === 0)
				return session.fail("No model rows to show (none of the enabled models appear in the accessible list).");

			session.saveCache({ usage, models });
			session.send(renderAllTable(usage, models, catalog, note, scopeLabel));
		},
	});
}

type ModelShape = { provider?: string; id: string };
