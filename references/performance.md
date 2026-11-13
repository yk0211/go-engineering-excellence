# 性能（Performance）

源自 Uber Go Style Guide。**仅在已识别的热路径（hot path）上优化**；过早优化损害可读性与简单性。所有性能结论应以 benchmark（`go test -bench`）为依据，而非直觉。

## 1. strconv 优于 fmt（原始类型↔字符串）
热路径上 `strconv` 比 `fmt.Sprintf` 快且分配少。

```go
// Bad（热路径）
s := fmt.Sprintf("%d", n)
// Good
s := strconv.Itoa(n)
b, _ := strconv.ParseInt(s, 10, 64)
```

## 2. 容量预分配（make with capacity）
已知元素数量时，给 slice/map 指定容量，避免反复 realloc。

```go
// Bad
var out []T
for ... { out = append(out, x) }
// Good
out := make([]T, 0, n)
for ... { out = append(out, x) }

m := make(map[K]V, n)
```

## 3. 避免重复字符串转 []byte
固定字符串转 `[]byte` 每次都分配。热路径上转换一次并复用。

```go
const sep = "::"
buf := []byte(sep)  // 转换一次，复用
```

## 4. 指定结构体字段顺序减少内存对齐空洞
将小字段（bool/int8）聚合，减少 padding 浪费（仅在对大量实例性能敏感时）。

## 5. 避免不必要的分配与拷贝
- 大结构体按指针传递（receiver 与参数）。
- 用 `strings.Builder` / `bytes.Buffer` 拼接多段字符串，而非 `+` 循环。
- 避免在热循环里创建闭包捕获大变量（可能阻止逃逸分析优化）。

## 6. 同步原语开销
- `sync.Mutex` 临界区尽量小。
- 读多写少用 `sync.RWMutex`。
- 简单计数/标志用 `go.uber.org/atomic` 或 `sync/atomic`，避免锁。

## 7. 不要为性能牺牲清晰
当简单写法与"快写法"差距不显著时，选简单写法。用 benchmark + pprof 定位真正瓶颈，再针对性优化，并加注释说明为何偏离惯用法（信号增强 / signal boosting）。

```go
// 性能关键：此处用 unsafe 字符串→[]byte 零拷贝以削减低延迟路径分配。
// 仅因 benchmark 显示此处为瓶颈；改动需回归 -bench。
```
