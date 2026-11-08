#!/bin/bash
# Mirrors zsh prompt: underlined user@host, green cwd (~-abbreviated), git branch,
# then dim model name and context window usage (each omitted if absent).
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
short="${cwd/#$HOME/\~}"
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2> /dev/null \
    || git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2> /dev/null)
printf '\033[32m%s\033[0m' "$short"
[ -n "$branch" ] && printf ' (%s)' "$branch"
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
[ -n "$model" ] && printf ' \033[2m%s\033[0m' "$model"
[ -n "$used" ] && printf ' \033[2mctx %.0f%%\033[0m' "$used"
printf '\n'
