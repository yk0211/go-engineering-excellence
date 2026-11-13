# 并发（Concurrency）

源自 Uber Go Style Guide 与 Go 官方并发指南。**Go 的并发错误是生产事故的主要来源**，务必遵循最小机制与显式生命周期。

## 1. 绝不"发射后不管"（Fire-and-Forget）
每个 goroutine 必须有可预期的停止方式或被等待。调用方必须能等待其结束。

```go
// Bad: goroutine 泄漏，无法停止或等待
go process(item)

// Good: 用 WaitGroup 等待多个
var wg sync.WaitGroup
for _, item := range items {
    wg.Add(1)
    go func(it Item) {
        defer wg.Done()
        process(it)
    }(item)
}
wg.Wait()

// Good: 单个后台任务用 done channel 信令停止
func (w *Worker) Start() {
    w.done = make(chan struct{})
    go w.run()
}
func (w *Worker) Stop() { close(w.done) }
func (w *Worker) run() {
    for {
        select {
        case <-w.done:
            return
        case job := <-w.jobs:
            w.handle(job)
        }
    }
}
```

## 2. 禁止在 init() 中启动 goroutine
`init()` 必须确定性、无 I/O、不操纵全局/环境变量、不依赖执行顺序。后台任务通过带显式 `Start()/Stop()`（或 `Shutdown()`/`Close()`）生命周期方法的对象管理。

## 3. channel 容量：0 或 1
- 默认 unbuffered（容量 0）。
- 容量 1 用于"latest value"或解耦生产/消费节奏。
- 其他尺寸（如 worker 池缓冲）需极强理由与审查，容易造成延迟与内存堆积。

```go
ch := make(chan int)        // 无缓冲，同步
ch := make(chan int, 1)     // 容量 1
```

## 4. 零值 Mutex 有效，且不要嵌入
`sync.Mutex` / `sync.RWMutex` 零值即有效，不要用 `new(sync.Mutex)`。结构体内用命名字段；**对外导出类型用私有锁字段，不要嵌入 mutex**（嵌入会泄露实现细节、抑制类型演化）。

```go
// Bad
mu := new(sync.Mutex)
type SMap struct {
    sync.Mutex          // 嵌入，导出类型尤忌
    data map[string]string
}

// Good
type SMap struct {
    mu   sync.Mutex     // 私有命名字段
    data map[string]string
}
```

## 5. 类型安全原子操作
优先用 `go.uber.org/atomic`（`atomic.Bool`、`atomic.Int64` 等）替代裸 `sync/atomic`，类型更安全、防误用。

```go
// Bad
var started int32
atomic.StoreInt32(&started, 1)

// Good
var started atomic.Bool
started.Store(true)
```

## 6. 同步函数优先，调用方再加并发
默认写同步（阻塞）函数；让调用方决定是否需要并发。这样更易测试与推理。

## 7. channel 方向标注
在签名中标注 channel 方向（`<-chan` / `chan<-`），既文档化又防误用。

```go
func Consumer(in <-chan int) { ... }
func Producer(out chan<- int) { ... }
```

## 8. time 包与单位
- 时刻用 `time.Time`，时段用 `time.Duration`。
- 当 `time.Duration` 无法直接表达时，字段名带单位：`IntervalMillis int64`。
- 时间戳字符串用 RFC 3339。
- 日历天用 `AddDate`，绝对 24 小时用 `Add`。

## 9. 测试并发用 -race
所有涉及并发的代码必须通过 `go test -race`（见 scripts/go-check.sh）。在 goroutine 内不要用 `t.Fatal`（会退出测试 goroutine 而非主测试），改用 `t.Error`。
