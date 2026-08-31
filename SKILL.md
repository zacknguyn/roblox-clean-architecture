---
name: roblox-clean-architecture
version: 1.0.0
description: Universal skill for building prestige-quality Roblox games with clean architecture, server-authority, and exploiter-hardened patterns. Compatible with Claude, OpenCode, Gemini, Codex, Cursor, and any AI coding assistant.
author: Quang
tags: [roblox, luau, architecture, rojo, server-authority, security]
---

# Roblox Clean Architecture Skill

Universal conventions for building production-grade Roblox games. This skill defines the architecture, patterns, and security practices that any AI agent should follow when working on Roblox projects.

## Core Philosophy

> **The client asks; the server decides.** Never put game logic, validation, or private numbers on the client. The client only renders and sends intent. The server validates, computes, and replicates results.

---

## 1. Realm Separation (Non-Negotiable)

```
src/
├── shared/          # Replicated to client — safe data only
│   ├── Configs/     # GameConfig (client-needed numbers: UI caps, cooldowns shown to player)
│   ├── Networking/  # RemoteEvent/RemoteFunction definitions (single source of truth)
│   └── Modules/     # Pure logic usable by both realms (math, utilities, types)
├── server/          # ServerScriptService — AUTHORITATIVE LOGIC ONLY
│   ├── Services/    # Feature folders, each with init.luau
│   │   └── XService/
│   │       ├── init.luau      # Public API + event handlers
│   │       └── Config.luau    # PRIVATE: odds, seeds, internal cooldowns, economy numbers
│   └── init.server.luau       # Bootstraps all Services/*/init.luau
└── client/          # StarterPlayerScripts — VIEW ONLY
    ├── Services/    # Feature folders, each with init.luau
    │   └── XClientService/
    │       └── init.luau      # Listens to Remotes, updates UI/HUD
    └── init.client.luau       # Bootstraps all Services/*/init.luau
```

**Rules:**
- `server/` code **never** replicates to clients. Put private configs, RNG, economy, validation here.
- `shared/` code **must** be safe if a client reads it. No secrets, no server-only logic.
- `client/` code **never** makes decisions. Only renders, asks via Remotes, displays results.

---

## 2. Service Pattern

Every feature = a folder under `server/Services/` or `client/Services/` with `init.luau`.

### Server Service (`server/Services/XService/init.luau`)
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Networking.Remotes).init()
local Config = require(script.Config)  -- private, server-only

local XService = {}

function XService.init()
    -- Bind to events, set up listeners, start loops
end

return XService
```

### Client Service (`client/Services/XClientService/init.luau`)
```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Networking.Remotes).init()

local XClientService = {}

function XClientService.init()
    Remotes.SomeEvent.OnClientEvent:Connect(function(data)
        -- Update UI only
    end)
end

return XClientService
```

### Bootstrap (in `init.server.luau` / `init.client.luau`)
```lua
local function loadServices(container)
    for _, child in container:GetChildren() do
        local module = if child:IsA("ModuleScript") then child
            elseif child:IsA("Folder") then child:FindFirstChild("init")
            else nil

        if module then
            local ok, service = pcall(require, module)
            if ok and type(service) == "table" and type(service.init) == "function" then
                service.init()
            end
        end
    end
end

loadServices(script.Services)
```
> Handles Rojo's `init.luau` → ModuleScript collapse automatically.

---

## 3. Configuration Management

| Config Type | Location | Replicates? | Purpose |
|---|---|---|---|
| **Private (Server)** | `server/Services/XService/Config.luau` | ❌ Never | Odds, weights, seeds, internal cooldowns, economy multipliers, anti-cheat thresholds |
| **Public (Shared)** | `shared/Configs/GameConfig.luau` | ✅ Yes | UI display values: max slots, cooldown text, capacity numbers client needs for HUD |

**Never** put private numbers in `shared/`. If the client needs to *display* a number, duplicate it in `GameConfig` — the server remains the source of truth.

---

## 4. Networking — Single Source of Truth

`shared/Networking/Remotes.luau` defines **all** RemoteEvents/Functions. Both realms `require` it.

```luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Remotes = {}

local function getOrCreate(name: string)
    if RunService:IsServer() then
        local remote = ReplicatedStorage:FindFirstChild(name)
        if not remote then
            remote = Instance.new("RemoteEvent")
            remote.Name = name
            remote.Parent = ReplicatedStorage
        end
        return remote
    end
    return ReplicatedStorage:WaitForChild(name)
end

function Remotes.init()
    Remotes.ExampleRequest = getOrCreate("ExampleRequest")  -- Client → Server
    Remotes.ExampleResult  = getOrCreate("ExampleResult")   -- Server → Client
    return Remotes
end

return Remotes
```

**Direction naming convention:**
- `XxxRequest` = Client → Server (client asks)
- `XxxResult` / `XxxUpdate` = Server → Client (server decides/pushes)

**No `OnServerEvent` on result remotes.** Results are one-way server→client. Clients cannot spoof outcomes.

---

## 5. Exploiter-Hardening Checklist (Apply to Every Feature)

| Threat | Mitigation |
|---|---|
| `:Trigger()` / `FireServer` from distance | Server-side distance check: `(root.Position - part.Position).Magnitude <= Config.Range` |
| Spam / rapid-fire | Server-side cooldown table keyed by `UserId` using `os.clock()` |
| Client fakes result | Result remotes are **server→client only**; no `OnServerEvent` handler |
| Client reads odds/seed | Private configs in `server/` — never in `shared/` |
| Predictable RNG | Use `Random.new(seed)` on server; never `math.random`; seed from `Config.Seed` (nil = crypto) |
| Client chooses roll parameters | Server roll takes **zero client input** |
| Reward granting | Apply rewards **inside server handler**, never trust client to claim |

---

## 6. Code Quality Standards

- **Luau type annotations** on all function params/returns.
- **Selene** clean (0 warnings). Config: `selene.toml` in repo root.
- **StyLua** formatted. Config: `stylua.toml` in repo root.
- **No comments** unless explaining *why* (not *what*).
- **No magic strings** — use `Remotes` module, `Config` tables, constants.
- **No global state mutation** outside service `init()`.

---

## 7. Toolchain (Rokit-managed)

```toml
# rokit.toml
[tools]
rojo = "rojo-rbx/rojo@7.x"
wally = "UpliftGames/wally@0.3.x"
selene = "Kampfkarren/selene@0.31.x"
stylua = "JohnnyMorganz/stylua@2.5.x"
```

Run:
```bash
rokit install
wally install
selene src
stylua src
```

---

## 8. Adding a New Feature (Checklist)

1. Create `server/Services/NewFeature/` with `init.luau` + `Config.luau`
2. Create `client/Services/NewFeatureClient/` with `init.luau` (if UI needed)
3. Add entries to `shared/Networking/Remotes.luau`
4. Add public display numbers to `shared/Configs/GameConfig.luau` (if client shows them)
5. Implement server logic in `init.luau` — validate, compute, `FireClient`
6. Implement client listener — render only
7. Tag any workspace instances via CollectionService (not hardcoded paths)
8. Run `selene src && stylua src` → fix warnings
9. Test with exploiter mindset: spam, distance, fake remotes, read memory

---

## 9. Anti-Patterns (Reject These)

| ❌ Anti-Pattern | ✅ Correct |
|---|---|
| `LocalScript` does damage calc | Server validates & applies damage |
| `ModuleScript` in `shared/` with `game:GetService("ServerStorage")` | Move to `server/Services/` |
| `Config` with odds in `shared/` | Private `Config.luau` in `server/Services/X/` |
| `RemoteEvent` created ad-hoc in scripts | Central `Remotes.luau` singleton |
| `math.random()` for gameplay | `Random.new(seed)` with server-only seed |
| Client sends "I got legendary" | Server rolls, server grants, server fires result |
| Hardcoded `Workspace.TriggerPart` | `CollectionService` tag + `GetTagged` |

---

## 10. Quick Reference: File → Responsibility

| File | Realm | Responsibility |
|---|---|---|
| `server/Services/X/Config.luau` | Server | Private numbers, odds, seeds |
| `server/Services/X/init.luau` | Server | Event binding, validation, roll, grant, `FireClient` |
| `shared/Networking/Remotes.luau` | Both | RemoteEvent definitions, create/wait |
| `shared/Configs/GameConfig.luau` | Both | Client-safe display numbers |
| `client/Services/XClient/init.luau` | Client | `OnClientEvent` → UI update |
| `server/init.server.luau` | Server | Bootstrap all server services |
| `client/init.client.luau` | Client | Bootstrap all client services |

---

## Usage

Drop this skill into your AI assistant's skill directory, or include `.opencode/skill/roblox-clean-architecture/` in your project template repo. Any agent loading this skill will enforce the above architecture automatically.

---

*Built for prestige-quality Roblox games. Server-authority first. Exploiter-hardened by default.*