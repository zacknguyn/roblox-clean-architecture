# roblox-clean-architecture-skill

Universal skill for building prestige-quality Roblox games with clean architecture, server-authority, and exploiter-hardened patterns.

## What This Is

A **skill definition** (Anthropic/Claude/OpenCode/Gemini/Codex compatible) that teaches any AI agent your architecture conventions. Drop it into your agent's skill directory or include it in a project template repo.

## What It Covers

- **Realm separation** (`shared/server/client`) — non-negotiable boundaries
- **Service pattern** — feature folders with `init.luau`, auto-bootstrap
- **Config privacy** — `server/Services/X/Config.luau` (private) vs `shared/Configs/GameConfig` (public)
- **Networking singleton** — `shared/Networking/Remotes.luau` (one source of truth)
- **Exploiter hardening** — distance gates, cooldown tables, one-way result remotes, server-only RNG
- **Code quality** — Selene + StyLua, typed Luau, no magic strings
- **Toolchain** — Rokit-managed Rojo, Wally, Selene, StyLua

## Quick Install (as a project template)

```bash
# 1. Use this repo as a GitHub template, OR clone + copy the skill
git clone https://github.com/you/roblox-clean-architecture-skill MyGame
cd MyGame

# 2. Install toolchain
rokit install
wally install

# 3. Develop
rojo serve
```

## Skill File

The core definition is [`SKILL.md`](SKILL.md) — agents load this to understand your conventions.

## Project Template Structure

```
src/
├── shared/
│   ├── Configs/
│   │   └── GameConfig.luau
│   ├── Networking/
│   │   └── Remotes.luau
│   └── Modules/
├── server/
│   ├── Services/
│   │   └── ExampleService/
│   │       ├── init.luau
│   │       └── Config.luau
│   └── init.server.luau
└── client/
    ├── Services/
    │   └── ExampleClientService/
    │       └── init.luau
    └── init.client.luau
```

Copy the `src/` folder into a new Rojo project, run `rokit install && wally install`, and you have a clean architecture from day one.

## License

MIT — use freely in any project.