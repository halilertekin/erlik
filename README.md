# 🐺 ERLİK — Open Source Native Mac Activity & Focus Intelligence

<p align="center">
  <img src="assets/erlik_logo.jpg" width="180" height="180" alt="ERLIK Logo" style="border-radius: 28px;">
</p>

<p align="center">
  <b>Apple Silicon (ARM64) İçin Açık Kaynak, Sıfır Bellek Tüketimli Zaman ve Odak Takipçisi</b><br>
  <i>İsmini Türk mitolojisinin derinlik ve kayıtlar hükümdarı Erlik Han'dan alır.</i>
</p>

<p align="center">
  <a href="#özellikler">Özellikler</a> •
  <a href="#activitywatch-farkı">ActivityWatch Farkı</a> •
  <a href="#hızlı-başlangıç">Hızlı Başlangıç</a> •
  <a href="#dışa-aktarma-export">Export</a> •
  <a href="#katkıda-bulunma">Katkıda Bulunma</a>
</p>

---

## ⚡ Özellikler

- **Saf Apple Silicon Native (ARM64):** Rosetta gerektirmez. macOS `NSWorkspace`, `CGWindowList` ve `IOHIDSystem` API'leri üzerinden doğrudan Swift ile çalışır (~8 MB RAM).
- **Gerçek Zamanlı Donanımsal AFK:** Kullanıcı klavye/fareyi bıraktığında (donanım sayacı ile) çalışma süresi otomatik dondurulur.
- **Modern & Tam Duyarlı (Responsive) Dashboard:**
  - Mobil, tablet ve masaüstü uyumlu glassmorphism arayüz.
  - Klasik `alert()` yerine modern Glass Modal ve Toast bildirimleri.
  - Günlük (24s) / Haftalık (7g) / Aylık (30g) zaman filtreleri.
  - Chart.js zaman çizelgesi ve kategori halka grafiği.
- **ActivityWatch Standardında Dışa Aktarma (Export):**
  - Tüm aktivitelerinizi açık kaynak formatında (Bucket / Event tabanlı JSON) tek tıkla indirebilirsiniz.
- **Kişiselleştirilebilir Raporlama:**
  - Kullanıcı panelden kendi e-posta adresini ve opsiyonel Discord/Slack Webhook URL'sini tanımlayabilir.
- **Kalıcı & Gizlilik Odaklı (Local-First):** Veriler harici sunuculara gitmez, lokal SQLite (`erlik.db`) üzerinde kalır.

---

## 📊 ActivityWatch vs ERLİK

| Özellik | ActivityWatch (macOS) | ERLİK (Native ARM64) |
| :--- | :--- | :--- |
| **Mimari & İşlemci** | Ağır Python/Qt + x86 (Rosetta ihtiyacı) | Saf Swift ARM64 (Apple Silicon Native) |
| **RAM Tüketimi** | ~150 - 300 MB | **~8 - 15 MB** |
| **Pil / Enerji Verimi** | Orta | **Maksimum (Sıfır CPU yükü)** |
| **Arayüz** | Vue/Ağır Web | Ultra hafif Tailwind + Responsive Glass UI |
| **Bildirimler** | Tarayıcı alert | Entegre Toast & Modal bileşenleri |
| **Raporlama** | Eklenti gerektirir | Dahili E-Posta & Discord Webhook |

---

## 🚀 Hızlı Başlangıç

### 1. Klonlayın ve Başlatın
```bash
git clone https://github.com/halilertekin/erlik.git
cd erlik
./erlik.sh start
```

Tarayıcınızda açın: **[http://localhost:5757](http://localhost:5757)**

### 2. Durum Kontrolü & Durdurma
```bash
./erlik.sh status   # Servis durumunu kontrol eder
./erlik.sh stop     # Servisleri durdurur
```

---

## 📦 Dışa Aktarma (Export)

Dashboard üzerindeki **"Dışa Aktar"** butonuna basarak veya doğrudan API üzerinden tüm geçmişi JSON olarak alabilirsiniz:
```bash
curl http://localhost:5757/api/export > erlik-backup.json
```

---

## 📜 Lisans
MIT License. Topluluk katkılarına açıktır!
