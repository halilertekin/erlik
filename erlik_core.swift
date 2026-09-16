import Cocoa
import SQLite3
import Foundation
import ApplicationServices

// MARK: - App Category Resolver
enum AppCategory: String {
    case coding = "Yazılım & Terminal"
    case design = "Tasarım & Medya"
    case browsing = "Tarayıcı & Web"
    case communication = "İletişim & Chat"
    case productivity = "Notlar & Ofis"
    case agentic = "AI & Otomasyon"
    case system = "Sistem & Diğer"
}

func categorizeApp(bundleId: String, appName: String) -> String {
    let lowerBundle = bundleId.lowercased()
    let lowerName = appName.lowercased()

    if lowerBundle.contains("antigravity") || lowerBundle.contains("cursor") || lowerBundle.contains("codex") || lowerBundle.contains("zed") || lowerBundle.contains("xcode") || lowerBundle.contains("iterm") || lowerBundle.contains("terminal") || lowerBundle.contains("warp") || lowerName.contains("zcode") || lowerName.contains("code") {
        return AppCategory.coding.rawValue
    }
    if lowerBundle.contains("chrome") || lowerBundle.contains("safari") || lowerBundle.contains("arc") || lowerBundle.contains("brave") || lowerBundle.contains("browser") {
        return AppCategory.browsing.rawValue
    }
    if lowerBundle.contains("figma") || lowerBundle.contains("canva") || lowerBundle.contains("photoshop") || lowerBundle.contains("illustrator") || lowerBundle.contains("bambustudio") {
        return AppCategory.design.rawValue
    }
    if lowerBundle.contains("slack") || lowerBundle.contains("discord") || lowerBundle.contains("whatsapp") || lowerBundle.contains("telegram") || lowerBundle.contains("messages") || lowerBundle.contains("spark") {
        return AppCategory.communication.rawValue
    }
    if lowerBundle.contains("notion") || lowerBundle.contains("notes") || lowerBundle.contains("linear") || lowerBundle.contains("word") || lowerBundle.contains("excel") || lowerBundle.contains("obsidian") {
        return AppCategory.productivity.rawValue
    }
    if lowerName.contains("hermes") || lowerName.contains("agent") || lowerName.contains("openclaw") {
        return AppCategory.agentic.rawValue
    }
    return AppCategory.system.rawValue
}

// MARK: - SQLite Manager
class ErlikDB {
    var db: OpaquePointer?

    init(path: String) {
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("❌ Erlik DB açılırken hata oluştu: \(path)")
        }
        setupTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func setupTables() {
        let sql = """
        CREATE TABLE IF NOT EXISTS erlik_heartbeats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            app_name TEXT NOT NULL,
            bundle_id TEXT NOT NULL,
            category TEXT NOT NULL,
            window_title TEXT,
            duration_seconds INTEGER NOT NULL,
            is_afk INTEGER DEFAULT 0
        );
        CREATE INDEX IF NOT EXISTS idx_erlik_time ON erlik_heartbeats(timestamp);
        CREATE INDEX IF NOT EXISTS idx_erlik_app ON erlik_heartbeats(app_name);
        CREATE INDEX IF NOT EXISTS idx_erlik_category ON erlik_heartbeats(category);
        """
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    func record(app: String, bundleId: String, title: String, duration: Int, isAfk: Bool) {
        let cat = isAfk ? "Boşta (AFK)" : categorizeApp(bundleId: bundleId, appName: app)
        let sql = "INSERT INTO erlik_heartbeats (app_name, bundle_id, category, window_title, duration_seconds, is_afk) VALUES (?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (app as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (bundleId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (cat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, Int32(duration))
            sqlite3_bind_int(stmt, 6, isAfk ? 1 : 0)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }
}

// MARK: - Hardware Idle Time Detection
func getIdleSeconds() -> Double {
    var iterator: io_iterator_t = 0
    let matching = IOServiceMatching("IOHIDSystem")
    let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
    if result != KERN_SUCCESS { return 0 }
    defer { IOObjectRelease(iterator) }

    let entry = IOIteratorNext(iterator)
    if entry == 0 { return 0 }
    defer { IOObjectRelease(entry) }

    var dict: Unmanaged<CFMutableDictionary>?
    let kernResult = IORegistryEntryCreateCFProperties(entry, &dict, kCFAllocatorDefault, 0)
    if kernResult != KERN_SUCCESS || dict == nil { return 0 }
    let properties = dict!.takeRetainedValue() as NSDictionary

    if let nanoseconds = properties["HIDIdleTime"] as? NSNumber {
        return nanoseconds.doubleValue / 1_000_000_000.0
    }
    return 0
}

// MARK: - Active Window Title via Quartz & Accessibility
func getActiveWindowDetails(pid: pid_t) -> String {
    let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
    if let windowListInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] {
        for info in windowListInfo {
            if let ownerPID = info[kCGWindowOwnerPID as String] as? pid_t, ownerPID == pid {
                if let layer = info[kCGWindowLayer as String] as? Int, layer == 0 {
                    if let name = info[kCGWindowName as String] as? String, !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        return name
                    }
                }
            }
        }
    }
    return ""
}

// MARK: - Main Daemon Engine
let dbPath = "/Users/halil/code/erlik/erlik.db"
let db = ErlikDB(path: dbPath)

print("🛡️ ERLİK Core Native Daemon (Apple Silicon ARM64) aktifleştirildi.")
print("📦 Veritabanı: \(dbPath)")

let sampleInterval: TimeInterval = 2.0 // Her 2 sn örnekleme
var currentApp = ""
var currentBundle = ""
var currentTitle = ""
var accumulatedSeconds = 0

Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { _ in
    let idleSecs = getIdleSeconds()
    let isAfk = idleSecs >= 120.0 // 2 dk hareketsizlikte AFK modu

    var appName = "AFK / Dinlenme"
    var bundleId = "com.apple.idle"
    var windowTitle = ""

    if !isAfk {
        if let front = NSWorkspace.shared.frontmostApplication {
            appName = front.localizedName ?? "Bilinmeyen"
            bundleId = front.bundleIdentifier ?? "unknown.app"
            windowTitle = getActiveWindowDetails(pid: front.processIdentifier)
        }
    }

    if appName == currentApp && windowTitle == currentTitle {
        accumulatedSeconds += Int(sampleInterval)
    } else {
        if !currentApp.isEmpty && accumulatedSeconds > 0 {
            db.record(app: currentApp, bundleId: currentBundle, title: currentTitle, duration: accumulatedSeconds, isAfk: currentApp.starts(with: "AFK"))
        }
        currentApp = appName
        currentBundle = bundleId
        currentTitle = windowTitle
        accumulatedSeconds = Int(sampleInterval)
    }
}

RunLoop.main.run()
