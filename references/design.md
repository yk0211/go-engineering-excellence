# 设计（Design & API）

源自 Google / Uber Go Style Guide。设计的核心是**小接口、消费者定义接口、组合优于继承、最小机制**。

## 1. 接口归属：消费者定义，生产者返回具体
"Accept interfaces, return concrete types." 接口应在**使用方**定义（窄、贴合需求），实现方返回具体类型——这样实现方不被宽泛接口束缚，也便于演进。

```go
// 消费者定义窄接口
type Reader interface { Read(p []byte) (int, error) }
func Consume(r Reader) { ... }

// 生产者返回具体类型
func NewStore() *Store { return &Store{} }
```

## 2. 接口要小、聚焦
多数接口 1–2 个方法。大接口难以实现、难以 mock、难以推理。仅在确有复用时抽象。

## 3. 编译期接口校验
在适当处用 `var _ I = (*T)(nil)` 验证类型实现接口，失败即编译报错。

```go
var _ http.Handler = (*Handler)(nil)
```

## 4. 不要接口指针
几乎不需要指向接口的指针。接口本身已含指针（type + data），按值传递即可，底层数据仍可是指针。

## 5. 接收者类型选择（Receiver Types）
- 任一方法用指针接收者，则**所有**方法都用指针接收者（一致性）。
- 需要修改接收者或结构体较大 → 指针接收者。
- 小型不可变值 → 值接收者。
- 值接收者的方法既能被值也能被指针调用；指针接收者只能被可寻址值/指针调用。

## 6. Option 模式（Functional Options）
当函数有较多可选参数（>4 个参数时应重构），使用 option structs 或 functional options，而非长参数列表或 bool 开关。

```go
type Option func(*Server)
func WithTimeout(d time.Duration) Option { return func(s *Server) { s.timeout = d } }
func NewServer(opts ...Option) *Server {
    s := &Server{timeout: defaultTimeout}
    for _, o := range opts { o(s) }
    return s
}
```
避免"裸 bool 参数"（如 `NewDB(true)`），语义不清，改用 options 或独立构造函数。

## 7. context.Context 约定
- 永远是函数**第一个参数**，命名 `ctx`。
- **不要**存入 struct（应沿调用链显式传递）。
- 仅在确实需取消/超时/传值时使用；纯计算函数若不需要可不引入。

## 8. 避免可变全局状态
用依赖注入（构造函数传入依赖）替代修改全局变量、全局函数指针。全局可变状态难以测试、易引发并发问题。

## 9. 组合优于继承
用结构体嵌入（embedding）组合行为，而非继承层级。但**公开结构体不要嵌入其他类型**（泄露实现细节、抑制演化）；用委托方法显式暴露所需行为。

## 10. 泛型：确需才用
Go 1.18+ 泛型用于真正通用的算法/容器。不要为单一具体类型提前抽象。仅在能消除实质性重复或提供类型安全时才引入。

## 11. main 的单一 exit 点（run 模式）
```go
func main() {
    if err := run(); err != nil {
        log.Fatalf("fatal: %v", err)  // 仅此处可 exit/fatal
    }
}
func run() error { /* 全部逻辑，返回 error */ }
```
使 `main` 可测试，且全局仅一处退出。
