# 安全与防御性编程（Safety & Defensive Programming）

本文件是 **go-safety** 的重点：编写在异常输入、并发、资源压力下仍正确、不崩溃、不泄漏的代码。综合 Google / Uber 指南与 Go 官方安全实践。

## 1. nil 安全
- 返回"无"用 `nil`（slice/map/指针/error），调用方用 `len(x) == 0` / `== nil` 判定。
- 解引用指针、调用方法前确认非 nil。nil interface 与 nil 具体类型易踩坑：

```go
// 陷阱：含 nil 具体值的接口 != nil 接口
func f() error { var p *MyErr; return p } // 返回的 error 接口 != nil，但底层是 nil *MyErr
if err != nil { /* 会进入这里，尽管逻辑上"无错误" */ }
```
**规则**：不要返回具体类型的 nil 指针当作"无错误"；显式 `return nil`。

- `json.Unmarshal` 到 nil slice/map 会分配；预分配容量见 performance.md。
- `defer` 中若可能 panic（如 nil receiver 调用方法），确保 receiver 已初始化。

## 2. Race 安全（数据竞争）
- 所有共享可变状态用 mutex / atomic / channel 保护。**不要**依赖"反正只有我读"的假设——并发下必翻车。
- 测试必跑 `go test -race`（见 scripts/go-check.sh）。
- struct 含 `sync.Mutex` 等不可复制类型时，禁止值复制（用 `go vet` 的 copylocks 检查）。用指针传递此类结构体。

```go
// Bad: 复制带锁的 struct
var a SMap; b := a   // copylocks 告警
// Good: 用指针
a := NewSMap(); useA(a)
```

## 3. 资源清理（Resource Cleanup）
文件、连接、锁、goroutine 必须确定性释放，首选 `defer`。

```go
f, err := os.Open(path)
if err != nil { return err }
defer f.Close()   // 即使后续出错也释放
```

- `defer` 开销极小，不要为微优化而省略。
- 锁用 `defer mu.Unlock()`（在 `Lock()` 成功后）。
- 注意 `defer` 在循环/大函数中的累积：长循环内应显式关闭而非 defer 到函数尾。

## 4. 边界拷贝（Copy at Boundaries）
slice/map 含指向底层数据的指针。若存储调用方传入的 slice/map，或返回暴露内部状态的 slice/map，需拷贝以防调用方意外篡改（或内部被外部改动）。

```go
// 接收并存储：拷贝
func (d *Driver) SetTrips(trips []Trip) {
    d.trips = make([]Trip, len(trips))
    copy(d.trips, trips)
}
// 返回内部状态：拷贝
func (d *Driver) Trips() []Trip {
    out := make([]Trip, len(d.trips))
    copy(out, d.trips)
    return out
}
```

## 5. 初始化陷阱（init() 风险）
- `init()` 必须确定性、无 I/O、不操纵全局/环境变量、不依赖执行顺序、不启动 goroutine。
- 需要默认值时用显式初始化函数或 `var x = compute()`（纯计算）替代有副作用的 `init()`。
- 避免在 `init()` 中 `os.Exit` 或 `log.Fatal`（难以测试、难以捕获）。

## 6. 预声明标识符遮蔽（Shadowing）
不要用 Go 预声明标识符作变量名：`error`、`string`、`bool`、`len`、`cap`、`make`、`new`、`copy`、`append`、`real`、`imag`、`complex`、`int`、`float64` 等。`go vet` 的 shadow 检查应保持干净。

```go
// Bad
func f(error string) { ... }   // 遮蔽内建 error 类型
// Good
func f(msg string) { ... }
```

## 7. 类型断言与类型开关安全
见 errors.md 的 comma-ok。类型开关优于链式断言：

```go
switch v := i.(type) {
case string: handleStr(v)
case int:    handleInt(v)
default:     return fmt.Errorf("unsupported type %T", i)
}
```

## 8. 不要 panic 跨 API 边界
库函数 panic 会炸掉调用方程序且无法 recover 干净。库内一律返回 error；仅在 main/初始化阶段不可恢复时 panic。

## 9. 整数与溢出
Go 无隐式溢出检查。涉及计数、索引、尺寸计算时注意 uint 与 int 混用、`len` 转 int 在 32 位平台的上限、向下溢出（uint 减到负数变极大值）。

## 10. 外部输入校验
任何来自网络/文件/用户的输入都不可信：长度上限、字段范围、UTF-8 有效性、路径穿越（`filepath.Clean` + 前缀校验）、SQL/命令注入（用参数化查询、不拼 shell）。

## 11. 确定性输出
涉及 map 迭代、随机、时间的逻辑，测试或安全相关场景需确定性（map 遍历随机化是 Go 特性，不要依赖顺序）。
