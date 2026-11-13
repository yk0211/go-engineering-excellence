---
name: go-engineering-excellence
description: Go 工程卓越规范。当用户编写、审查、重构 Go 代码，或进行 Go 代码评审、API 设计、并发/错误处理/测试/格式化时触发。综合 Google Go Style Guide、Uber Go Style Guide 及 Go 官方规范（Effective Go、Go Code Review Comments）的业界最佳实践。Triggers on Go naming, error handling, interface design, concurrency, testing, formatting, package layout, and code review.
agent_created: true
---

# Go 工程卓越规范（Go Engineering Excellence）

## 概述

本技能综合 **Google Go Style Guide**（Go 的诞生地，最权威规范）、**Uber Go Style Guide**（社区事实标准）以及 **Go 官方规范**（Effective Go、Go Code Review Comments）的业界最佳实践，用于在编写、审查、重构 Go 代码时产出清晰、简单、安全、可维护的惯用代码。

> **关于 Meta 的说明（如实）**：Meta（Facebook）并未公开发布 Go 专属风格指南——Go 并非其主力语言。因此本规范以 Google 与 Uber 为核心来源，并补充 Go 团队的官方建议。Meta 的工程理念（强代码所有权、简洁性、严格的代码评审文化、stable infrastructure 上快速迭代）已融入本规范的"可维护性"与"评审流程"章节。

核心目标：**可读性优先、显式错误处理、安全的并发、可演进的 API**。

## 核心哲学（按优先级）

来自 Google Go Style Guide 的五大可读性原则，按重要性排序：

1. **清晰（Clarity）**：代码的目的与理由对读者必须清晰。易读比易写更重要。注释应解释"为什么"而非"是什么"。
2. **简单（Simplicity）**：用最简单的方式达成目标。避免不必要的抽象层级、不必要的机制。
3. **简洁（Concision）**：高信噪比，使用常见惯用法，避免重复代码。
4. **可维护性（Maintainability）**：易于后续修改，API 优雅演进，最小化依赖，测试完备。
5. **一致性（Consistency）**：与项目/包/文件中的类似代码保持一致。代码中"特立独行"通常是为了性能，需有意为之并加注释。

**支撑原则 —— 最小机制（Least Mechanism）**：优先使用核心语言构造（slice、map、channel、`for range`、`sync`），而非精巧的机器或外部库。只有当标准构造确实不够时才引入抽象。

## 何时使用

- 编写新的 Go 包、函数、方法或 API
- 审查（review）/评审 Go 代码
- 重构现有 Go 代码
- 设计 Go 接口、Option 模式、错误类型
- 编写或改进 Go 测试（含 table-driven test）
- Go 并发、性能、格式化、包布局相关任务

触发词示例：Go 命名规范、错误包装、`errors.Is`、interface 设计、goroutine 生命周期、`gofmt`、`go vet`、table-driven test、代码评审、race 检测。

## 强制规则（正确性与安全性，不可违反）

以下是正确性与安全的底线。完整清单与反例见 `references/safety.md` 与 `references/errors.md`。

1. **显式处理每一个错误**：绝不用 `_` 静默丢弃 `error`。库代码中禁止 `panic`；生产代码避免 `panic`——`panic` 仅用于真正不可恢复的状态或程序初始化。除 `main()` 外所有函数一律返回 `error`。
2. **错误只处理一次**：要么 `wrap` 后返回，要么记录并降级，**不要**既 `log` 又 `return` 同一个 error（避免重复日志与信息丢失）。
3. **错误包装**：用 `fmt.Errorf("context: %w", err)`（`%w` 供 `errors.Is/As` 匹配；`%v` 用于隐藏内部细节）。错误字符串不大写、不以标点结尾，避免 `"failed to"` 前缀（用 `"open config: %w"` 而非 `"failed to open config: %w"`）。
4. **哨兵错误与错误类型**：导出哨兵错误用 `Err` 前缀（`var ErrNotFound = errors.New("...")`）供调用方 `errors.Is` 匹配；自定义错误类型用 `Error` 后缀。
5. **类型断言一律用 comma-ok**：`v, ok := i.(T)`，禁止裸断言。
6. **绝不"发射后不管"的 goroutine**：每个 goroutine 必须有可预期的停止方式或被等待（`sync.WaitGroup` 或多个 goroutine、`done chan struct{}` 关闭信令单个）。禁止在 `init()` 中启动 goroutine。
7. **channel 容量为 0 或 1**：其他尺寸需极强理由与审查。
8. **零值有效**：`sync.Mutex` / `sync.RWMutex` 零值即可用，不要用 `new(sync.Mutex)`；结构体内用命名字段 `mu sync.Mutex`（对外导出类型用私有锁字段，**不要嵌入**mutex）。
9. **边界拷贝**：接收并存储的 slice/map 要拷贝；返回暴露内部状态的 slice/map 前要拷贝，防止调用方意外篡改。
10. **接口值传递**：几乎不需要接口指针；接口由**使用者**定义（accept interfaces, return concrete types）。
11. **`context.Context` 永远是函数第一个参数**，且**不要**存入 struct。
12. **禁止可变全局状态**：用依赖注入替代修改全局变量（含函数指针）。
13. **不要遮蔽预声明标识符**（`error`、`string`、`len`、`make`、`new` 等），`go vet` 必须干净。

## 工作流程

### 编写新 Go 代码

1. 确定包名：短、全小写、无下划线，避免 `util`/`common`/`helper`/`model`/`shared`/`lib`（见 `references/naming.md`）。
2. 定义函数签名与期望行为，先写 table-driven 测试（见 `references/testing.md`）。
3. 实现最小可用代码使测试通过（Red-Green）。
4. 重构保持测试绿：提升可读性、性能，并遵循本规范。
5. 运行 `scripts/go-check.sh`（gofmt/goimports、`go vet`、staticcheck、`go test -race`）确认无问题。

### 代码评审（Review）

按以下清单逐项检查：

- **错误处理**：错误是否被显式、单次处理？是否有裸 `panic`、被忽略的错误（`_ = ...`）？
- **并发安全**：mutex 使用是否恰当？`context` 是否正确传播？goroutine 生命周期是否可控？是否有 race 风险？
- **资源清理**：文件、锁、连接是否通过 `defer` 释放？
- **接口设计**：是否小而聚焦？是否有编译期 `var _ I = (*T)(nil)` 校验？是否"接受接口、返回具体"？
- **命名与包布局**：是否符合 `references/naming.md`？是否存在"工具包"异味？
- **文档注释**：每个导出符号是否有以符号名开头的完整句 doc comment？

**结构限制（Uber 风格建议）**：函数 ≤50 行、struct ≤200 行、参数 ≤4（超过时用 functional options 模式）。

### 重构

1. 先确保有测试；无测试则先补（测试是安全网）。
2. 一次一个改动，保持测试通过。
3. 识别并消除反模式：>50 行函数、>4 参数（改用 options）、被忽略的错误、缺 `defer` 清理、不当的接口设计、可变全局状态。

## 主题参考（详细规则与正反例）

- `references/naming.md` — 命名（MixedCaps、包名、接收者、常量、缩写大小写、无 Get 前缀、变量名长度）
- `references/errors.md` — 错误处理（哨兵、%v/%w、单次处理、comma-ok、错误字符串风格）
- `references/concurrency.md` — 并发（channel 容量、goroutine 生命周期、零值 mutex、atomic、`time` 使用）
- `references/design.md` — 设计（接口归属、Option 模式、接收者类型选择、泛型、context、依赖注入、组合优于继承）
- `references/testing.md` — 测试（table-driven、不使用断言库、`t.Helper`、用 `errors.Is` 而非字符串匹配、`t.Fatal` 不跨 goroutine）
- `references/formatting.md` — 格式化（gofmt、import 分组与排序、结构体字面量带字段名、nil slice 语义、减少嵌套）
- `references/safety.md` — **安全与防御性编程（go-safety 重点）**：nil 安全、race 安全、资源清理、边界拷贝、初始化陷阱、`init()` 风险、预声明标识符遮蔽
- `references/performance.md` — 性能（仅热路径优化：strconv 优于 fmt、容量预分配、避免重复字符串转 `[]byte`）

## 资源

- `scripts/go-check.sh`：一键运行 `gofmt -l` / `goimports -l`、`go vet`、`staticcheck`、`go test -race` 的格式与质量检查脚本，输出结构化报告。
