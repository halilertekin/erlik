#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

case "$1" in
    start)
        pkill -f "$DIR/erlik-daemon" 2>/dev/null || true
        pkill -f "$DIR/erlik_web.js" 2>/dev/null || true
        pkill -f "$DIR/erlik-menubar" 2>/dev/null || true
        
        "$DIR/erlik-daemon" > "$DIR/daemon.log" 2>&1 &
        node "$DIR/erlik_web.js" > "$DIR/web.log" 2>&1 &
        "$DIR/erlik-menubar" > "$DIR/menubar.log" 2>&1 &
        
        echo "🐺 ERLİK Native Activity & Focus Intelligence v3.0 başlatıldı!"
        echo "📊 Modern Dashboard: http://localhost:5757"
        echo "🍎 macOS Menubar Widget devrede: Menü çubuğundaki kurt simgesini kontrol edin!"
        ;;
    stop)
        pkill -f "$DIR/erlik-daemon" 2>/dev/null || true
        pkill -f "$DIR/erlik_web.js" 2>/dev/null || true
        pkill -f "$DIR/erlik-menubar" 2>/dev/null || true
        echo "🛑 ERLİK tüm servisleriyle durduruldu."
        ;;
    status)
        if pgrep -f "$DIR/erlik-daemon" >/dev/null; then
            echo "🟢 ERLİK Daemon: ÇALIŞIYOR (PID: $(pgrep -f "$DIR/erlik-daemon" | head -1))"
        else
            echo "🔴 ERLİK Daemon: DURDU"
        fi
        if pgrep -f "$DIR/erlik_web.js" >/dev/null; then
            echo "🟢 ERLİK Web UI: ÇALIŞIYOR (http://localhost:5757)"
        else
            echo "🔴 ERLİK Web UI: DURDU"
        fi
        if pgrep -f "$DIR/erlik-menubar" >/dev/null; then
            echo "🟢 ERLİK Menubar: ÇALIŞIYOR (macOS Status Bar)"
        else
            echo "🔴 ERLİK Menubar: DURDU"
        fi
        ;;
    *)
        echo "Kullanım: $0 {start|stop|status}"
        exit 1
        ;;
esac
