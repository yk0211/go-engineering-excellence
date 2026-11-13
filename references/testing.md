# 测试（Testing）

源自 Google / Uber Go Style Guide 与 Go 官方测试建议。**测试是安全网，先于重构存在**。

## 1. Table-Driven Tests（首选）
用结构体切片表达用例，字段具名、带描述，避免重复。

```go
func TestParse(t *testing.T) {
    tests := []struct {
        name string
        in   string
        want int
        wantErr error
    }{
        {name: "empty", in: "", want: 0},
        {name: "one", in: "1", want: 1},
        {name: "bad", in: "x", wantErr: ErrInvalid},
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := Parse(tt.in)
            if tt.wantErr != nil {
                if !errors.Is(err, tt.wantErr) {
                    t.Fatalf("Parse(%q) err = %v, want %v", tt.in, err, tt.wantErr)
                }
                return
            }
            if err != nil { t.Fatalf("unexpected err: %v", err) }
            if got != tt.want {
                t.Errorf("Parse(%q) = %v, want %v", tt.in, got, tt.want)
            }
        })
    }
}
```

## 2. 不使用断言库
只用标准 `testing` 包（`if got != want { t.Errorf(...) }`）。避免 testify 等断言库——保持惯用、可读、无额外依赖。报告格式建议：`Func(%v) = %v, want %v`。

## 3. 测试辅助函数用 t.Helper()
辅助函数内调用 `t.Helper()`，使失败行号指向调用处而非辅助函数内部。

```go
func mustLoad(t *testing.T, path string) *Config {
    t.Helper()
    c, err := Load(path)
    if err != nil { t.Fatalf("load %s: %v", path, err) }
    return c
}
```

## 4. 错误匹配用 errors.Is / errors.As
不要用字符串比较错误（见 errors.md）。测试应对错误文案变化鲁棒。

## 5. Goroutine 内勿用 t.Fatal
`t.Fatal` 调用 `runtime.Goexit`，在子 goroutine 中只会终止该 goroutine 而非主测试，导致主测试"假绿"。在 goroutine 内用 `t.Error` 并把结果传回主 goroutine 判定。

```go
// Bad（在 goroutine 内）
go func() { t.Fatal("boom") }()

// Good
done := make(chan error, 1)
go func() { done <- doWork() }()
if err := <-done; err != nil { t.Errorf("doWork: %v", err) }
```

## 6. 作用域化 Setup
每个测试显式 setup；避免包级 `init()` 做 I/O 或共享可变状态。测试间应相互独立。

## 7. 可运行的 Example
导出包的文档示例（`ExampleXxx`）既出现在 godoc，又作为测试运行，是双保险。

## 8. 测试覆盖率与 -race
关键路径需覆盖；涉及并发必跑 `go test -race`（见 scripts/go-check.sh）。

## 9. 标志（flags）覆盖
测试中直接覆盖绑定 flag 的变量值，不要用 `flag.Set`（易影响其他测试、顺序依赖）。
