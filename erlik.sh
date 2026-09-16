#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

case "$1" in
    start)
        pkill -f "$DIR/erlik-daemon" 2>/dev/null || true
        pkill -f "$DIR/erlik_web.js" 2>/dev/null || true
        
        "$DIR/erlik-daemon" > "$DIR/daemon.log" 2>&1 &
        node "$DIR/erlik_web.js" > "$DIR/web.log" 2>&1 &
        
        echo "🐺 ERLİK Native Activity & Focus Intelligence başlatıldı!"
        echo "📊 Modern Dashboard: http://localhost:5757"
        ;;
    stop)
        pkill -f "$DIR/erlik-daemon" 2>/dev/null || true
        pkill -f "$DIR/erlik_web.js" 2>/dev/null || true
        echo "🛑 ERLİK durduruldu."
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
        ;;
    *)
        echo "Kullanım: $0 {start|stop|status}"
        exit 1
        ;;
esac
