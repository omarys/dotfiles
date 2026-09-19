/**
 * Runnable check for the subagent-activity footer extension.
 *   node ~/.pi/agent/extensions/subagent-activity/self-check.mjs
 * Fakes the pi event bus plus a pi-subagents RPC bridge and asserts the footer
 * text tracks active count, follows polling, and clears when idle.
 */

import assert from "node:assert/strict";
import createExtension from "./index.ts";

const listeners = new Map();
const bus = {
	on(channel, handler) {
		const set = listeners.get(channel) ?? new Set();
		set.add(handler);
		listeners.set(channel, set);
		return () => set.delete(handler);
	},
	emit(channel, data) {
		for (const handler of [...(listeners.get(channel) ?? [])]) handler(data);
	},
};

let active = 1;
let statusReads = 0;
bus.on("subagents:rpc:v1:request", (request) => {
	if (request.method !== "status") return;
	statusReads++;
	bus.emit(`subagents:rpc:v1:reply:${request.requestId}`, {
		version: 1,
		requestId: request.requestId,
		method: "status",
		success: true,
		data: { fleet: { version: 1, entries: [], totalActive: active, omitted: 0 } },
	});
});

const piHandlers = new Map();
const statuses = [];
const ctx = {
	hasUI: true,
	ui: { theme: { fg: (_color, text) => text }, setStatus: (key, text) => statuses.push([key, text]) },
};
const pi = {
	events: bus,
	on(name, handler) {
		piHandlers.set(name, [...(piHandlers.get(name) ?? []), handler]);
	},
};
const fire = (name, event = {}) => {
	for (const handler of piHandlers.get(name) ?? []) handler(event, ctx);
};

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
const last = () => statuses.at(-1);

createExtension(pi);
fire("session_start");
await sleep(50);
assert.equal(statuses.length, 0, "idle before any trigger");

bus.emit("subagents:rpc:v1:ready", {});
await sleep(600); // 250ms debounce + round trip
assert.deepEqual(last(), ["subagents-active", "◆ 1 subagent"], "one active child renders");

active = 3; // no event: only the poller can notice
await sleep(2400);
assert.deepEqual(last(), ["subagents-active", "◆ 3 subagents"], "poller tracks nested children");

active = 0;
bus.emit("subagent:async-complete", {});
await sleep(600);
assert.deepEqual(last(), ["subagents-active", undefined], "clears when idle");

const readsWhileIdle = statusReads;
await sleep(2400);
assert.equal(statusReads, readsWhileIdle, "polling stops once idle");

fire("session_shutdown");
assert.deepEqual(last(), ["subagents-active", undefined]);

console.log("subagent-activity self-check passed");
