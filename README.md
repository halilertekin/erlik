# 🐺 ERLİK — Native Mac Activity & Focus Intelligence

<p align="center">
  <img src="assets/erlik_logo.jpg" width="180" height="180" alt="ERLIK Logo" style="border-radius: 28px;">
</p>

<p align="center">
  <b>Apple Silicon (M-Serisi) İçin Sıfır Bellek Tüketimli, Native ARM64 Zaman ve Aktivite Takipçisi</b><br>
  <i>İsmini Türk mitolojisinin derinlik ve kayıtlar hükümdarı Erlik Han'dan alır.</i>
</p>

---

## ⚡ Özellikler

- **Saf Apple Silicon Native (ARM64):** Rosetta 2 gerektirmez; macOS `NSWorkspace`, `CGWindowList` ve `IOHIDSystem` API'leri üzerinden native Swift ile derlenmiştir (~8 MB RAM).
- **Gerçek Zamanlı Donanımsal AFK:** Kullanıcı klavye/fareyi bıraktığında (donanım sayacı ile) çalışma süresi dondurulur, sahte odak yazılmaz.
- **Otomatik Uygulama Kategorizasyonu:**
  - `Yazılım & Terminal` (Xcode, Antigravity, Cursor, Zed, Warp, iTerm)
  - `Tarayıcı & Web` (Chrome, Safari, Arc, Brave)
  - `Tasarım & Medya` (Figma, Photoshop, BambuStudio)
  - `İletişim & Chat` (Slack, Discord, WhatsApp, Spark)
  - `Notlar & Ofis` (Notion, Apple Notes, Linear, Obsidian)
- **Kalıcı SQLite Veritabanı (`erlik.db`):** Veriler asla silinmez, lokalde güvenle saklanır.
- **Modern Glassmorphism Dashboard:**
  - Günlük / Haftalık / Aylık görünüm filtreleri.
  - Chart.js zaman çizelgesi ve kategori halka grafiği.
  - Canlı pencere akışı tablosu.
- **Otomatik Haftalık Raporlama:**
  - Haftalık çalışma ve odak verilerini `halil@ertekin.me` adresine ve Discord webhook'una otomatik özetler.

---

## 🚀 Hızlı Başlangıç

### Servisleri Başlatma
```bash
./erlik.sh start
```
Tarayıcınızda açın: **[http://localhost:5757](http://localhost:5757)**

### Durum Kontrolü
```bash
./erlik.sh status
```

### Servisleri Durdurma
```bash
./erlik.sh stop
```

---

## 🛠️ Mimari

- `erlik_core.swift`: Native Swift ARM64 Daemon (arka plan servisi).
- `erlik_web.js`: Node.js tabanlı REST API & Modern Dashboard sunucusu (Port 5757).
- `erlik_mailer.sh`: Haftalık email ve Discord webhook raporlayıcısı.
- `erlik.db`: Yerel SQLite veritabanı.

---
*Geliştirici:* Halil Ertekin <halil@ertekin.me>
