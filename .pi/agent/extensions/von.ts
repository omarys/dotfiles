import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import * as fs from "node:fs";
import * as path from "node:path";

interface VonConfig {
enabled: boolean;
endpoint: string;
enableGating: boolean;
timeoutMs: number;
}

const DEFAULT_CONFIG: VonConfig = {
enabled: true,
endpoint: process.env.VON_API_BASE || process.env.TYPESAFE_API_BASE || "http://127.0.0.1:8000",
enableGating: false,
timeoutMs: 3000,
};

function getConfigFile(ctx: any): string {
const baseDir = ctx.cwd ? path.join(ctx.cwd, ".pi") : path.join(process.env.HOME || "~", ".pi");
return path.join(baseDir, "von.json");
}

function loadConfig(ctx: any): VonConfig {
try {
  const configPath = getConfigFile(ctx);
  if (fs.existsSync(configPath)) {
    const data = JSON.parse(fs.readFileSync(configPath, "utf-8"));
    return { ...DEFAULT_CONFIG, ...data };
  }
} catch {
  // fallback to defaults
}
if (process.env.VON_ENABLED !== undefined) {
  DEFAULT_CONFIG.enabled = process.env.VON_ENABLED === "1" || process.env.VON_ENABLED === "true";
}
return { ...DEFAULT_CONFIG };
}

function saveConfig(ctx: any, config: VonConfig) {
try {
  const configPath = getConfigFile(ctx);
  fs.mkdirSync(path.dirname(configPath), { recursive: true });
  fs.writeFileSync(configPath, JSON.stringify(config, null, 2), "utf-8");
} catch (err: any) {
  ctx.ui.notify(`Failed to save Von config: ${err.message}`, "error");
}
}

async function queryVon(endpoint: string, payload: any, timeoutMs: number) {
const controller = new AbortController();
const timer = setTimeout(() => controller.abort(), timeoutMs);

try {
  const url = `${endpoint.replace(/\/+$/, "")}/v1/systemone`;
  const resp = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
    signal: controller.signal,
  });

  if (!resp.ok) {
    throw new Error(`Von HTTP ${resp.status}: ${await resp.text()}`);
  }
  return await resp.json();
} finally {
  clearTimeout(timer);
}
}

export default function (pi: ExtensionAPI) {
// -------------------------------------------------------------
// 1. Tool: von_evaluate
// -------------------------------------------------------------
pi.registerTool({
  name: "von_evaluate",
  label: "Von System One Evaluator",
  description:
    "Performs rapid, calibrated non-autoregressive decision making using local Von (Jev drop-in). Modes: 'choice' (select from options), 'noul' (yes/no
probability), or 'score' (0-10 numerical scoring).",
  parameters: Type.Object({
    mode: Type.Union([
      Type.Literal("choice"),
      Type.Literal("noul"),
      Type.Literal("score"),
    ], { description: "Evaluation primitive mode" }),
    query: Type.String({ description: "Question or decision criteria to evaluate" }),
    state: Type.Optional(Type.String({ description: "Context or state payload to judge (keep < 512 tokens for Von)" })),
    options: Type.Optional(Type.Array(Type.String(), { description: "Options to select from (required for 'choice' mode)" })),
  }),
  async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
    const config = loadConfig(ctx);

    if (!config.enabled) {
      return {
        content: [
          {
            type: "text",
            text: "Von evaluation is currently DISABLED by user preference. Proceed with standard LLM reasoning.",
          },
        ],
        details: { disabled: true },
      };
    }

    try {
      const payload = {
        mode: params.mode,
        query: params.query,
        state: params.state || "",
        options: params.options || [],
      };

      const result = await queryVon(config.endpoint, payload, config.timeoutMs);
      return {
        content: [
          {
            type: "text",
            text: `Von Result (${params.mode}):\n` + JSON.stringify(result, null, 2),
          },
        ],
        details: result,
      };
    } catch (err: any) {
      return {
        content: [
          {
            type: "text",
            text: `Von evaluation failed (${err.message}). Defaulting to standard agent reasoning.`,
          },
        ],
        details: { error: err.message },
      };
    }
  },
});

// -------------------------------------------------------------
// 2. Command: /von
// -------------------------------------------------------------
pi.registerCommand("von", async (args, ctx) => {
  const config = loadConfig(ctx);
  const sub = (args || "").trim().split(/\s+/)[0]?.toLowerCase();
  const rest = (args || "").trim().slice(sub.length).trim();

  switch (sub) {
    case "off":
    case "disable": {
      config.enabled = false;
      saveConfig(ctx, config);
      ctx.ui.notify("Von integration has been DISABLED.", "warning");
      break;
    }

    case "on":
    case "enable": {
      config.enabled = true;
      saveConfig(ctx, config);
      ctx.ui.notify(`Von integration ENABLED (endpoint: ${config.endpoint}).`, "info");
      break;
    }

    case "toggle": {
      config.enabled = !config.enabled;
      saveConfig(ctx, config);
      ctx.ui.notify(`Von is now ${config.enabled ? "ENABLED" : "DISABLED"}.`, "info");
      break;
    }

    case "set-url": {
      if (!rest) {
        ctx.ui.notify("Usage: /von set-url <http://host:port>", "error");
        return;
      }
      config.endpoint = rest;
      saveConfig(ctx, config);
      ctx.ui.notify(`Von endpoint updated to: ${config.endpoint}`, "info");
      break;
    }

    case "gate": {
      if (rest === "on") {
        config.enableGating = true;
        saveConfig(ctx, config);
        ctx.ui.notify("Von tool safety gating enabled.", "info");
      } else if (rest === "off") {
        config.enableGating = false;
        saveConfig(ctx, config);
        ctx.ui.notify("Von tool safety gating disabled.", "info");
      } else {
        ctx.ui.notify(`Usage: /von gate on | /von gate off (currently: ${config.enableGating ? "on" : "off"})`, "info");
      }
      break;
    }

    case "test": {
      ctx.ui.notify(`Testing Von at ${config.endpoint}...`, "info");
      try {
        const start = Date.now();
        const res = await queryVon(
          config.endpoint,
          {
            mode: "choice",
            query: "Classify priority",
            options: ["low", "medium", "high"],
            state: "System running smoothly with minor log warnings",
          },
          config.timeoutMs
        );
        const elapsed = Date.now() - start;
        ctx.ui.notify(`Von OK (${elapsed}ms): ${JSON.stringify(res)}`, "info");
      } catch (err: any) {
        ctx.ui.notify(`Von test failed: ${err.message}`, "error");
      }
      break;
    }

    case "status":
    default: {
      ctx.ui.notify(
        `Von Status: ${config.enabled ? "ENABLED" : "DISABLED"}\n` +
        `Endpoint: ${config.endpoint}\n` +
        `Safety Gating: ${config.enableGating ? "ON" : "OFF"}\n` +
        `Commands: /von on | /von off | /von toggle | /von test | /von gate <on|off> | /von set-url <url>`,
        "info"
      );
      break;
    }
  }
});

// -------------------------------------------------------------
// 3. Optional Event Interceptor: Tool Safety Gating
// -------------------------------------------------------------
pi.on("tool_call", async (event: any, ctx: any) => {
  const config = loadConfig(ctx);
  if (!config.enabled || !config.enableGating) return;

  // Only gate command executions
  if (event.toolName === "run_command" || event.toolName === "bash") {
    const command = event.params?.CommandLine || event.params?.command || "";
    try {
      const check = await queryVon(
        config.endpoint,
        {
          mode: "noul",
          query: "Is this shell command potentially destructive or risky to execute without asking?",
          state: command,
        },
        1500
      );

      if (check.probability > 0.75) {
        ctx.ui.notify(`Von Gate Warning: Flagged potentially risky command (${Math.round(check.probability * 100)}% risk)`, "warning");
      }
    } catch {
      // Silently skip if Von is unresponsive so normal flow isn't blocked
    }
  }
});
}

