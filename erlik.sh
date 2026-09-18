#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

case "$1" in
    start)
        pkill -f "$DIR/erlik-app" 2>/dev/null || true
        pkill -f "$DIR/erlik-daemon" 2>/dev/null || true
        pkill -f "$DIR/erlik_web.js" 2>/dev/null || true
        pkill -f "$DIR/erlik-menubar" 2>/dev/null || true
        
        "$DIR/erlik-app" > "$DIR/app.log" 2>&1 &
        
        echo "🐺 ERLİK Unified Native Core & WebUI v3.2 başlatıldı!"
        echo "📊 Modern Dashboard: http://localhost:5757"
        echo "🍎 macOS Menubar Widget devrede: Menü çubuğundaki kurt simgesini kontrol edin!"
        ;;
    stop)
        pkill -f "$DIR/erlik-app" 2>/dev/null || true
        pkill -f "$DIR/erlik-daemon" 2>/dev/null || true
        pkill -f "$DIR/erlik_web.js" 2>/dev/null || true
        pkill -f "$DIR/erlik-menubar" 2>/dev/null || true
        echo "🛑 ERLİK tüm servisleriyle durduruldu."
        ;;
    status)
        if pgrep -f "$DIR/erlik-app" >/dev/null; then
            echo "🟢 ERLİK Unified Core: ÇALIŞIYOR (PID: $(pgrep -f "$DIR/erlik-app" | head -1))"
            echo "📊 Web Dashboard: http://localhost:5757"
            echo "🍎 Status Bar: Aktif"
        else
            echo "🔴 ERLİK Unified Core: DURDU"
        fi
        ;;
    *)
        echo "Kullanım: $0 {start|stop|status}"
        exit 1
        ;;
esac
