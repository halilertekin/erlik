#!/bin/bash
# Clean-Mac-Cache Advanced Modular Script
# Usage:
#   clean-mac-cache.sh [all|safe|dev|ai|docker]
#   DRY=1 clean-mac-cache.sh dev   # dry-run: hicbir sey silmez, sadece listeler

MODE="${1:-safe}"
DRY="${DRY:-0}"

ts() { date "+%H:%M:%S"; }
log() { echo "[] $1"; }

# DRY=1 ise silmez, sileceklerini listeler
del() {
    if [ "$DRY" = "1" ]; then
        for p in "$@"; do [ -e "$p" ] && log "[DRY] silecek: $p"; done
    else
        rm -rf "$@" 2>/dev/null || true
    fi
}

delfind() { # delfind <arama-kokleri...> -- <find-ifadeleri>
    local roots=() expr=() seen_ddash=0
    for a in "$@"; do
        if [ "$a" = "--" ]; then seen_ddash=1; continue; fi
        if [ "$seen_ddash" = "0" ]; then roots+=("$a"); else expr+=("$a"); fi
    done
    if [ "$DRY" = "1" ]; then
        find "${roots[@]}" "${expr[@]}" -exec du -sh {} + 2>/dev/null
    else
        find "${roots[@]}" "${expr[@]}" -exec rm -rf {} + 2>/dev/null || true
    fi
}

runcmd() { # cache temizlik komutlari icin
    if [ "$DRY" = "1" ]; then log "[DRY] komut atlandi: $*"; else "$@" 2>/dev/null || true; fi
}

clean_safe() {
    log "🧹 [Safe] Cleaning package manager caches, runtimes & temporary files..."
    runcmd npm cache clean --force
    runcmd pnpm store prune
    runcmd bun pm cache rm
    runcmd brew cleanup -s --prune=all

    del ~/.cache/yarn ~/.cache/uv ~/.cache/codex-runtimes ~/.cache/mongodb-binaries
    # npx geçici paket cache'i — `npm cache clean --force` buna DOKUNMAZ (_cacache
    # hariç ayrı bir dizin). 2026-09-05'te 1.8GB tutuyordu; ilk npx kullanımında
    # yeniden indirilir, silinmesi güvenli.
    del ~/.npm/_npx
    del ~/Library/Caches/dotslash ~/Library/Caches/Homebrew ~/Library/Caches/node-gyp
    del ~/Library/Caches/JetBrains/Toolbox ~/Library/Caches/com.google.antigravity
    # /private/var/folders altındaki devasa EAS CLI ve macOS kod imzalama klonlarını temizle
    delfind /private/var/folders -type d \( -name "eas-cli-nodejs" -o -name "*.code_sign_clone" \) -prune --
    if [ "$DRY" = "1" ]; then
        for f in ~/Downloads/*.dmg ~/Downloads/*.pkg; do [ -e "$f" ] && log "[DRY] silecek: $f"; done
    else
        rm -f ~/Downloads/*.dmg ~/Downloads/*.pkg 2>/dev/null || true
    fi
}

clean_dev() {
    log "📱 [Dev] Cleaning mobile build caches (ios/build, android/build), Xcode DerivedData & Pods (Simulators Preserved)..."

    # Android gradle build çıktıları — 2026-09-06'da app/build 17.2GB + .cxx
    # (NDK/CMake build state) 3.6GB birikmişti. Kaynak koda dokunmaz; sonraki
    # gradlew build yeniden üretir. NOT: "-not -path */.cxx/*" şart — CMake
    # hedefin mutlak yolunu dizin adına gömer (appmodules.dir/<abs>/build),
    # yoksa .cxx iç dizinleri yanlış match olur.
    # Daemon/temizlik stratejisi: AKTİF gradle build varsa (wrapper/gradle
    # client süreci) ne daemon'a ne build çıktısına ne ~/.gradle/caches'e
    # dokun — build'i bozar. Sadece idle daemon varsa durdur ve temizle.
    # (Eski davranış "daemon varsa her şeyi atla" idi; 3 saat idle kalan
    # daemon bütün temizlik turunu blokluyordu.) DRY modunda pkill runcmd
    # tarafından atlanır.
    if pgrep -f "gradle-wrapper.jar|GradleWrapperMain|org.gradle.launcher.GradleMain" >/dev/null 2>&1; then
        log "gradle build aktif — daemon + build/cache temizligi bu tur atlandi"
    else
        delfind ~/code -type d \( -name "node_modules" -o -name ".git" \) -prune -o -type d \( -path "*/ios/build" -o -path "*/android/build" \) -print --
        if pgrep -f "GradleDaemon|KotlinCompileDaemon" >/dev/null 2>&1; then
            log "idle gradle/kotlin daemon bulundu — durduruluyor"
            runcmd pkill -f "GradleDaemon|KotlinCompileDaemon"
            sleep 2
        fi
        delfind ~/code -type d -path "*/android/app/build" -not -path "*/.cxx/*" -prune --
        delfind ~/code -type d -path "*/android/app/.cxx" -prune --
        del ~/.gradle/caches ~/.android/cache ~/.android/build-cache
    fi

    # NOT: Xcode Archives, Simulator cihazlari ve DerivedData (FenixBackup linkli) bilerek korunuyor
    if [ -L ~/Library/Developer/Xcode/DerivedData ]; then
        # Symlink ise linki bozma, icerigini temizle
        delfind "$(readlink ~/Library/Developer/Xcode/DerivedData)" -mindepth 1 -maxdepth 1 --
    else
        del ~/Library/Developer/Xcode/DerivedData
    fi
    # Simulator RUNTIME loglari (diagnostic log)
    del ~/Library/Logs/CoreSimulator
    del ~/Library/Developer/Xcode/iOS\ DeviceSupport ~/Library/Developer/Xcode/DocumentationCache
    del ~/Library/Caches/com.apple.dt.Xcode ~/Library/Caches/org.swift.swiftpm ~/Library/org.swift.swiftpm
    del ~/Library/Caches/CocoaPods ~/.cocoapods/cache ~/Library/Caches/carthage
}

clean_ai() {
    log "🤖 [AI] Cleaning AI Agent replays, screenshots, temp sessions & models (Safe mode)..."
    del ~/.codex/.tmp ~/.codex/tmp* ~/.codex/computer-use
    if [ "$DRY" = "1" ]; then
        find ~/.codex/sessions -type f -mtime +14 -print 2>/dev/null | head -20
    else
        find ~/.codex/sessions -type f -mtime +14 -delete 2>/dev/null || true
    fi

    del ~/.browserclaw/replays ~/.browserclaw/screenshots
    del ~/.openclaw/tmp

    # Claude vm_bundles FenixBackup'a linklidir, linki bozma
    if [ ! -L ~/Library/Application\ Support/Claude/vm_bundles ]; then
        del ~/Library/Application\ Support/Claude/vm_bundles
    fi
    del ~/Library/Application\ Support/Claude/local-agent-mode-sessions

    # Hermes sync & large log files (PROFILES ARE PRESERVED, backups korunuyor)
    del ~/.hermes/obsidian-sync.log
    find ~/.hermes/logs -type f -name "*.log" -size +50M 2>/dev/null | while read -r f; do
        if [ "$DRY" = "1" ]; then log "[DRY] truncate: $f"; else truncate -s 0 "$f"; fi
    done

    del ~/.lmstudio/server-logs ~/.lmstudio/.internal/staged-updates-app ~/.lmstudio/.internal/temp-downloads
    del ~/Library/Application\ Support/Google/Chrome/OptGuideOnDeviceModel
    del ~/Library/Application\ Support/Google/GoogleUpdater/crx_cache
    del ~/.wakatime/*.zip ~/.wakatime/macos-wakatime.log
    if [ -f ~/.wakatime/wakatime.log ]; then
        if [ "$DRY" = "1" ]; then log "[DRY] truncate: ~/.wakatime/wakatime.log"; else truncate -s 0 ~/.wakatime/wakatime.log; fi
    fi
    if command -v sqlite3 >/dev/null 2>&1 && [ -f ~/.zcode/cli/db/db.sqlite ]; then
        if [ "$DRY" = "1" ]; then log "[DRY] checkpoint: ~/.zcode/cli/db/db.sqlite"; else sqlite3 ~/.zcode/cli/db/db.sqlite "PRAGMA wal_checkpoint(TRUNCATE);" >/dev/null 2>&1 || true; fi
    fi
}

clean_docker() {
    log "🐳 [Docker] Pruning unused Docker containers, networks, images & volumes..."
    if command -v docker >/dev/null 2>&1; then
        runcmd docker system prune -af --volumes
    fi
}

case "$MODE" in
    safe) clean_safe ;;
    dev) clean_safe; clean_dev ;;
    ai) clean_safe; clean_ai ;;
    docker) clean_docker ;;
    all)
        clean_safe
        clean_dev
        clean_ai
        clean_docker
        ;;
    *)
        echo "Usage: $0 [all|safe|dev|ai|docker]  (DRY=1 ile dry-run)"
        exit 1
        ;;
esac

if [ "$DRY" = "1" ]; then log "🔍 DRY-RUN bitti — hicbir sey silinmedi."; else log "✅ Cleanup completed successfully!"; fi
