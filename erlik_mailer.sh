#!/bin/bash
# ERLIK Otomatik E-Posta Raporlayıcı
DB_PATH="/Users/halil/code/erlik/erlik.db"
TO_EMAIL="halil@ertekin.me"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1502968852516966461/6u33jekF1gGYeQvKHArZZSeFlp8ofTE4uIF-k6D4CjAY-1LdBsiIXESL-DvzjtWLusJX"

# İstatistikleri SQLite'dan çek
TOTAL_SEC=$(sqlite3 "$DB_PATH" "SELECT IFNULL(SUM(duration_seconds), 0) FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= datetime('now', '-7 days');")
TOTAL_MIN=$((TOTAL_SEC / 60))
TOTAL_HRS=$(echo "scale=1; $TOTAL_MIN / 60" | bc 2>/dev/null || echo "$((TOTAL_MIN / 60))")

TOP_APPS=$(sqlite3 "$DB_PATH" "SELECT app_name || ': ' || (SUM(duration_seconds)/60) || ' dk' FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= datetime('now', '-7 days') GROUP BY app_name ORDER BY SUM(duration_seconds) DESC LIMIT 5;")

SUBJECT="🐺 ERLIK — Haftalık Mac Aktivite & Odak Raporu"
MESSAGE="Merhaba Halil,

Geçtiğimiz 7 günde Mac üzerindeki toplam odaklanma ve çalışma verilerin:

📊 Toplam Aktif Çalışma: ${TOTAL_HRS} saat (${TOTAL_MIN} dakika)
🏆 En Çok Kullanılan Uygulamalar:
${TOP_APPS}

Detaylı canlı paneline http://localhost:5757 üzerinden dilediğin an ulaşabilirsin.

Saygılarımızla,
ERLİK Native AI Agent"

# Discord Webhook'a da anında bildirim gönder
PAYLOAD=$(cat <<JSON
{
  "username": "ERLIK Focus Intelligence",
  "avatar_url": "https://raw.githubusercontent.com/halilertekin/erlik/main/assets/erlik_logo.jpg",
  "content": "🐺 **ERLIK Haftalık Aktivite Özeti:**\n⏱️ **Toplam Odak:** ${TOTAL_HRS} saat\n📱 **Top Uygulamalar:**\n\`\`\`\n${TOP_APPS}\n\`\`\`\n🔗 Dashboard: http://localhost:5757"
}
JSON
)

curl -s -H "Content-Type: application/json" -X POST -d "$PAYLOAD" "$DISCORD_WEBHOOK" >/dev/null 2>&1 || true

# Eğer himalaya CLI veya mail komutu varsa e-posta gönder
if command -v himalaya >/dev/null 2>&1; then
    echo "$MESSAGE" | himalaya message send -t "$TO_EMAIL" -s "$SUBJECT" >/dev/null 2>&1 || true
elif command -v mail >/dev/null 2>&1; then
    echo "$MESSAGE" | mail -s "$SUBJECT" "$TO_EMAIL" >/dev/null 2>&1 || true
fi

echo "✅ ERLIK Rapor Bildirimi Tamamlandı!"
