# 错误处理（Error Handling）

源自 Google / Uber Go Style Guide 与 Go 官方建议。错误是 Go 的一等公民，**显式、单次、带上下文**地处理。

## 1. 显式处理，绝不静默丢弃
禁止用 `_ =` 或裸 `_` 丢弃 error。库代码不 panic，生产代码避免 panic。

```go
// Bad
_ = json.Unmarshal(b, &v)
f, _ := os.Open(path)

// Good
if err := json.Unmarshal(b, &v); err != nil {
    return fmt.Errorf("decode config: %w", err)
}
```

`panic` 仅用于：真正不可恢复的状态（如 nil 解引用）、程序初始化（如模板必须编译 `template.Must`）。`os.Exit`/`log.Fatal` 只应在 `main()` 调用（推荐用单一 `run() error` 模式，见 design.md）。

## 2. 错误只处理一次（Handle Errors Once）
要么 wrap 后返回，要么记录并降级。**不要**既 log 又 return 同一个 error——会造成重复日志与信息丢失。

```go
// Bad: 既记录又返回
if err != nil {
    log.Errorf("read: %v", err)
    return err
}

// Good: 仅包装返回（由最上层统一记录）
if err != nil {
    return fmt.Errorf("read %s: %w", path, err)
}
```

若确需降级（无法向上传播），则只 log 并继续，不要 return。

## 3. 错误包装：%w 与 %v
- `%w`：调用方需要 `errors.Is`/`errors.As` 匹配时使用。
- `%v`：需要向调用方隐藏内部细节（opaque）时使用。
- 位置约定：上下文在前，原错误在后（`"context: %w"`）。
- 避免 `"failed to"` 前缀；首字母小写、结尾无标点。

```go
// Bad
return fmt.Errorf("Failed to open config file.")   // 大写+标点+failed to
return fmt.Errorf("open config: %s", err)          // %s 无法 Is/As

// Good
return fmt.Errorf("open config %s: %w", path, err)
return fmt.Errorf("open config %s: %v", path, err) // 隐藏内部
```

## 4. 哨兵错误与错误类型
- 导出哨兵错误用 `Err` 前缀：`var ErrNotFound = errors.New("not found")`，供 `errors.Is` 匹配。
- 未导出错误变量用 `err` 前缀：`var errNotFound = errors.New(...)`.
- 需要携带结构化信息时，自定义错误类型，名称用 `Error` 后缀，并实现 `Error() string`；供 `errors.As` 提取。

```go
var ErrNotFound = errors.New("not found")

// 自定义错误类型
type ValidationError struct {
    Field string
    Msg   string
}
func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Msg)
}

// 调用方
if errors.Is(err, ErrNotFound) { ... }
var ve *ValidationError
if errors.As(err, &ve) { ... }
```

## 5. 类型断言一律 comma-ok
```go
// Bad
s := i.(string)   // panic 风险

// Good
s, ok := i.(string)
if !ok { return fmt.Errorf("expected string, got %T", i) }
```

## 6. 错误字符串风格
错误字符串（传给 `errors.New`/`fmt.Errorf` 的**消息部分**）不大写、不以标点结尾。注意：`%w` 包裹的底层错误可能自带大写，这是允许的。

## 7. 不要使用 In-Band 错误
不要用特殊返回值（如 `-1`、`nil` 表错误）表达错误，应使用多返回值 `(value, error)`。

## 8. 测试中匹配错误用 errors.Is
不要用字符串比较错误；用 `errors.Is` / `errors.As`，使测试对错误文案变化鲁棒。

```go
if !errors.Is(err, ErrNotFound) {
    t.Fatalf("got %v, want ErrNotFound", err)
}
```
