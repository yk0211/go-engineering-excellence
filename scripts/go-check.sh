#!/bin/sh
# go-check.sh — Go 格式与质量检查脚本
# 依次运行：gofmt / goimports、go vet、staticcheck、go test -race
# 兼容 POSIX sh（dash / bash / zsh 均可），无 bash 专属语法。
#
# 用法：
#   sh scripts/go-check.sh            # 在当前模块根（自动向上查找 go.mod）运行
#   GO_CHECK_ROOT=/path sh scripts/go-check.sh
#
# 退出码：0 = 全部通过；1 = 存在失败项。

set -u

# 切到模块根：优先用 GO_CHECK_ROOT，否则向上查找 go.mod
cd_root() {
    if [ -n "${GO_CHECK_ROOT:-}" ]; then
        cd "$GO_CHECK_ROOT" || exit 1
        return 0
    fi
    dir=$(pwd)
    while [ "$dir" != "/" ]; do
        if [ -f "$dir/go.mod" ]; then
            cd "$dir" || exit 1
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 0
}

cd_root

echo "==> Go version"
go version

# 1. gofmt：所有文件必须已格式化
echo "==> gofmt -l (期望为空)"
unformatted=$(gofmt -l . 2>/dev/null)
if [ -n "$unformatted" ]; then
    echo "FAIL: 以下文件未通过 gofmt:"
    echo "$unformatted"
    FMT_FAIL=1
else
    echo "OK"
fi

# 2. goimports（可选）：自动整理 import 分组
if command -v goimports >/dev/null 2>&1; then
    echo "==> goimports -l (期望为空)"
    unimp=$(goimports -l . 2>/dev/null)
    if [ -n "$unimp" ]; then
        echo "WARN: 以下文件 import 需整理（建议运行 goimports -w）:"
        echo "$unimp"
    else
        echo "OK"
    fi
else
    echo "==> goimports 未安装（可选，跳过）。安装: go install golang.org/x/tools/cmd/goimports@latest"
fi

# 3. go vet：捕获常见错误（含 copylocks / shadow 提示）
echo "==> go vet ./..."
if go vet ./... 2>&1; then
    echo "OK"
else
    echo "FAIL: go vet 发现问题"
    VET_FAIL=1
fi

# 4. staticcheck（可选）：更严格的静态分析
if command -v staticcheck >/dev/null 2>&1; then
    echo "==> staticcheck ./..."
    if staticcheck ./... 2>&1; then
        echo "OK"
    else
        echo "FAIL: staticcheck 发现问题"
        SC_FAIL=1
    fi
else
    echo "==> staticcheck 未安装（可选，跳过）。安装: go install honnef.co/go/tools/cmd/staticcheck@latest"
fi

# 5. go test -race：正确性 + 并发安全
echo "==> go test -race ./..."
if go test -race ./... 2>&1; then
    echo "OK"
else
    echo "FAIL: 测试失败或检测到数据竞争"
    TEST_FAIL=1
fi

# 汇总
echo ""
echo "==== 汇总 ===="
if [ -n "${FMT_FAIL:-}" ] || [ -n "${VET_FAIL:-}" ] || [ -n "${SC_FAIL:-}" ] || [ -n "${TEST_FAIL:-}" ]; then
    echo "结果: FAIL"
    [ -n "${FMT_FAIL:-}" ] && echo " - gofmt 未通过"
    [ -n "${VET_FAIL:-}" ] && echo " - go vet 未通过"
    [ -n "${SC_FAIL:-}" ] && echo " - staticcheck 未通过"
    [ -n "${TEST_FAIL:-}" ] && echo " - 测试/race 未通过"
    exit 1
else
    echo "结果: PASS"
fi
