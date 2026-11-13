# 格式化（Formatting）

源自 Google Go Style Guide。Go 的格式化几乎全自动，**没有讨论格式的余地**——工具说了算。

## 1. 必须 gofmt / goimports
所有代码必须 `gofmt` 兼容（`gofmt -l` 应为空）。推荐 `goimports`（自动管理 import 分组）。

```bash
gofmt -l .
goimports -l .
```

## 2. Import 分组与排序
两组：标准库在前，第三方/其他在后，中间空一行。同组内按字母排序。`goimports` 自动处理。

```go
import (
    "fmt"
    "os"

    "github.com/uber-go/atomic"
    "google.golang.org/grpc"
)
```

- 导入重命名仅在包名与路径末段不符或有冲突时进行；proto 包建议 `pb` 后缀（`foopb "path/to/foo_go_proto"`）。
- 跨多文件重命名同一导入时，尽量保持一致本地名。

## 3. 结构体字面量带字段名
初始化结构体使用字段名（`MyStruct{Field: value}`），除测试表中 ≤3 字段且含义自明时可省略。

```go
// Good
u := User{Name: "a", Age: 3}
// 测试表中可简写
tests := []struct{ in, want string }{ {"a", "b"} }
```

## 4. nil slice 语义
`var s []T` 与 `s := []T{}` 不同：前者为 `nil`，后者为非 nil 空切片。**返回"无结果"时用 `nil`**，用 `len(s) == 0` 判断空。两者都能 `range` 且 `append` 安全。

```go
// Good: 未找到返回 nil
func Find(...) []Item { return nil }
// 判断空
if len(items) == 0 { ... }
```

## 5. 减少嵌套（Reduce Nesting）
错误/特殊情况先处理并提前返回（early return），保持"成功路径"靠左（happy path 左对齐）。消除不必要的 `else`：用默认值 + 条件覆盖替代 if/else 两边都赋值。

```go
// Bad（深层嵌套）
if err == nil {
    if v, err := f(); err == nil {
        ...
    } else { ... }
} else { ... }

// Good（提前返回）
if err != nil { return err }
v, err := f()
if err != nil { return err }
...
```

## 6. 局部变量声明
有显式非零值用 `:=`；零值初始化用 `var x T`；需要指针用 `new(T)`。

## 7. 复杂条件提取
把复杂布尔条件提取为具名变量或函数，提升可读性，避免 Yoda 写法、冗余 `break`。

## 8. 软性行长度
无硬上限（Google 不强制），但过长行应**重构**而非硬拆。Uber 建议软上限 99 字符，避免横向滚动。不要在缩进变化前或长字符串/URL 中间强行拆行。
