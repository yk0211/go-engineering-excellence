# Go 工程卓越规范

> **Go Engineering Excellence** — 一个遵循开放 Agent Skills 规范的**跨平台 Skill**，把 Google、Uber 与 Go 官方的 Go 工程规范，固化为可自动执行的「编写 / 评审 / 重构」准则。同一份文件，无需为不同 Agent 改写。
>
> **适用 Agent**：WorkBuddy · Claude Code · OpenAI Codex / ChatGPT · Cursor（v2.4+）· DeepSeek Harness，以及任何兼容 Agent Skills 规范的 Agent。详见下方「多 Agent 兼容性」。

简体中文 · [English](./README.en.md)

---

## 它解决什么问题

Go 的规范散落在多份文档里：Google 的四页系列、Uber 的一份长文、Go 官方的 *Effective Go* 与 *Go Code Review Comments*。它们互补，却有明确的优先级差异（Google 自己就区分 *normative* / *canonical* / 辅助文档）。写代码时逐条回忆不现实；直接让 AI 助手「写 idiomatic Go」，得到的往往只是泛泛的常识。

本 Skill 把这些规范收敛成**一份常驻准则 + 分层参考 + 可执行检查**：

- **`SKILL.md`** — 常驻上下文：五大可读性原则、13 条强制规则、三种工作流（编写 / 评审 / 重构）。
- **`references/`** — 按需加载：8 个主题文件，每条规则都配正例 / 反例代码。
- **`scripts/`** — 确定性执行：一条命令跑完 gofmt / goimports / go vet / staticcheck / go test -race。

采用渐进式披露：关键规则留在 `SKILL.md`，细节按需读取，避免占满上下文窗口。

---

## 引用的规范：名称与地址

> 本章列出本 Skill 所依据的全部外部规范的**准确名称与官方地址**。所有规则均可追溯到下列来源。

### A. Google Go Style Guide（官方系列，共 4 页）

| 规范名称 | 定位 | 官方地址 |
| --- | --- | --- |
| Go Style Guide — **Overview** | 系列总览，定义 normative / canonical / auxiliary 等术语 | https://google.github.io/styleguide/go/ |
| Go Style Guide — **Guide** | **normative and canonical**，核心指南：Clarity、Simplicity、Concision、Maintainability、Consistency | https://google.github.io/styleguide/go/guide |
| **Go Style Decisions** | normative 但非 canonical，具体决策：命名、MixedCaps、格式、行长度、导入别名等 | https://google.github.io/styleguide/go/decisions |
| **Go Style Best Practices** | 辅助文档（neither normative nor canonical）：命名、错误处理、文档、测试、函数参数列表 | https://google.github.io/styleguide/go/best-practices |

发布方：Google · 源仓库：https://github.com/google/styleguide

### B. Uber Go Style Guide

| 规范名称 | 定位 | 官方地址 |
| --- | --- | --- |
| **Uber Go Style Guide** | 社区事实标准。错误处理、并发生命周期、数据完整性、全局状态、性能、代码结构 | https://github.com/uber-go/guide/blob/master/style.md |

发布方：Uber (`uber-go`) · 源仓库：https://github.com/uber-go/guide · 附带的 lint 配置：https://github.com/uber-go/guide/blob/master/.golangci.yml

### C. Go 官方规范（Go Team）

| 规范名称 | 定位 | 官方地址 |
| --- | --- | --- |
| **Effective Go** | 编写清晰、惯用 Go 代码的基础指南（撰写于 2009 年，不再活跃更新，不含泛型 / modules） | https://go.dev/doc/effective_go |
| **Go Code Review Comments** | Go 代码评审常见意见集合，*Effective Go* 的补充 | https://go.dev/wiki/CodeReviewComments |
| **Go Test Comments** | 测试代码的评审意见 | https://go.dev/wiki/TestComments |
| **Go Doc Comments** | 文档注释（godoc）规范 | https://go.dev/doc/comment |
| **The Go Programming Language Specification** | 语言规范本身 | https://go.dev/ref/spec |

### D. 被引用的工具链

| 工具 / 规范名称 | 用途 | 官方地址 |
| --- | --- | --- |
| **gofmt** | 强制统一格式，本 Skill 要求 `gofmt -l` 必须为空 | https://pkg.go.dev/cmd/gofmt |
| **goimports** | import 分组与自动增删 | https://pkg.go.dev/golang.org/x/tools/cmd/goimports |
| **go vet** | 静态检查（含 copylocks / shadow 提示） | https://pkg.go.dev/cmd/vet |
| **Staticcheck** | 150+ 项静态分析：正确性、简化、可维护性、风格 | https://staticcheck.dev/ |
| **Go Race Detector** (`go test -race`) | 数据竞争检测 | https://go.dev/doc/articles/race_detector |
| **go.uber.org/atomic** | 类型安全的原子类型（Uber 规范推荐，替代裸 `sync/atomic`） | https://pkg.go.dev/go.uber.org/atomic |

### E. 规范 → Skill 文件映射

| Skill 文件 | 主要依据 |
| --- | --- |
| `SKILL.md` | Google Guide（核心哲学）、Uber Guide（强制规则） |
| `references/naming.md` | Google Decisions + Best Practices、Uber *Function Names* |
| `references/errors.md` | Google Best Practices *Error handling*、Uber *Error Types / Wrapping* |
| `references/concurrency.md` | Uber *Channel Size / Goroutine Lifecycle / Zero-value Mutexes* |
| `references/design.md` | Google Best Practices *Function argument lists*、Uber *Pointers to Interfaces*、Effective Go |
| `references/testing.md` | Google Best Practices *Tests*、Go Test Comments |
| `references/formatting.md` | Google Guide/Decisions *Formatting*、Uber *Style* 章节 |
| `references/safety.md` | Uber *Copy Slices and Maps at Boundaries / Don't Panic / init()*、Go Code Review Comments |
| `references/performance.md` | Uber *Performance*、Google Best Practices *Size hints* |
| `scripts/go-check.sh` | 上表 D 的工具链 |

### F. 关于 Meta（如实标注）

**Meta（Facebook）并未公开发布 Go 专属风格指南** —— Go 并非其主力语言，因此本 Skill 未引用任何「Meta Go 规范」，也未虚构地址。其工程文化（强代码所有权、简洁性、严格代码评审文化、在稳定基础设施上快速迭代）仅作为理念融入 `SKILL.md` 的「可维护性」与「评审流程」章节。泛指参考：https://engineering.fb.com/ （非 Go 规范）。

---

## 目录结构

```
go-engineering-excellence/
├── SKILL.md                  # 必需：触发条件、核心哲学、强制规则、工作流
├── README.md                 # 本文档（简体中文）
├── README.en.md              # English README
├── references/               # 按需加载的详细规则
│   ├── naming.md             # 命名
│   ├── errors.md             # 错误处理
│   ├── concurrency.md        # 并发
│   ├── design.md             # API 与接口设计
│   ├── testing.md            # 测试
│   ├── formatting.md         # 格式化
│   ├── safety.md             # 安全与防御性编程（go-safety 重点）
│   └── performance.md        # 性能（仅热路径）
└── scripts/
    ├── go-check.sh           # 格式与质量检查（POSIX sh，兼容 dash）
    └── install.sh            # 多 Agent 一键安装（copy / symlink）
```

分发包：`go-engineering-excellence.zip`

---

## 安装

本 Skill 遵循开放 Agent Skills 规范，**同一份目录可直接用于多个 Agent**，内容无需改写。各 Agent 的技能目录见下方「多 Agent 兼容性 → 兼容性矩阵」。

### 一键安装（推荐）

解压 `go-engineering-excellence.zip` 后运行：

```bash
sh scripts/install.sh all     # WorkBuddy + Claude Code + ~/.agents/skills/（Codex / Cursor / DeepSeek Harness 共用）
```

其它用法（指定平台、`MODE=link` 软链、`SCOPE=project` 装进仓库）见「多 Agent 兼容性 → 一键安装」。

### 手动安装

把 `go-engineering-excellence/` 整个目录（内含 `SKILL.md`）放到对应位置：

| 目标 Agent | 用户级目录 | 项目级目录 |
| --- | --- | --- |
| WorkBuddy | `~/.workbuddy/skills/` | `.workbuddy/skills/` |
| Claude Code | `~/.claude/skills/` | `.claude/skills/` |
| OpenAI Codex / Cursor / DeepSeek Harness | `~/.agents/skills/` | `<repo>/.agents/skills/` |
| Cursor（专用目录，可选） | `~/.cursor/skills/` | `.cursor/skills/` |

推荐优先使用 `~/.agents/skills/`——一个中立目录即可覆盖多家。本机当前已装在 WorkBuddy 用户级目录 `C:\Users\admin\.workbuddy\skills\go-engineering-excellence\`，其它 Agent 用上面的脚本补装即可。

---

## 多 Agent 兼容性

本 Skill 采用**开放 Agent Skills 规范**（目录内含 `SKILL.md`，YAML frontmatter 至少含 `name` + `description`），因此 **WorkBuddy、Claude Code、OpenAI Codex、Cursor、DeepSeek Harness 均可直接读取，无需改写任何内容**。差异只在「放到哪个目录」以及「可选的平台专属增强字段」。

### 兼容性矩阵

| Agent | 支持方式 | 用户级目录 | 项目级目录 | 显式调用 |
| --- | --- | --- | --- | --- |
| **WorkBuddy** | 原生 | `~/.workbuddy/skills/` | `.workbuddy/skills/` | 由 description 自动触发 |
| **Claude Code** | 原生 Agent Skills | `~/.claude/skills/` | `.claude/skills/` | `/go-engineering-excellence` |
| **OpenAI Codex / ChatGPT** | 原生，基于开放 Agent Skills 标准 | `~/.agents/skills/` | `<repo>/.agents/skills/` | `$go-engineering-excellence`、`/skills` |
| **Cursor**（v2.4+） | 原生 Agent Skills | `~/.cursor/skills/`、`~/.agents/skills/` | `.cursor/skills/`、`.agents/skills/` | `/skill-name` 或 `@` 附加 |
| **DeepSeek Harness** | 原生 skill 加载 + `dsh-agent-skills` 插件 | `~/.agents/skills/` | 技能目录 | 自动 / 手动加载 |

> **`~/.agents/skills/` 是事实上的中立目录**：Codex、Cursor、DeepSeek Harness（以及 Gemini CLI、opencode）都会扫描它，放一份即可覆盖多家；Cursor 还额外兼容读取 `~/.claude/skills/` 与 `~/.codex/skills/`。

### frontmatter 兼容性

| 字段 | 本 Skill | 说明 |
| --- | --- | --- |
| `name` | 必需 | `go-engineering-excellence`：全小写 + 连字符、25 字符，符合各平台「≤64 字符、不含保留词」要求，且与目录名一致 |
| `description` | 必需 | 含用途与触发条件，长度在 1024 字符限制内，关键触发词前置 |
| `agent_created: true` | 平台私有 | WorkBuddy 专用（供 `skill_manage` 修改 / 删除）。其他平台把它当作未知字段忽略，**不影响加载**；若追求纯净可删除此行 |
| 其他字段 | 未使用 | 刻意不引入任何平台专属字段，保证最大可移植性 |

### 差异与注意点

- **各平台技能库不互通**：Claude Code 的 skills 是文件系统级的，与 claude.ai / API 上传的 Skills 相互独立，需在各自环境分别放置。
- **触发依赖 `description`**：Codex 的初始技能列表有约 8000 字符（或上下文 2%）预算，描述可能被截断，因此本 Skill 把关键触发词放在句首。
- **脚本需授权执行**：`scripts/go-check.sh` 由 Agent 按工作流调用，不是平台自动运行；在受限沙箱（Codex workspace-write、Claude Code 权限模型）下需授予 shell 执行权限。
- **中文正文**：UTF-8 Markdown，各平台通用，无需转码。
- **平台专属增强（可选，其他平台会忽略未知字段）**：
  - Cursor / Claude Code：`paths: ["**/*.go"]`，仅在 Go 文件上下文激活。
  - Claude Code：`when_to_use`、`allowed-tools`、`disable-model-invocation`。
  - Codex：可选 `agents/openai.yaml`（UI 元数据、工具依赖、调用策略）。
  - DeepSeek Harness：安装 `dsh-agent-skills` 插件后可在「设置 → Agent Skills」启停，且不修改原始 `SKILL.md`。

### 一键安装

```bash
sh scripts/install.sh all                        # WorkBuddy + Claude Code + 中立目录
sh scripts/install.sh claude-code cursor codex    # 指定平台
MODE=link sh scripts/install.sh all              # 符号链接，保持单一真源
SCOPE=project sh scripts/install.sh cursor       # 装到当前仓库
FORCE=1 sh scripts/install.sh all                # 覆盖已存在目标（仅覆盖文件，不删目录）
```

默认 `MODE=copy`（Windows / Git Bash 下 `ln -s` 常需额外权限）；`link` 模式仅在目标不存在时创建链接，**不会删除任何已有内容**。脚本为 POSIX `sh`，可在 Linux / macOS / Git Bash 运行。

### 兼容性核实来源（官方文档）

| 文档 | 地址 |
| --- | --- |
| Claude Code — Extend Claude with skills | https://code.claude.com/docs/en/skills |
| Agent Skills 规范（Claude Platform） | https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview |
| Claude — Create custom skills | https://claude.com/docs/skills/how-to |
| OpenAI Codex — Build skills | https://developers.openai.com/codex/skills |
| AGENTS.md 开放格式 | https://agents.md/ |
| Cursor — Skills | https://cursor.com/docs/agent/commands |
| DeepSeek Harness | https://www.deepseek.com/harness/ |
| DSH `dsh-agent-skills` 插件 | https://dshpluginhub.ai/zh/plugins/dsh-agent-skills |

---

## 何时触发

编写新 Go 包 / 函数 / API、评审（review）Go 代码、重构现有 Go 代码、设计接口与 Option 模式、编写 table-driven 测试，以及并发、性能、格式化、包布局相关任务。

常见触发词：Go 命名规范、错误处理、interface 设计、并发模式、table-driven test、gofmt、go vet、代码评审。

---

## 核心规则速览（13 条强制规则）

1. 显式处理每一个错误，绝不用 `_` 静默丢弃；库代码不用 `panic`。
2. 错误只处理一次：要么包装后返回，要么记录并降级，**不要既 log 又 return**。
3. `fmt.Errorf("context: %w", err)` 包装；错误字符串不大写、不带标点、避免 `"failed to"` 前缀。
4. 导出哨兵错误用 `Err` 前缀，供 `errors.Is` 匹配；自定义错误类型用 `Error` 后缀。
5. 类型断言一律 comma-ok：`v, ok := i.(T)`，禁止裸断言。
6. 绝不「发射后不管」的 goroutine：必须可停止、可被等待；`init()` 中不启动 goroutine。
7. channel 容量为 0 或 1，其他尺寸需极强理由。
8. `sync.Mutex` 零值有效，用命名私有字段，**不要嵌入**。
9. 边界拷贝：存储传入的 slice/map 前拷贝；返回暴露内部状态的 slice/map 前拷贝。
10. 接口由**消费者**定义，接受接口、返回具体类型；不用接口指针。
11. `context.Context` 永远是函数第一个参数，不存入 struct。
12. 避免可变全局状态，改用依赖注入。
13. 不遮蔽预声明标识符（`error`、`string`、`len`、`make`、`new`…），`go vet` 必须干净。

**结构限制（Uber 建议）**：函数 ≤ 50 行、struct ≤ 200 行、参数 ≤ 4（超出改 functional options）。

---

## 质量检查脚本

```bash
# 在当前模块根运行（自动向上查找 go.mod）
sh scripts/go-check.sh

# 指定根目录
GO_CHECK_ROOT=/path/to/repo sh scripts/go-check.sh
```

依次执行 `gofmt -l`、`goimports -l`（可选）、`go vet ./...`、`staticcheck ./...`（可选）、`go test -race ./...`，最后输出 PASS / FAIL 汇总；存在失败项时退出码为 1，可直接接入 CI。

脚本为 POSIX `sh` 语法（dash / bash / zsh 通用），未使用进程替换等 bash 专属特性，可在 Linux / macOS / Git Bash 下运行。

未安装 `goimports` / `staticcheck` 时会跳过并给出安装命令，不会导致失败：

```bash
go install golang.org/x/tools/cmd/goimports@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
```

---

## 定制与维护

- **新增团队约定**：写入 `references/` 对应主题文件，并在 `SKILL.md` 的主题索引中登记；不要在两个文件里重复同一内容。
- **调整优先级**：修改 `SKILL.md` 的「强制规则」清单；`references/` 只提供细节与示例。
- **重新打包**：使用 skill 创建工具校验并打包，会检查 YAML frontmatter、命名规范与资源引用。
- **写作风格**：Skill 正文使用祈使 / 不定式（动词开头），面向 AI 消费，不使用第二人称。

---

## 版本与来源说明

| 项 | 值 |
| --- | --- |
| Skill 名称 | `go-engineering-excellence` |
| 适用 Agent | WorkBuddy · Claude Code · OpenAI Codex / ChatGPT · Cursor（v2.4+）· DeepSeek Harness |
| 作用域 | 用户级 / 项目级（见兼容性矩阵） |
| 语言 | 简体中文正文 + 英文术语 / 标识符 |
| 规范基线 | Google Go Style Guide、Uber Go Style Guide、Go 官方文档（地址见上） |
| 最后整理 | 2026-11-13 |

所有引用链接均为发布方官方地址。若上游规范更新，以官方页面为准，并同步更新本 Skill 的对应规则与映射表。
