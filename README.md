# roblox-clean-architecture

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Template](https://img.shields.io/badge/GitHub-Template-blue?logo=github)](https://github.com/zacknguyn/roblox-clean-architecture/generate)
[![Rojo](https://img.shields.io/badge/Rojo-7.x-orange?logo=roblox)](https://rojo.space/)
[![Wally](https://img.shields.io/badge/Wally-0.3.x-purple)](https://wally.run/)
[![Rokit](https://img.shields.io/badge/Rokit-managed-green)](https://github.com/rojo-rbx/rokit)

**Universal architecture for prestige-quality Roblox games.**  
Server-authoritative, exploiter-hardened, AI-agent compatible.

---

## Why This Exists

Most Roblox projects suffer from:
- ❌ Game logic on the client (exploiters win)
- ❌ Private configs in `shared/` (odds/seed leaked)
- ❌ Ad-hoc RemoteEvents (magic strings, typos)
- ❌ No distance checks on ProximityPrompts (`:Trigger()` from anywhere)
- ❌ `math.random()` for gameplay (predictable rolls)
- ❌ No CI enforcement (architecture drifts)

**This template fixes all of it from day one.**

---

## What You Get

| Feature | Implementation |
|---------|----------------|
| **Server Authority** | Client sends requests → Server validates, computes, grants, replies |
| **Realm Separation** | `shared/` (safe), `server/` (private), `client/` (view only) |
| **Service Pattern** | `Services/XService/{init.luau, Config.luau}` auto-bootstrapped |
| **Config Privacy** | Private odds/seed in `server/Config.luau` • Public display in `shared/GameConfig.luau` |
| **Networking** | Single `Remotes.luau` — `*Request` (client→server), `*Result` (server→client) |
| **Exploiter Hardening** | Distance gates, `UserId` cooldown tables, one-way result remotes, `Random.new()` |
| **CI Enforcement** | Selene plugin with 8 architecture rules + StyLua formatting |
| **AI Agent Ready** | `SKILL.md` teaches any agent (Cursor, Claude, Codex, OpenCode) your conventions |

---

## Quick Start

### Option 1: GitHub Template (Recommended)

1. Click **[Use this template](https://github.com/zacknguyn/roblox-clean-architecture/generate)** → create your repo
2. Clone locally:
   ```bash
   git clone https://github.com/YOU/YourGame
   cd YourGame
   ```
3. Bootstrap:
   ```bash
   ./scripts/init.sh
   # → rokit install, wally install, rojo build, selene, stylua
   ```
4. Open `place.rbxlx` in Studio or run `rojo serve`

### Option 2: Manual Clone

```bash
git clone https://github.com/zacknguyn/roblox-clean-architecture MyGame
cd MyGame
./scripts/init.sh
```

---

## Architecture Overview

```
src/
├── shared/                    # ReplicatedStorage.Shared (safe, replicated)
│   ├── Configs/
│   │   └── GameConfig.luau    # Public display numbers (max slots, UI cooldowns)
│   ├── Networking/
│   │   └── Remotes.luau       # Single source of truth for all Remotes
│   └── Modules/               # Pure logic usable by both realms
├── server/                    # ServerScriptService.Server (AUTHORITATIVE ONLY)
│   ├── Services/
│   │   └── ExampleService/
│   │       ├── init.luau      # Event handlers, validation, computation
│   │       └── Config.luau    # PRIVATE: odds, seeds, internal cooldowns
│   └── init.server.luau       # Bootstraps all Services/*/init.luau
└── client/                    # StarterPlayerScripts.Client (VIEW ONLY)
    ├── Services/
    │   └── ExampleClientService/
    │       └── init.luau      # Listens to Remotes, updates UI only
    └── init.client.luau       # Bootstraps all Services/*/init.luau
```

---

## Core Rules (Non-Negotiable)

| Rule | Why |
|------|-----|
| **Client asks, Server decides** | Never put validation, RNG, or rewards on client |
| **Private configs stay in `server/`** | Odds, seeds, economy multipliers never replicate |
| **All Remotes in `Remotes.luau`** | No `Instance.new("RemoteEvent")` inline, no magic strings |
| **Distance gate every ProximityPrompt** | `(root.Position - part.Position).Magnitude <= Config.Range` |
| **Cooldowns in server table keyed by `UserId`** | `cooldowns[userId] = os.clock() + Config.Cooldown` |
| **`Random.new(seed)` only** | Never `math.random()` for gameplay |
| **Result remotes are one-way** | Server→Client only; no `OnServerEvent` on `*Result` |
| **Tag instances, don't hardcode paths** | `CollectionService:GetTagged("MyTag")` |

---

## Adding a New Feature

### 1. Create Server Service
```bash
# src/server/Services/LootService/init.luau + Config.luau
```
```luau
-- init.luau
local Remotes = require(ReplicatedStorage.Shared.Networking.Remotes).init()
local Config = require(script.Config)

Remotes.LootRequest.OnServerEvent:Connect(function(player)
    -- 1. Validate (distance, cooldown, permissions)
    -- 2. Compute (Random.new(Config.Seed))
    -- 3. Grant (apply rewards server-side)
    -- 4. Remotes.LootResult:FireClient(player, result)
end)
```

### 2. Create Client Service (if UI needed)
```bash
# src/client/Services/LootClientService/init.luau
```
```luau
Remotes.LootResult.OnClientEvent:Connect(function(result)
    -- Update UI only
end)
```

### 3. Register Remotes
```luau
-- shared/Networking/Remotes.luau
Remotes.LootRequest = getOrCreate("LootRequest")
Remotes.LootResult  = getOrCreate("LootResult")
```

### 4. Add Public Display Numbers (if client shows them)
```luau
-- shared/Configs/GameConfig.luau
return { MaxLootSlots = 50, LootCooldownDisplay = 1 }
```

### 5. Tag Instances (ProximityPrompts, Parts)
```lua
-- In Studio: Tag the ProximityPrompt with "LootPrompt"
-- Server: CollectionService:GetTagged("LootPrompt")
```

---

## Toolchain

Managed by **Rokit** (see `rokit.toml`):

| Tool | Purpose |
|------|---------|
| **Rojo 7.x** | File-system ↔ Roblox sync |
| **Wally 0.3.x** | Luau package manager |
| **Selene 0.31.x** | Linter with architecture rules |
| **StyLua 2.5.x** | Formatter |

Run locally:
```bash
rokit install      # Installs all tools to ~/.rokit/bin
wally install      # Installs Wally packages
selene src         # Lint (enforces architecture rules)
stylua src         # Format
rojo build -o place.rbxlx
rojo serve         # Live sync to Studio
```

---

## CI/CD (`.github/workflows/ci.yml`)

Runs on every push/PR:
```yaml
- selene src        # Architecture enforcement
- stylua src        # Format check
- rojo build        # Compile verification
```

---

## Selene Plugin Rules (Enforced)

| Rule | Severity | Catches |
|------|----------|---------|
| `no_server_config_in_shared` | error | Private config required from shared/client |
| `no_math_random_gameplay` | error | `math.random()` in gameplay context |
| `no_hardcoded_workspace_path` | error | `Workspace:WaitForChild("X")` |
| `no_client_fires_result_remote` | error | Client fires `*Result` remote |
| `no_server_handler_on_result_remote` | error | `OnServerEvent` on `*Result` |
| `missing_distance_gate` | error | ProximityPrompt handler without distance check |
| `no_magic_remote_strings` | warn | Inline remote creation/string names |
| `require_remotes_module` | warn | Direct `ReplicatedStorage.X` access |

---

## AI Agent Integration

The `SKILL.md` teaches any AI your conventions.

### Install to Agent (after `init.sh`):
```bash
# Auto-detects .cursor/, .claude/, .codex/, .gemini/, .opencode/
phong-rojo install --with-skill   # (after CLI publish)
```

### Manual Install:
| Agent | Location |
|-------|----------|
| **Cursor** | `.cursor/rules/roblox-clean-architecture.md` |
| **Claude Code** | `.claude/commands/roblox-clean-architecture.md` |
| **Codex** | `.codex/instructions/roblox-clean-architecture.md` |
| **OpenCode** | `.opencode/skill/roblox-clean-architecture/SKILL.md` |
| **Gemini** | `.gemini/instructions/roblox-clean-architecture.md` |

---

## Example: Secure Loot Roll

**Server (`LootService/init.luau`):**
```lua
Remotes.LootRequest.OnServerEvent:Connect(function(player)
    -- Distance gate
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or (root.Position - lootPart.Position).Magnitude > Config.Range then return end

    -- Cooldown
    local now = os.clock()
    if cooldowns[player.UserId] and now < cooldowns[player.UserId] then return end
    cooldowns[player.UserId] = now + Config.Cooldown

    -- Server-only RNG
    local rng = Random.new(Config.Seed)
    local roll = weightedPick(Config.Outcomes, rng)

    -- Grant + reply
    giveItem(player, roll.Name)
    Remotes.LootResult:FireClient(player, roll.Name)
end)
```

**Client (`LootClientService/init.luau`):**
```lua
Remotes.LootResult.OnClientEvent:Connect(function(itemName)
    -- Only UI update
    showLootToast(itemName)
end)
```

---

## Project Structure Reference

```
roblox-clean-architecture/
├── LICENSE
├── README.md
├── SKILL.md                      # Universal AI agent instructions
├── .gitignore
└── template/                     # GitHub template source
    ├── SKILL.md                  # Copied to every new project
    ├── scripts/init.sh           # One-command bootstrap
    ├── .github/workflows/ci.yml  # CI: selene + stylua + rojo build
    ├── rokit.toml                # Tool versions
    ├── wally.toml                # Wally packages
    ├── selene.toml               # Linter config + plugin
    ├── stylua.toml               # Formatter config
    ├── default.project.json      # Rojo project mapping
    └── src/
        ├── shared/
        │   ├── Configs/GameConfig.luau
        │   ├── Networking/Remotes.luau
        │   └── Modules/
        ├── server/
        │   ├── Services/ExampleService/{init.luau, Config.luau}
        │   └── init.server.luau
        └── client/
            ├── Services/ExampleClientService/init.luau
            └── init.client.luau
```

---

## License

MIT — use freely in any project. See [LICENSE](LICENSE).

---

## Credits

Built for **prestige-quality Roblox games**.  
Architecture patterns inspired by production Roblox studios.  
Selene plugin enforces what Markdown only documents.

**Author:** [Phong](https://github.com/zacknguyn)  
**Issues/PRs:** [github.com/zacknguyn/roblox-clean-architecture](https://github.com/zacknguyn/roblox-clean-architecture)