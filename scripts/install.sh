#!/bin/sh
# install.sh — 将本 Skill 安装到各 Agent 的技能目录
# 依据开放 Agent Skills 规范：SKILL.md + name/description frontmatter。
# POSIX sh 语法（dash / bash / zsh 通用），无 bash 专属特性。
#
# 用法：
#   sh scripts/install.sh all
#   sh scripts/install.sh claude-code cursor codex
#   MODE=link sh scripts/install.sh all
#   SCOPE=project sh scripts/install.sh claude-code cursor
#   FORCE=1 sh scripts/install.sh all
#
# 目标（agent key）：
#   workbuddy    ~/.workbuddy/skills/
#   claude-code  ~/.claude/skills/
#   shared       ~/.agents/skills/   # Codex / Cursor / DeepSeek Harness / Gemini CLI / opencode 均扫描
#   cursor       ~/.cursor/skills/  # 可选；Cursor 也读取 shared
#   codex        -> shared（别名）
#   dsh          -> shared（别名；建议配合 dsh-agent-skills 插件）
#   all          = workbuddy + claude-code + shared
#
# 环境变量：
#   MODE=copy|link   默认 copy（Windows / Git Bash 下 ln -s 常需额外权限）
#   SCOPE=user|project  默认 user
#   FORCE=1           目标已存在时覆盖文件；只覆盖，不删除目标目录

set -u

SKILL_NAME=go-engineering-excellence
SRC=$(cd "$(dirname "$0")/.." && pwd)
MODE=${MODE:-copy}
SCOPE=${SCOPE:-user}
FORCE=${FORCE:-}

if [ "$#" -eq 0 ]; then
    echo "用法: sh scripts/install.sh all | <agent>..."
    echo "  agent: workbuddy claude-code shared cursor codex dsh"
    echo "  env:   MODE=copy|link  SCOPE=user|project  FORCE=1"
    exit 2
fi

resolve_parent() {
    if [ "$SCOPE" = "project" ]; then
        base=$(pwd)
    else
        base="$HOME"
    fi
    case "$1" in
        workbuddy)   echo "$base/.workbuddy/skills" ;;
        claude-code) echo "$base/.claude/skills" ;;
        shared)      echo "$base/.agents/skills" ;;
        cursor)      echo "$base/.cursor/skills" ;;
        codex|dsh)   echo "$base/.agents/skills" ;;
        *)           return 1 ;;
    esac
}

install_one() {
    key=$1
    parent=$(resolve_parent "$key") || { echo "SKIP   未知目标: $key"; return 1; }
    dst="$parent/$SKILL_NAME"

    # link 模式：仅在目标不存在时创建符号链接，绝不删除已有内容
    if [ "$MODE" = "link" ]; then
        if [ -e "$dst" ] || [ -L "$dst" ]; then
            echo "SKIP   link 模式下目标已存在: $dst"
            return 0
        fi
        mkdir -p "$parent" || { echo "FAIL   无法创建 $parent"; return 1; }
        if ln -s "$SRC" "$dst" 2>/dev/null; then
            echo "LINK   $dst -> $SRC"
            return 0
        fi
        echo "WARN   符号链接不可用，回退为复制: $dst"
        MODE=copy
    fi

    if { [ -e "$dst" ] || [ -L "$dst" ]; } && [ -z "$FORCE" ]; then
        echo "SKIP   已存在: $dst  (FORCE=1 可覆盖)"
        return 0
    fi

    mkdir -p "$dst" || { echo "FAIL   无法创建 $dst"; return 1; }
    if cp -R "$SRC/." "$dst/" 2>/dev/null; then
        echo "COPY   $dst"
        return 0
    fi
    echo "FAIL   复制失败: $dst"
    return 1
}

echo "源目录: $SRC"
echo "参数  : MODE=$MODE SCOPE=$SCOPE FORCE=${FORCE:-0}"
echo ""

# 展开 all；目标名均为固定 identifier，可安全按空格分词
targets=""
for a in "$@"; do
    case "$a" in
        all) targets="$targets workbuddy claude-code shared" ;;
        *)   targets="$targets $a" ;;
    esac
done

fail=0
for t in $targets; do
    install_one "$t" || fail=1
done

echo ""
echo "提示: Codex / Cursor / DeepSeek Harness 都扫描 ~/.agents/skills/，"
echo "      'shared' 一次安装即覆盖三家；Claude Code 需单独 ~/.claude/skills/。"
echo "      DeepSeek Harness 建议用 dsh-agent-skills 插件在设置页接管。"
exit "$fail"
