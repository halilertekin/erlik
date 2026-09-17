#!/bin/bash
# ERLIK Otomatik E-Posta & Webhook Raporlayıcı
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
DB_PATH="$DIR/erlik.db"
CONFIG_PATH="$DIR/config.json"
ENV_PATH="$DIR/.env"

# .env varsa kaynak olarak al
if [ -f "$ENV_PATH" ]; then
    export $(grep -v '^#' "$ENV_PATH" | xargs 2>/dev/null)
fi

TO_EMAIL="${USER_EMAIL:-$ERLIK_EMAIL}"
DISCORD_WEBHOOK="${USER_WEBHOOK:-$ERLIK_DISCORD_WEBHOOK}"

if [ -z "$TO_EMAIL" ] && [ -f "$CONFIG_PATH" ]; then
    TO_EMAIL=$(grep -o '"email": *"[^"]*"' "$CONFIG_PATH" | cut -d'"' -f4)
fi
if [ -z "$DISCORD_WEBHOOK" ] && [ -f "$CONFIG_PATH" ]; then
    DISCORD_WEBHOOK=$(grep -o '"webhook": *"[^"]*"' "$CONFIG_PATH" | cut -d'"' -f4)
fi

TOTAL_SEC=$(sqlite3 "$DB_PATH" "SELECT IFNULL(SUM(duration_seconds), 0) FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= datetime('now', '-7 days');")
TOTAL_MIN=$((TOTAL_SEC / 60))
TOTAL_HRS=$(echo "scale=1; $TOTAL_MIN / 60" | bc 2>/dev/null || echo "$((TOTAL_MIN / 60))")

TOP_APPS=$(sqlite3 "$DB_PATH" "SELECT app_name || ': ' || (SUM(duration_seconds)/60) || ' dk' FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= datetime('now', '-7 days') GROUP BY app_name ORDER BY SUM(duration_seconds) DESC LIMIT 5;")

SUBJECT="🐺 ERLIK — Haftalık Mac Aktivite & Odak Raporu"
MESSAGE="Merhaba,

Son 7 gündeki Mac odaklanma ve aktivite verileriniz:

📊 Toplam Aktif Çalışma: ${TOTAL_HRS} saat (${TOTAL_MIN} dakika)
🏆 En Çok Kullanılan Uygulamalar:
${TOP_APPS}

Detaylı canlı paneline http://localhost:5757 üzerinden dilediğin an ulaşabilirsin.

Saygılarımızla,
ERLİK Focus Intelligence"

# Discord Webhook Gönderimi
if [ -n "$DISCORD_WEBHOOK" ]; then
    PAYLOAD=$(cat <<JSON
{
  "username": "ERLIK Focus Intelligence",
  "avatar_url": "https://raw.githubusercontent.com/halilertekin/erlik/main/assets/erlik_logo.jpg",
  "content": "🐺 **ERLIK Haftalık Aktivite Özeti:**\n⏱️ **Toplam Odak:** ${TOTAL_HRS} saat\n📱 **Top Uygulamalar:**\n\`\`\`\n${TOP_APPS}\n\`\`\`\n🔗 Dashboard: http://localhost:5757"
}
JSON
    )
    curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$DISCORD_WEBHOOK" >/dev/null 2>&1 || true
fi

# E-Posta Gönderimi
if [ -n "$TO_EMAIL" ]; then
    if command -v himalaya >/dev/null 2>&1; then
        echo "$MESSAGE" | himalaya message send -t "$TO_EMAIL" -s "$SUBJECT" >/dev/null 2>&1 || true
    elif command -v mail >/dev/null 2>&1; then
        echo "$MESSAGE" | mail -s "$SUBJECT" "$TO_EMAIL" >/dev/null 2>&1 || true
    fi
fi

echo "✅ ERLIK Rapor Gönderimi Tamamlandı!"
