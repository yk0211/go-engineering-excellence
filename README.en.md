# Go Engineering Excellence

> **Go Engineering Excellence** — a cross-platform Skill built on the open Agent Skills specification. It turns the Go engineering standards from Google, Uber, and the Go team into enforceable, machine-readable guidelines for **writing, reviewing, and refactoring** Go code. One directory works across agents, with no per-agent rewrites.
>
> **Supported agents**: WorkBuddy · Claude Code · OpenAI Codex / ChatGPT · Cursor (v2.4+) · DeepSeek Harness, and any agent implementing the Agent Skills specification. See "Cross-Agent Compatibility" below.

English · [简体中文](./README.md)

---

## The Problem It Solves

Go's conventions are scattered across several documents: Google's four-page style series, Uber's long-form guide, and the Go team's *Effective Go* and *Go Code Review Comments*. They complement each other, yet carry explicit differences in authority — Google itself distinguishes between *normative*, *canonical*, and *auxiliary* documents. Recalling every rule while coding is unrealistic, and asking an AI assistant for "idiomatic Go" usually yields only generic commonplaces.

This Skill consolidates those standards into **a resident core, layered references, and an executable check**:

- **`SKILL.md`** — always in context: the five readability principles, 13 mandatory rules, and three workflows (write / review / refactor).
- **`references/`** — loaded on demand: eight topic files, each rule paired with good / bad code examples.
- **`scripts/`** — deterministic execution: one command runs gofmt / goimports / go vet / staticcheck / go test -race.

It follows **progressive disclosure**: only the highest-value rules live in `SKILL.md`; details are pulled in when needed, so the context window is never flooded.

---

## Referenced Standards: Names and URLs

> This section lists the **exact names and official URLs** of every external standard this Skill is based on. Every rule is traceable to one of the sources below.

### A. Google Go Style Guide (official four-part series)

| Standard | Role | Official URL |
| --- | --- | --- |
| Go Style Guide — **Overview** | Series overview; defines normative / canonical / auxiliary terminology | https://google.github.io/styleguide/go/ |
| Go Style Guide — **Guide** | **normative and canonical** core guide: Clarity, Simplicity, Concision, Maintainability, Consistency | https://google.github.io/styleguide/go/guide |
| **Go Style Decisions** | Normative but not canonical; concrete decisions on naming, MixedCaps, formatting, line length, import aliasing | https://google.github.io/styleguide/go/decisions |
| **Go Style Best Practices** | Auxiliary document (neither normative nor canonical): naming, error handling, documentation, tests, function argument lists | https://google.github.io/styleguide/go/best-practices |

Publisher: Google · Source repository: https://github.com/google/styleguide

### B. Uber Go Style Guide

| Standard | Role | Official URL |
| --- | --- | --- |
| **Uber Go Style Guide** | De-facto community standard. Error handling, goroutine lifecycles, data integrity, global state, performance, code structure | https://github.com/uber-go/guide/blob/master/style.md |

Publisher: Uber (`uber-go`) · Source repository: https://github.com/uber-go/guide · Bundled lint config: https://github.com/uber-go/guide/blob/master/.golangci.yml

### C. Official Go Documentation (Go Team)

| Standard | Role | Official URL |
| --- | --- | --- |
| **Effective Go** | Foundational guide to clear, idiomatic Go (written for the 2009 release; no longer actively updated, does not cover generics / modules) | https://go.dev/doc/effective_go |
| **Go Code Review Comments** | Collection of common review comments; a supplement to *Effective Go* | https://go.dev/wiki/CodeReviewComments |
| **Go Test Comments** | Review comments specific to test code | https://go.dev/wiki/TestComments |
| **Go Doc Comments** | Specification for documentation comments (godoc) | https://go.dev/doc/comment |
| **The Go Programming Language Specification** | The language specification itself | https://go.dev/ref/spec |

### D. Referenced Tooling

| Tool / Standard | Purpose | Official URL |
| --- | --- | --- |
| **gofmt** | Enforced formatting; this Skill requires `gofmt -l` to return empty | https://pkg.go.dev/cmd/gofmt |
| **goimports** | Import grouping and automatic add/remove | https://pkg.go.dev/golang.org/x/tools/cmd/goimports |
| **go vet** | Static checks (including copylocks / shadow hints) | https://pkg.go.dev/cmd/vet |
| **Staticcheck** | 150+ checks for correctness, simplification, maintainability, and style | https://staticcheck.dev/ |
| **Go Race Detector** (`go test -race`) | Data-race detection | https://go.dev/doc/articles/race_detector |
| **go.uber.org/atomic** | Type-safe atomic types, recommended by the Uber guide over raw `sync/atomic` | https://pkg.go.dev/go.uber.org/atomic |

### E. Standard → Skill File Mapping

| Skill file | Primary sources |
| --- | --- |
| `SKILL.md` | Google Guide (core philosophy), Uber Guide (mandatory rules) |
| `references/naming.md` | Google Decisions + Best Practices, Uber *Function Names* |
| `references/errors.md` | Google Best Practices *Error handling*, Uber *Error Types / Error Wrapping* |
| `references/concurrency.md` | Uber *Channel Size / Goroutine Lifecycles / Zero-value Mutexes* |
| `references/design.md` | Google Best Practices *Function argument lists*, Uber *Pointers to Interfaces*, Effective Go |
| `references/testing.md` | Google Best Practices *Tests*, Go Test Comments |
| `references/formatting.md` | Google Guide/Decisions *Formatting*, Uber *Style* sections |
| `references/safety.md` | Uber *Copy Slices and Maps at Boundaries / Don't Panic / init()*, Go Code Review Comments |
| `references/performance.md` | Uber *Performance*, Google Best Practices *Size hints* |
| `scripts/go-check.sh` | Tooling listed in section D above |

### F. A Note on Meta (stated honestly)

**Meta (Facebook) does not publish a Go-specific style guide.** Go is not one of its primary languages, so this Skill cites no "Meta Go standard" and invents no URL for one. Its engineering culture — strong code ownership, simplicity, rigorous code review, and moving fast on stable infrastructure — is reflected only as a philosophy in the *Maintainability* and *Review workflow* sections of `SKILL.md`. General background reading (not a Go standard): https://engineering.fb.com/.

---

## Directory Structure

```
go-engineering-excellence/
├── SKILL.md                  # Required: triggers, core philosophy, mandatory rules, workflows
├── README.md                 # Simplified Chinese README
├── README.en.md              # This document (English)
├── references/               # Detailed rules, loaded on demand
│   ├── naming.md             # Naming
│   ├── errors.md             # Error handling
│   ├── concurrency.md        # Concurrency
│   ├── design.md             # API and interface design
│   ├── testing.md            # Testing
│   ├── formatting.md         # Formatting
│   ├── safety.md             # Safety and defensive programming (go-safety focus)
│   └── performance.md        # Performance (hot paths only)
└── scripts/
    ├── go-check.sh           # Format and quality checks (POSIX sh, dash-compatible)
    └── install.sh            # One-command multi-agent install (copy / symlink)
```

Distribution archive: `go-engineering-excellence.zip`

---

## Installation

This Skill follows the open Agent Skills specification: **one directory works across multiple agents**, with no content changes. Per-agent skill directories are listed below in "Cross-Agent Compatibility → Compatibility Matrix".

### One-command install (recommended)

After extracting `go-engineering-excellence.zip`:

```bash
sh scripts/install.sh all     # WorkBuddy + Claude Code + ~/.agents/skills/ (shared by Codex / Cursor / DeepSeek Harness)
```

For other options (specific agents, `MODE=link` symlinks, `SCOPE=project` for repo-local installs), see "Cross-Agent Compatibility → One-Command Install".

### Manual install

Place the whole `go-engineering-excellence/` directory (containing `SKILL.md`) into the matching location:

| Target agent | User scope | Project scope |
| --- | --- | --- |
| WorkBuddy | `~/.workbuddy/skills/` | `.workbuddy/skills/` |
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| OpenAI Codex / Cursor / DeepSeek Harness | `~/.agents/skills/` | `<repo>/.agents/skills/` |
| Cursor (dedicated directory, optional) | `~/.cursor/skills/` | `.cursor/skills/` |

Prefer `~/.agents/skills/`: one neutral directory covers several agents. On this machine the Skill is currently installed in the WorkBuddy user scope at `C:\Users\admin\.workbuddy\skills\go-engineering-excellence\`; use the script above to add the others.

---

## Cross-Agent Compatibility

This Skill follows the **open Agent Skills specification** (a directory containing `SKILL.md` whose YAML frontmatter has at least `name` and `description`). **WorkBuddy, Claude Code, OpenAI Codex, Cursor, and DeepSeek Harness can all read it as-is — no content changes required.** The only differences are where the directory lives and which optional platform-specific frontmatter fields you may add.

### Compatibility Matrix

| Agent | Support | User scope | Project scope | Explicit invocation |
| --- | --- | --- | --- | --- |
| **WorkBuddy** | Native | `~/.workbuddy/skills/` | `.workbuddy/skills/` | Auto-triggered via `description` |
| **Claude Code** | Native Agent Skills | `~/.claude/skills/` | `.claude/skills/` | `/go-engineering-excellence` |
| **OpenAI Codex / ChatGPT** | Native, built on the open Agent Skills standard | `~/.agents/skills/` | `<repo>/.agents/skills/` | `$go-engineering-excellence`, `/skills` |
| **Cursor** (v2.4+) | Native Agent Skills | `~/.cursor/skills/`, `~/.agents/skills/` | `.cursor/skills/`, `.agents/skills/` | `/skill-name` or `@` to attach |
| **DeepSeek Harness** | Native skill loading + `dsh-agent-skills` plugin | `~/.agents/skills/` | Skill directory | Automatic / manual load |

> **`~/.agents/skills/` is the de-facto neutral directory**: Codex, Cursor, and DeepSeek Harness (as well as Gemini CLI and opencode) all scan it, so one install covers several agents. Cursor additionally reads `~/.claude/skills/` and `~/.codex/skills/` for compatibility.

### Frontmatter Compatibility

| Field | This Skill | Notes |
| --- | --- | --- |
| `name` | Required | `go-engineering-excellence`: lowercase + hyphens, 25 characters, matches the directory name, and satisfies the ≤64-character / no-reserved-word rule |
| `description` | Required | States purpose and triggers, within the 1,024-character limit, with key trigger words front-loaded |
| `agent_created: true` | Platform-private | WorkBuddy-specific (used by `skill_manage` to modify/delete). Other platforms ignore it as an unknown field — **it does not block loading**. It can be removed for a purist setup |
| Other fields | None used | No platform-specific fields were introduced, to maximize portability |

### Differences and Caveats

- **Skill libraries do not sync across surfaces**: Claude Code skills are filesystem-based and separate from Skills uploaded to claude.ai or the API. Each surface needs its own copy.
- **Triggering depends on `description`**: Codex's initial skill list has a budget of roughly 8,000 characters (or 2% of the context window), and descriptions may be shortened — hence the key trigger words are front-loaded.
- **Scripts need execution permission**: `scripts/go-check.sh` is invoked by the agent as part of the workflow; it is not run automatically by the platform. Restricted sandboxes (Codex workspace-write, the Claude Code permission model) require granting shell access.
- **Chinese body text**: plain UTF-8 Markdown, universally supported; no conversion needed.
- **Optional platform-specific enhancements** (unknown fields are ignored by other platforms):
  - Cursor / Claude Code: `paths: ["**/*.go"]` to activate only for Go files.
  - Claude Code: `when_to_use`, `allowed-tools`, `disable-model-invocation`.
  - Codex: optional `agents/openai.yaml` for UI metadata, tool dependencies, and invocation policy.
  - DeepSeek Harness: with the `dsh-agent-skills` plugin, skills can be toggled in Settings → Agent Skills without modifying the original `SKILL.md`.

### One-Command Install

```bash
sh scripts/install.sh all                        # WorkBuddy + Claude Code + neutral directory
sh scripts/install.sh claude-code cursor codex    # Pick specific agents
MODE=link sh scripts/install.sh all              # Symlinks, single source of truth
SCOPE=project sh scripts/install.sh cursor       # Install into the current repository
FORCE=1 sh scripts/install.sh all                # Overwrite existing targets (files only, no directory deletion)
```

`MODE=copy` is the default (`ln -s` often needs extra privileges on Windows / Git Bash). In `link` mode a symlink is created only when the target does not exist — **nothing already on disk is deleted**. The script is POSIX `sh` and runs on Linux, macOS, and Git Bash.

### Sources Verified (Official Documentation)

| Document | URL |
| --- | --- |
| Claude Code — Extend Claude with skills | https://code.claude.com/docs/en/skills |
| Agent Skills specification (Claude Platform) | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview |
| Claude — Create custom skills | https://claude.com/docs/skills/how-to |
| OpenAI Codex — Build skills | https://developers.openai.com/codex/skills |
| AGENTS.md open format | https://agents.md/ |
| Cursor — Skills | https://cursor.com/docs/agent/commands |
| DeepSeek Harness | https://www.deepseek.com/harness/ |
| DSH `dsh-agent-skills` plugin | https://dshpluginhub.ai/zh/plugins/dsh-agent-skills |

---

## When It Triggers

Writing new Go packages / functions / APIs, reviewing Go code, refactoring existing Go code, designing interfaces or functional options, writing table-driven tests, and any task involving concurrency, performance, formatting, or package layout.

Typical triggers: Go naming conventions, error handling, interface design, concurrency patterns, table-driven tests, gofmt, go vet, code review.

---

## Mandatory Rules at a Glance (13)

1. Handle every error explicitly; never discard one with `_`. No `panic` in library code.
2. Handle an error **once**: either wrap and return, or log and degrade — never both log *and* return.
3. Wrap with `fmt.Errorf("context: %w", err)`; error strings are lowercase, unpunctuated, and avoid the `"failed to"` prefix.
4. Exported sentinel errors use the `Err` prefix for `errors.Is`; custom error types use the `Error` suffix.
5. Always use the comma-ok form for type assertions: `v, ok := i.(T)`. No bare assertions.
6. Never fire-and-forget a goroutine: it must be stoppable and awaitable; no goroutines in `init()`.
7. Channel capacity is 0 or 1; any other size requires strong justification.
8. `sync.Mutex` is valid at its zero value; use a named private field, **do not embed** it.
9. Copy at boundaries: copy incoming slices/maps before storing them, and copy outgoing ones that expose internal state.
10. Interfaces are defined by the **consumer**; accept interfaces, return concrete types. No pointers to interfaces.
11. `context.Context` is always the first parameter and is never stored in a struct.
12. Avoid mutable global state; use dependency injection instead.
13. Do not shadow predeclared identifiers (`error`, `string`, `len`, `make`, `new`, …); `go vet` must be clean.

**Structural limits (Uber recommendation)**: functions ≤ 50 lines, structs ≤ 200 lines, ≤ 4 parameters (use functional options beyond that).

---

## Quality Check Script

```bash
# Run from the module root (it walks up to find go.mod)
sh scripts/go-check.sh

# Or point it at an explicit root
GO_CHECK_ROOT=/path/to/repo sh scripts/go-check.sh
```

It runs `gofmt -l`, `goimports -l` (optional), `go vet ./...`, `staticcheck ./...` (optional), and `go test -race ./...` in sequence, then prints a PASS / FAIL summary. It exits with code 1 if any step fails, so it can be wired directly into CI.

The script is POSIX `sh` (dash / bash / zsh compatible) and avoids bash-only features such as process substitution, so it runs on Linux, macOS, and Git Bash alike.

Missing `goimports` / `staticcheck` are skipped with install hints rather than treated as failures:

```bash
go install golang.org/x/tools/cmd/goimports@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
```

---

## Customization and Maintenance

- **Adding team conventions**: put them in the matching `references/` topic file and register them in the topic index of `SKILL.md`. Never duplicate the same content in both places.
- **Changing priorities**: edit the *Mandatory Rules* list in `SKILL.md`; keep `references/` for detail and examples only.
- **Repackaging**: use the skill creation tooling to validate and package — it checks YAML frontmatter, naming conventions, and resource references.
- **Writing style**: Skill body text uses imperative / infinitive form (verb-first) for AI consumption, not second person.

---

## Version and Provenance

| Field | Value |
| --- | --- |
| Skill name | `go-engineering-excellence` |
| Supported agents | WorkBuddy · Claude Code · OpenAI Codex / ChatGPT · Cursor (v2.4+) · DeepSeek Harness |
| Scope | User-level or project-level (see the compatibility matrix) |
| Language | Simplified Chinese body text with English technical terms / identifiers |
| Standards baseline | Google Go Style Guide, Uber Go Style Guide, official Go documentation (URLs above) |
| Last organized | 2026-11-13 |

All cited links are the publishers' official addresses. When an upstream standard changes, the official page takes precedence; update the corresponding rules and the mapping table in this Skill accordingly.
