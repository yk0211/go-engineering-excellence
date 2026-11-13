# 命名规范（Naming）

源自 Google Go Style Guide 与 Uber Go Style Guide，按优先级排列。

## 1. 避免冗余命名（Redundant Naming）
符号名不要重复包名、接收者、参数类型或返回值类型信息。

```go
// Bad: 重复包名
user.UserCount        // 包已叫 user
user.Type             // 用 user.Kind 或具体类型名

// Good
user.Count
user.Role
```

## 2. MixedCaps，禁止 snake_case
导出用 `MixedCaps`，未导出用 `mixedCaps`。Go 标识符（包名、变量、函数、常量）一般不使用下划线。

```go
// Bad
user_count  userCount_2  User_Count

// Good
userCount
```

**例外**（允许下划线）：
- 仅由生成代码导入的包名（如 `foo_go_proto`）。
- `*_test.go` 中的 Test/Benchmark/Example 函数名（如 `TestParse_URL`）。
- 与操作系统/cgo 互操作的底层库（如 `syscall`）。
- 源文件名本身不是标识符，可含下划线。

## 3. 缩写大小写一致
常见缩写保持统一大小写：`URL`/`url`、`ID`/`id`、`HTTP`/`http`、`JSON`/`json`、`API`/`api`。**绝不**写成 `Url`、`Id`、`Http`。

```go
// Bad
func ServeUrl(u Url) {}
type UserId int

// Good
func ServeURL(u URL) {}
type UserID int
```

## 4. 包名（Package Names）
- 短、全小写、无下划线；多词包名保持连续小写（`tabwriter` 而非 `tabWriter`/`TabWriter`）。
- 避免会被常用局部变量遮蔽的名字：`count` 不如 `usercount`。
- 避免无意义包名：`util`、`utility`、`common`、`helper`、`model`、`models`、`testhelper`、`shared`、`lib`。这类名字会诱使导入者重命名。若必须聚合通用代码，按职责拆成具体包。

## 5. 接收者命名（Receiver Names）
短（1–2 字母），是类型名的缩写，对同一类型的所有方法保持一致，不用 `this`/`self`。

```go
// Bad                  Good
func (tray Tray)        func (t Tray)
func (this *Report)     func (r *Report)
func (self *Scanner)    func (s *Scanner)
```

## 6. 常量命名
使用 MixedCaps（同其他 Go 名称），即使打破其他语言惯例。按**角色**而非值命名。

```go
// Bad: 由值派生
const MAX = 512

// Good: 说明含义
const MaxPacketSize = 512
const ExecuteBit = 1 << 0
```

## 7. 无 Get 前缀（Accessor Naming）
Go 访问器不用 `Get` 前缀；名词表获取、动词表动作。

```go
// Bad          Good
user.GetName()  user.Name()
user.Get(1)     user.Get(1)   // 动词可保留
```

## 8. 变量名长度与生命周期成正比
- 短生命周期/局部：简洁（`i`、`r`、`err`、`b`）。
- 长生命周期/大作用域：更具描述性。
- 零值初始化用 `var x T`（而非 `x := T{}` 当意在表达零值）。

## 9. 函数命名
返回值的函数用名词，执行动作的函数用动词。

```go
// 动词
func (u *User) Save() error
// 名词（返回新对象）
func NewUser(name string) *User
```

## 10. 函数/变量名去除类型信息
不要在变量名里重复类型。

```go
// Bad          Good
var userMap map[string]*User   var users map[string]*User
```
