#!/bin/bash
# 🐺 ERLİK Clean Disk & Cache Fast Engine
# Optimized for immediate execution, high speed, and non-blocking safety.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

MODE="${1:-safe}"

echo "🧹 [ERLİK Clean] Running cleanup (Mode: $MODE)..."

# 1. Package Managers & Temp Runtimes
npm cache clean --force 2>/dev/null || true
pnpm store prune 2>/dev/null || true
bun pm cache rm 2>/dev/null || true

rm -rf ~/.cache/yarn ~/.cache/uv ~/.cache/codex-runtimes ~/.cache/mongodb-binaries 2>/dev/null || true
rm -rf ~/.npm/_npx 2>/dev/null || true
rm -rf ~/Library/Caches/dotslash ~/Library/Caches/node-gyp ~/Library/Caches/JetBrains/Toolbox 2>/dev/null || true

# 2. Developer & Mobile Build Caches
if [ "$MODE" = "all" ] || [ "$MODE" = "dev" ]; then
    echo "📱 [ERLİK Clean] Cleaning iOS/Android build caches & Xcode DerivedData..."
    rm -rf ~/Library/Developer/Xcode/DerivedData/* 2>/dev/null || true
    rm -rf ~/Library/Developer/Xcode/iOS\ DeviceSupport/* ~/Library/Developer/Xcode/DocumentationCache 2>/dev/null || true
    rm -rf ~/Library/Caches/com.apple.dt.Xcode ~/Library/Caches/org.swift.swiftpm 2>/dev/null || true
    rm -rf ~/Library/Caches/CocoaPods ~/.cocoapods/cache ~/Library/Caches/carthage 2>/dev/null || true
    rm -rf ~/.gradle/caches ~/.android/cache ~/.android/build-cache 2>/dev/null || true
fi

# 3. AI Agent Replays & Temporary Sessions
if [ "$MODE" = "all" ] || [ "$MODE" = "ai" ]; then
    echo "🤖 [ERLİK Clean] Cleaning AI Agent replays & temporary browser sessions..."
    rm -rf ~/.codex/.tmp ~/.codex/tmp* ~/.codex/computer-use 2>/dev/null || true
    rm -rf ~/.browserclaw/replays ~/.browserclaw/screenshots 2>/dev/null || true
    rm -rf ~/.openclaw/tmp 2>/dev/null || true
    rm -rf ~/.lmstudio/server-logs ~/.lmstudio/.internal/temp-downloads 2>/dev/null || true
fi

# 4. Downloads installer cleanup
rm -f ~/Downloads/*.dmg ~/Downloads/*.pkg 2>/dev/null || true

echo "✅ [ERLİK Clean] Disk and cache cleanup finished successfully!"
