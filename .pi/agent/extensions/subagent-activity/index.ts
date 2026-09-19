/**
 * Subagent activity footer.
 *
 * Shows how many subagents are active right now ("◆ 2 subagents"), reading
 * pi-subagents' live fleet projection over its in-process event-bus RPC.
 * Cleared when nothing is running. Stays silent if pi-subagents is absent.
 */

import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const RPC_REQUEST = "subagents:rpc:v1:request";
const RPC_REPLY_PREFIX = "subagents:rpc:v1:reply:";
const RPC_READY = "subagents:rpc:v1:ready";
const ASYNC_STARTED = "subagent:async-started";
const ASYNC_COMPLETE = "subagent:async-complete";
const KEY = "subagents-active";
const POLL_MS = 2000;
const REPLY_TIMEOUT_MS = 4000;

export default function (pi: ExtensionAPI) {
	let ctx: ExtensionContext | undefined;
	let poller: ReturnType<typeof setInterval> | undefined;
	let debounce: ReturnType<typeof setTimeout> | undefined;
	let inflight = false;
	let queued = false;
	let lastText: string | undefined;

	function ask(): Promise<number | undefined> {
		return new Promise((resolve) => {
			const requestId = crypto.randomUUID();
			let timer: ReturnType<typeof setTimeout>;
			const off = pi.events.on(`${RPC_REPLY_PREFIX}${requestId}`, (raw) => {
				clearTimeout(timer);
				off();
				const reply = raw as { success?: boolean; data?: { fleet?: { totalActive?: number } } } | undefined;
				resolve(reply?.success ? reply.data?.fleet?.totalActive : undefined);
			});
			timer = setTimeout(() => {
				off();
				resolve(undefined);
			}, REPLY_TIMEOUT_MS);
			pi.events.emit(RPC_REQUEST, { version: 1, requestId, method: "status" });
		});
	}

	function stopPolling() {
		if (poller) clearInterval(poller);
		poller = undefined;
	}

	function show(text: string | undefined) {
		if (!ctx || text === lastText) return;
		lastText = text;
		ctx.ui.setStatus(KEY, text);
	}

	async function refresh() {
		if (inflight) {
			queued = true;
			return;
		}
		inflight = true;
		do {
			queued = false;
			const count = await ask();
			if (count === undefined) break; // no pi-subagents bridge answering
			if (count <= 0) {
				show(undefined);
				stopPolling();
				break;
			}
			const theme = ctx?.ui.theme;
			show(
				theme
					? theme.fg("accent", `◆ ${count} `) + theme.fg("dim", count === 1 ? "subagent" : "subagents")
					: `◆ ${count} subagents`,
			);
			// Nested foreground children change without lifecycle events, so poll
			// while something is active. Untargeted status is an in-memory read.
			if (!poller) poller = setInterval(() => void refresh(), POLL_MS);
		} while (queued);
		inflight = false;
	}

	// Lifecycle events arrive in bursts; collapse them into one status read.
	function refreshSoon() {
		if (debounce) return;
		debounce = setTimeout(() => {
			debounce = undefined;
			void refresh();
		}, 250);
	}

	pi.events.on(RPC_READY, refreshSoon); // fires after pi-subagents restores runs
	pi.events.on(ASYNC_STARTED, refreshSoon);
	pi.events.on(ASYNC_COMPLETE, refreshSoon);
	pi.on("session_start", (_event, context) => {
		ctx = context;
		lastText = undefined; // fresh footer: force the next read to render
	});
	pi.on("session_shutdown", () => {
		if (debounce) clearTimeout(debounce);
		debounce = undefined;
		stopPolling();
		show(undefined);
		ctx = undefined;
	});
	pi.on("tool_execution_start", (event) => {
		if (event.toolName === "subagent") refreshSoon();
	});
	pi.on("tool_execution_update", (event) => {
		if (event.toolName === "subagent") refreshSoon();
	});
}
