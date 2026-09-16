/**
 * OpenCode Go usage check for the `opencode-go` provider.
 *
 * Slash commands:
 *   /usage      — 5-hour rolling window as a draining bar (remaining % + reset
 *                 countdown), plus weekly/monthly in brief; scoped to the current model.
 *                 Works for `opencode-go` (opencode.ai/zen/go/v1 /usage) and
 *                 `openai-codex` (chatgpt.com/backend-api/wham/usage, ChatGPT plan).
 *   /usage-all  — the same account quota, shown once, plus a per-model matrix
 *                 (price $/MTok in/out, context window) for every model the Go
 *                 plan exposes (live /models list; pi's catalogue as offline fallback)
 *
 * Footer: while the active provider is opencode-go or openai-codex, the bottom
 * bar grows a right-aligned `5h ▰…▱ 86% · 2h31m` drain bar on the
 * extension-statuses line. Refreshes on session start, model select, and after
 * turns/tool calls.
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
import type { ExtensionAPI, ExtensionCommandContext, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { Box, Text, truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import {
	join,
	resolve as resolvePath,
	relative as relativePath,
	sep as pathSep,
	isAbsolute as isPathAbsolute,
} from "node:path";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const FALLBACK_BASE_URL = "https://opencode.ai/zen/go/v1";
const GO_PROVIDER = "opencode-go";
const USAGE_TYPE = "opencode-usage";
const USAGE_ALL_TYPE = "opencode-usage-all";
const CODEX_PROVIDER = "openai-codex";
const WHAM_URL = "https://chatgpt.com/backend-api/wham/usage";

function isSupported(provider: string): boolean {
	return provider === GO_PROVIDER || provider === CODEX_PROVIDER;
}

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
	if (h < 24) return m % 60 ? `${h}h ${m % 60}m` : `${h}h`;
	const d = Math.floor(h / 24);
	return h % 24 ? `${d}d ${h % 24}h` : `${d}d`;
}

/** Remaining percent in the window (0..100), clamped. */
export function remaining(usedPercent: number): number {
	const p = Number.isFinite(usedPercent) ? usedPercent : 0;
	return Math.max(0, Math.min(100, 100 - p));
}

/** Drain bar: `█` = still remaining, `░` = already used. Bar shrinks as you use the window. */
export function bar(usedPercent: number, width = 24): { filled: string; drained: string } {
	const filled = Math.round((remaining(usedPercent) / 100) * width);
	return { filled: "█".repeat(filled), drained: "░".repeat(width - filled) };
}

// ---- Footer: draining usage bar, right-aligned on the extension-statuses line ----
// Mirrors pi's built-in FooterComponent.render() so replacing the footer loses nothing;
// re-check against dist/bundle/chunks/chunk-JVUZSMYM.js (FooterComponent) on pi upgrades.
const FOOTER_BAR_WIDTH = 10;
const FOOTER_MIN_REFRESH_MS = 20_000; // throttle API hits; usage only moves when you use tokens
let footerState: { usedPercent?: number; resetsAt?: string; err?: string } | undefined;
let footerTui: { requestRender(): void } | undefined;
let footerInstalled = false;
let lastFooterRefresh = 0;

type FgTheme = { fg(name: string, text: string): string; bold(text: string): string };

type UsageLike = {
	input?: number;
	output?: number;
	cacheRead?: number;
	cacheWrite?: number;
	cost?: { total?: number };
};

export function fmtCwd(cwd: string): string {
	const home = process.env.HOME || process.env.USERPROFILE;
	if (!home) return cwd;
	const rel = relativePath(resolvePath(home), resolvePath(cwd));
	const outside = rel === ".." || rel.startsWith(`..${pathSep}`) || isPathAbsolute(rel);
	return outside ? cwd : rel === "" ? "~" : `~${pathSep}${rel}`;
}

export function fmtTokens(count: number): string {
	if (count < 1e3) return count.toString();
	if (count < 1e4) return `${(count / 1e3).toFixed(1)}k`;
	if (count < 1e6) return `${Math.round(count / 1e3)}k`;
	if (count < 1e7) return `${(count / 1e6).toFixed(1)}M`;
	return `${Math.round(count / 1e6)}M`;
}

function sanitizeStatusText(text: string): string {
	return text.replace(/[\r\n\t]/g, " ").replace(/ +/g, " ").trim();
}

/** Cumulative token usage for the current branch, + cache hit rate of the latest assistant turn. */
export function sessionTotals(ctx: ExtensionContext): {
	totals: { input: number; output: number; cacheRead: number; cacheWrite: number; cost: number };
	cacheHitRate?: number;
} {
	let input = 0,
		output = 0,
		cacheRead = 0,
		cacheWrite = 0,
		cost = 0;
	let cacheHitRate: number | undefined;
	for (const e of ctx.sessionManager.getEntries()) {
		const m = (e as { message?: { role?: string; usage?: UsageLike } }).message;
		let u: UsageLike | undefined;
		if (m) {
			if (m.role === "assistant" && m.usage) {
				u = m.usage;
				const prompt = (m.usage.input ?? 0) + (m.usage.cacheRead ?? 0) + (m.usage.cacheWrite ?? 0);
				if (prompt > 0) cacheHitRate = ((m.usage.cacheRead ?? 0) / prompt) * 100;
			} else if (m.role === "toolResult" && m.usage) {
				u = m.usage;
			}
		} else {
			const t = (e as { type?: string }).type;
			const u2 = (e as { usage?: UsageLike }).usage;
			if ((t === "branch_summary" || t === "compaction") && u2) u = u2;
		}
		if (!u) continue;
		input += u.input ?? 0;
		output += u.output ?? 0;
		cacheRead += u.cacheRead ?? 0;
		cacheWrite += u.cacheWrite ?? 0;
		cost += u.cost?.total ?? 0;
	}
	return { totals: { input, output, cacheRead, cacheWrite, cost }, cacheHitRate };
}

export function usageBarText(
	theme: FgTheme,
	state: { usedPercent?: number; resetsAt?: string; err?: string } | undefined = footerState,
): string {
	const s = state;
	const head = theme.fg("dim", "5h");
	if (!s || s.usedPercent === undefined) {
		return `${head} ${s?.err ? theme.fg("error", "· n/a") : theme.fg("dim", "· …")}`;
	}
	const pct = remaining(s.usedPercent);
	const b = bar(s.usedPercent, FOOTER_BAR_WIDTH);
	const color = pct >= 50 ? "success" : pct >= 20 ? "warning" : "error";
	const reset = s.resetsAt ? ` · ${countdown(s.resetsAt)}` : "";
	return `${head} ${theme.fg(color, b.filled)}${theme.fg("dim", b.drained)} ${theme.bold(
		theme.fg(color, `${Math.round(pct)}%`),
	)}${theme.fg("muted", reset)}`;
}

export function statsLineText(
	ctx: ExtensionContext,
	theme: FgTheme,
	footerData: { getAvailableProviderCount(): number },
	width: number,
): string {
	const { totals, cacheHitRate } = sessionTotals(ctx);
	const parts: string[] = [];
	if (totals.input) parts.push(`↑${fmtTokens(totals.input)}`);
	if (totals.output) parts.push(`↓${fmtTokens(totals.output)}`);
	if (totals.cacheRead) parts.push(`R${fmtTokens(totals.cacheRead)}`);
	if (totals.cacheWrite) parts.push(`W${fmtTokens(totals.cacheWrite)}`);
	if ((totals.cacheRead > 0 || totals.cacheWrite > 0) && cacheHitRate !== undefined)
		parts.push(`CH${cacheHitRate.toFixed(1)}%`);
	const usingSubscription = ctx.model?.provider === "kimi-coding";
	if (totals.cost || usingSubscription) parts.push(`$${totals.cost.toFixed(3)}${usingSubscription ? " (sub)" : ""}`);
	const context = ctx.getContextUsage();
	const window = context?.contextWindow ?? ctx.model?.contextWindow ?? 0;
	const pctVal = context?.percent ?? null;
	const pctDisp = pctVal === null ? `?/${fmtTokens(window)}` : `${pctVal.toFixed(1)}%/${fmtTokens(window)}`;
	parts.push(
		pctVal === null ? pctDisp : pctVal > 90 ? theme.fg("error", pctDisp) : pctVal > 70 ? theme.fg("warning", pctDisp) : pctDisp,
	);
	if (process.env.PI_EXPERIMENTAL === "1") parts.push(`${theme.fg("dim", "•")} ${theme.bold(theme.fg("warning", "xp"))}`);

	let statsLeft = theme.fg("dim", parts.join(" "));
	let statsLeftWidth = visibleWidth(statsLeft);
	if (statsLeftWidth > width) {
		statsLeft = truncateToWidth(statsLeft, width, "...");
		statsLeftWidth = visibleWidth(statsLeft);
	}
	const modelId = ctx.model?.id || "no-model";
	let rightSide = modelId;
	if (ctx.model?.reasoning) {
		const tl = ctx.thinkingLevel ?? "off";
		rightSide = `${modelId} • ${tl === "off" ? "thinking off" : tl}`;
	}
	if ((footerData.getAvailableProviderCount() ?? 0) > 1 && ctx.model) {
		const withProvider = `(${ctx.model.provider}) ${rightSide}`;
		if (statsLeftWidth + 2 + visibleWidth(withProvider) <= width) rightSide = withProvider;
	}

	const rightSideWidth = visibleWidth(rightSide);
	let line: string;
	if (statsLeftWidth + 2 + rightSideWidth <= width) {
		line = statsLeft + " ".repeat(width - statsLeftWidth - rightSideWidth) + rightSide;
	} else if (width - statsLeftWidth - 2 > 0) {
		const truncated = truncateToWidth(rightSide, width - statsLeftWidth - 2, "");
		line = statsLeft + " ".repeat(Math.max(0, width - statsLeftWidth - visibleWidth(truncated))) + truncated;
	} else {
		line = statsLeft;
	}
	return theme.fg("dim", statsLeft) + theme.fg("dim", line.slice(statsLeft.length));
}

export function statusesLineText(
	ctx: ExtensionContext,
	theme: FgTheme,
	footerData: { getExtensionStatuses(): ReadonlyMap<string, string> },
	width: number,
): string {
	const statuses = Array.from(footerData.getExtensionStatuses().entries())
		.sort(([a], [b]) => a.localeCompare(b))
		.map(([, text]) => sanitizeStatusText(text))
		.join(" ");
	const barText = usageBarText(theme);
	if (statuses) {
		const left = truncateToWidth(statuses, Math.max(1, width - visibleWidth(barText)), theme.fg("dim", "..."));
		const line = left + " ".repeat(Math.max(0, width - visibleWidth(left) - visibleWidth(barText))) + barText;
		return truncateToWidth(line, width);
	}
	return truncateToWidth(barText, width);
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

export function renderUsage(
	usage: Record<string, Window>,
	model?: { provider: string; id: string },
	label = "OpenCode Go",
): string {
	const roll = usage.rolling;
	const pct = typeof roll?.percent === "number" ? roll.percent : undefined;
	const b = bar(pct ?? 0);
	const rem = pct === undefined ? "n/a" : `${Math.round(remaining(pct))}% remaining`;
	const reset = pct !== undefined && roll?.resetsAt ? `resets in ${countdown(roll.resetsAt)} · used ${Math.round(pct)}%` : "";
	const head = `**${label} · 5h window** — \`${model ? `${model.provider}/${model.id}` : "unknown"}\``;
	const barBlock = ["```", `${b.filled}${b.drained}  ${rem}`, reset, "```"].join("\n");
	const caps =
		label === "OpenCode Go" ? CAPS : "Codex plan: the API reports percent only; numeric limits vary by tier.";
	return [head, "", barBlock, "", ...quotaRows(usage), "", caps].join("\n");
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

async function resolveGo(
	ctx: ExtensionContext,
): Promise<{ ok: false; error: string } | { ok: true; apiKey: string; baseUrl: string }> {
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
}

async function refreshFooterUsage(ctx: ExtensionContext): Promise<void> {
	const provider = ctx.model?.provider;
	if (!provider || !isSupported(provider) || !footerInstalled) return;
	const now = Date.now();
	if (now - lastFooterRefresh < FOOTER_MIN_REFRESH_MS) return; // ponytail: throttle; refetch is event-driven
	lastFooterRefresh = now;
	if (provider === CODEX_PROVIDER) {
		const res = await fetchCodexUsage(ctx);
		const roll = res.ok ? res.usage.rolling : undefined;
		if (res.ok && typeof roll?.percent === "number")
			footerState = { usedPercent: roll.percent, resetsAt: roll.resetsAt };
		else footerState = { err: res.ok ? "no rolling window data" : res.detail };
		footerTui?.requestRender();
		return;
	}
	const go = await resolveGo(ctx);
	if (!go.ok) {
		footerState = { err: go.error };
		footerTui?.requestRender();
		return;
	}
	const res = await fetchGo(go.baseUrl, "/usage", go.apiKey);
	const roll = res.ok ? (res.body as UsageBody).usage?.rolling : undefined;
	if (res.ok && typeof roll?.percent === "number") footerState = { usedPercent: roll.percent, resetsAt: roll.resetsAt };
	else footerState = { err: res.ok ? "unexpected usage response" : res.detail };
	footerTui?.requestRender();
}

function uninstallFooter(ctx: ExtensionContext): void {
	if (!footerInstalled) return;
	footerInstalled = false;
	footerState = undefined;
	ctx.ui.setFooter(undefined);
}

function installFooter(ctx: ExtensionContext): void {
	if (footerInstalled) return;
	footerInstalled = true;
	ctx.ui.setFooter((tui, theme, footerData) => {
		footerTui = tui;
		const unsub = footerData.onBranchChange(() => tui.requestRender());
		return {
			dispose: () => {
				unsub();
				footerInstalled = false;
				footerTui = undefined;
			},
			invalidate() {},
			render(width: number): string[] {
				let pwd = fmtCwd(ctx.sessionManager.getCwd());
				const branch = footerData.getGitBranch();
				if (branch) pwd = `${pwd} (${branch})`;
				const sessionName = ctx.sessionManager.getSessionName();
				if (sessionName) pwd = `${pwd} • ${sessionName}`;
				return [
					truncateToWidth(theme.fg("dim", pwd), width, theme.fg("dim", "...")),
					statsLineText(ctx, theme, footerData, width),
					statusesLineText(ctx, theme, footerData, width),
				];
			},
		};
	});
	void refreshFooterUsage(ctx);
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

/** ChatGPT account id embedded in the OAuth access-token JWT (claim used by WHAM). */
export function jwtAccountId(access: string): string | undefined {
	try {
		const payload = access.split(".")[1];
		const json = JSON.parse(Buffer.from(payload, "base64url").toString("utf8"));
		const id = json?.["https://api.openai.com/auth"]?.chatgpt_account_id;
		return typeof id === "string" && id.length > 0 ? id : undefined;
	} catch {
		return undefined;
	}
}

/** Normalize a WHAM rate-limit window (used_percent / reset_at) to our Window shape. */
export function windowOf(w: { used_percent?: number; reset_at?: number; reset_after_seconds?: number } | undefined): Window | undefined {
	if (!w || typeof w.used_percent !== "number") return undefined;
	let resetsAt: string | undefined;
	if (typeof w.reset_at === "number") resetsAt = new Date(w.reset_at * 1000).toISOString();
	else if (typeof w.reset_after_seconds === "number")
		resetsAt = new Date(Date.now() + w.reset_after_seconds * 1000).toISOString();
	return { status: "ok", percent: w.used_percent, ...(resetsAt ? { resetsAt } : {}) };
}

/**
 * Codex (ChatGPT plan) 5h/rolling window via the WHAM endpoint the Codex CLI polls.
 * Response: rate_limit.{primary_window, secondary_window} with used_percent/reset_at.
 */
async function fetchCodexUsage(
	ctx: ExtensionContext,
): Promise<{ ok: true; usage: Record<string, Window>; planType?: string } | { ok: false; detail: string }> {
	const access = await ctx.modelRegistry.getApiKeyForProvider(CODEX_PROVIDER);
	if (!access)
		return { ok: false, detail: "No ChatGPT auth found for `openai-codex`. Run `/login openai-codex` first." };
	const accountId = jwtAccountId(access);
	let res: Response;
	try {
		res = await fetch(WHAM_URL, {
			headers: {
				Authorization: `Bearer ${access}`,
				...(accountId ? { "ChatGPT-Account-Id": accountId } : {}),
				Accept: "application/json",
				"User-Agent": "Codex/1.0 (pi usage)",
			},
			signal: AbortSignal.timeout(15_000),
		});
	} catch {
		return { ok: false, detail: `Could not reach ${WHAM_URL} (network or timeout).` };
	}
	let body: Record<string, unknown> = {};
	try {
		body = await res.json();
	} catch {
		/* fall through to status handling */
	}
	if (!res.ok) {
		const detail = typeof (body as { error?: { message?: string } }).error?.message === "string" ? `: ${(body as { error?: { message?: string } }).error?.message}` : "";
		return { ok: false, detail: `Codex usage check failed: HTTP ${res.status}${detail}` };
	}
	const rl = (body.rate_limit ?? body) as Record<string, unknown>;
	const rolling = windowOf(rl.primary_window as never);
	const weekly = windowOf(rl.secondary_window as never);
	if (!rolling) return { ok: false, detail: "Unexpected response shape from the Codex usage API (no primary_window)." };
	const usage: Record<string, Window> = { rolling, ...(weekly ? { weekly } : {}) };
	const planType = typeof body.plan_type === "string" ? body.plan_type : undefined;
	return { ok: true, usage, planType };
}

export default function usageExtension(pi: ExtensionAPI) {
	// Footer: while the active provider is opencode-go or openai-codex; refresh after API-using turns.
	pi.on("session_start", (_event, ctx) => {
		if (ctx.model && isSupported(ctx.model.provider)) installFooter(ctx);
	});
	pi.on("model_select", (_event, ctx) => {
		if (ctx.model && isSupported(ctx.model.provider)) installFooter(ctx);
		else uninstallFooter(ctx);
	});
	pi.on("tool_execution_end", (_event, ctx) => void refreshFooterUsage(ctx));
	pi.on("turn_end", (_event, ctx) => void refreshFooterUsage(ctx));

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
		const send = (text: string, details?: unknown, customType = USAGE_TYPE) => {
			try {
				pi.sendMessage({ customType, content: text, display: true, ...(details ? { details } : {}) });
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
					lines.push(renderCached ? renderCached(c.data, undefined) : `${renderUsage(d.usage)}`);
				}
			}
			return send(lines.join("\n"));
		};
		return { cachePath, cache, saveCache, send, fail };
	};

	pi.registerMessageRenderer(USAGE_TYPE, ({ details, content }, { expanded, outputPad }, theme) => {
		const d = (details ?? {}) as { usage?: Record<string, Window>; model?: string };
		const roll = d.usage?.rolling;
		// Failed lookups (no details) render the actual error text instead of masking it.
		if (!d.usage) {
			const text = typeof content === "string" ? content : content.map((c) => (c.type === "text" ? c.text : "")).join("\n");
			const box = new Box(outputPad, 1, (t) => theme.bg("customMessageBg", t));
			box.addChild(new Text(text, 0, 0));
			return box;
		}
		const lines: string[] = [];
		lines.push(`${theme.bold("5h window")}${d.model ? theme.fg("muted", ` · ${d.model}`) : ""}`);
		if (roll && typeof roll.percent === "number") {
			const pct = remaining(roll.percent);
			const pctLabel = `${Math.round(pct)}% remaining`;
			const b = bar(roll.percent);
			const color = pct >= 50 ? "success" : pct >= 20 ? "warning" : "error";
			lines.push(
				`${theme.fg(color, b.filled)}${theme.fg("dim", b.drained)}  ${theme.bold(
					theme.fg(color, pctLabel),
				)}${pct === 0 ? theme.fg("error", " · window exhausted") : ""}`,
			);
			lines.push(theme.fg("muted", `resets ${roll.resetsAt ? `in ${countdown(roll.resetsAt)}` : "—"} · used ${Math.round(roll.percent)}%`));
		} else {
			lines.push(theme.fg("error", "no rolling window data"));
		}
		for (const [label, w] of [
			["wk", d.usage?.weekly],
			["mo", d.usage?.monthly],
		] as const) {
			if (!w || typeof w.percent !== "number") continue;
			const reset = w.resetsAt ? ` · resets in ${countdown(w.resetsAt)}` : "";
			lines.push(theme.fg("dim", `${label} ${Math.round(w.percent)}% used${reset}`));
		}
		if (expanded) lines.push(theme.fg("dim", JSON.stringify(d)));
		const box = new Box(outputPad, 1, (t) => theme.bg("customMessageBg", t));
		box.addChild(new Text(lines.join("\n"), 0, 0));
		return box;
	});

	pi.registerCommand("usage", {
		description: "5h-window usage as a draining bar (remaining %, reset countdown) for opencode-go / openai-codex",
		handler: async (_args, ctx) => {
			const session = makeSession(ctx);

			const model = ctx.model;
			const provider = model?.provider;
			if (!model || !provider) return session.fail("No active model to report usage for.");
			if (!isSupported(provider))
				return session.fail(`Usage reporting covers \`opencode-go\` and \`openai-codex\`; current model is \`${provider}/${model.id}\`.`);

			if (provider === CODEX_PROVIDER) {
				const res = await fetchCodexUsage(ctx);
				if (!res.ok) return session.fail(res.detail);
				const usage = res.usage;
				session.saveCache({ usage });
				const label = res.planType ? `Codex (${res.planType})` : "Codex";
				session.send(renderUsage(usage, model, label), { usage, model: `${model.provider}/${model.id}` });
				return;
			}

			const go = await resolveGo(ctx);
			if (!go.ok) return session.fail(go.error);

			const res = await fetchGo(go.baseUrl, "/usage", go.apiKey);
			if (!res.ok) return session.fail(res.detail);

			const usage = (res.body as UsageBody).usage;
			if (!usage?.rolling) return session.fail("Unexpected response shape from the usage API.");

			session.saveCache(res.body);
			session.send(renderUsage(usage, model), { usage, model: `${model.provider}/${model.id}` });
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
				return d.usage?.rolling ? renderUsage(d.usage) : "";
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
			session.send(renderAllTable(usage, models, catalog, note, scopeLabel), undefined, USAGE_ALL_TYPE);
		},
	});
}

type ModelShape = { provider?: string; id: string };
