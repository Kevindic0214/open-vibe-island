#!/bin/zsh

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
developer_dir="$(xcode-select -p 2>/dev/null || true)"
testing_frameworks="$developer_dir/Library/Developer/Frameworks"

if [[ -z "$developer_dir" || ! -d "$testing_frameworks/Testing.framework" ]]; then
    echo "Testing.framework was not found under the selected developer directory:" >&2
    echo "  ${testing_frameworks:-<unknown>}" >&2
    echo "Select Apple Command Line Tools or an Xcode installation that provides Swift Testing." >&2
    exit 1
fi

cd "$repo_root"

swift test \
    --enable-swift-testing \
    -Xswiftc -F \
    -Xswiftc "$testing_frameworks" \
    -Xlinker "-F$testing_frameworks" \
    -Xlinker -rpath \
    -Xlinker "$testing_frameworks" \
    -Xlinker -rpath \
    -Xlinker "$developer_dir/Library/Developer/usr/lib" \
    "$@"
