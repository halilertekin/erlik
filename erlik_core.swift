import Cocoa
import SQLite3
import Foundation

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

    if lowerBundle.contains("antigravity") || lowerBundle.contains("cursor") || lowerBundle.contains("codex") || lowerBundle.contains("zed") || lowerBundle.contains("xcode") || lowerBundle.contains("iterm") || lowerBundle.contains("terminal") || lowerBundle.contains("warp") || lowerBundle.contains("cmux") || lowerName.contains("zcode") || lowerName.contains("code") {
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

// MARK: - Project Detector
func detectProject(appName: String, windowTitle: String) -> String {
    let title = windowTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    let lowerTitle = title.lowercased()
    
    let knownProjects = [
        "erlik", "immostory", "qnack", "tolky", "mamapapa", "glowniq",
        "kinderverhaal", "silayolu", "paratura", "probex", "tamam",
        "2run", "vetaverse", "hermes", "openclaw", "pascal-editor", "activity"
    ]
    
    for proj in knownProjects {
        if lowerTitle.contains(proj) {
            return proj.capitalized
        }
    }
    
    if title.contains(" — ") {
        let parts = title.components(separatedBy: " — ")
        for part in parts {
            let p = part.trimmingCharacters(in: .whitespaces)
            if !p.contains(".") && p.count > 2 && p.count < 30 {
                return p
            }
        }
    } else if title.contains(" - ") {
        let parts = title.components(separatedBy: " - ")
        if let last = parts.last?.trimmingCharacters(in: .whitespaces), !last.isEmpty && last != appName {
            if last.count > 2 && last.count < 30 && !last.contains(".") {
                return last
            }
        }
    }

    if title.contains("/") {
        let segments = title.components(separatedBy: "/")
        if let codeIdx = segments.firstIndex(of: "code"), codeIdx + 1 < segments.count {
            return segments[codeIdx + 1].capitalized
        }
    }

    if appName.lowercased().contains("antigravity") || appName.lowercased().contains("code") {
        return "Erlik"
    }

    return "Genel"
}

// MARK: - Git Branch Detection
func detectGitBranch(project: String) -> String {
    if project.isEmpty || project == "Genel" || project == "-" { return "-" }
    
    let fm = FileManager.default
    let home = fm.homeDirectoryForCurrentUser.path
    let candidates = [
        "\(home)/code/\(project.lowercased())",
        "\(home)/code/habil/\(project.lowercased()).be",
        "\(home)/code/habil/\(project.lowercased())",
        "\(home)/code/probex/\(project.lowercased())"
    ]
    
    for c in candidates {
        if fm.fileExists(atPath: "\(c)/.git") {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
            task.currentDirectoryURL = URL(fileURLWithPath: c)
            task.arguments = ["branch", "--show-current"]
            let pipe = Pipe()
            task.standardOutput = pipe
            do {
                try task.run()
                task.waitUntilExit()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let branch = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !branch.isEmpty {
                    return branch
                }
            } catch {}
        }
    }
    return "-"
}

// MARK: - Direct AppleScript Window Title Fetch
func getActiveWindowName(appName: String) -> String {
    let escapedApp = appName.replacingOccurrences(of: "\"", with: "\\\"")
    let script = """
    tell application "System Events"
        if exists (process "\(escapedApp)") then
            tell process "\(escapedApp)"
                if (count of windows) > 0 then
                    return name of front window
                end if
            end tell
        end if
    end tell
    return ""
    """
    
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    task.arguments = ["-e", script]
    let pipe = Pipe()
    task.standardOutput = pipe
    
    do {
        try task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let str = String(data: data, encoding: .utf8) {
            return str.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    } catch {}
    
    return ""
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
            project_name TEXT DEFAULT 'Genel',
            git_branch TEXT DEFAULT '-',
            window_title TEXT,
            duration_seconds INTEGER NOT NULL,
            is_afk INTEGER DEFAULT 0
        );
        CREATE INDEX IF NOT EXISTS idx_erlik_time ON erlik_heartbeats(timestamp);
        CREATE INDEX IF NOT EXISTS idx_erlik_app ON erlik_heartbeats(app_name);
        CREATE INDEX IF NOT EXISTS idx_erlik_project ON erlik_heartbeats(project_name);
        CREATE INDEX IF NOT EXISTS idx_erlik_category ON erlik_heartbeats(category);
        """
        sqlite3_exec(db, sql, nil, nil, nil)
        sqlite3_exec(db, "ALTER TABLE erlik_heartbeats ADD COLUMN git_branch TEXT DEFAULT '-';", nil, nil, nil)
    }

    func record(app: String, bundleId: String, project: String, branch: String, title: String, duration: Int, isAfk: Bool) {
        let cat = isAfk ? "Boşta (AFK)" : categorizeApp(bundleId: bundleId, appName: app)
        let proj = isAfk ? "-" : project
        let br = isAfk ? "-" : branch
        let sql = "INSERT INTO erlik_heartbeats (app_name, bundle_id, category, project_name, git_branch, window_title, duration_seconds, is_afk) VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (app as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (bundleId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (cat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (proj as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (br as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, Int32(duration))
            sqlite3_bind_int(stmt, 8, isAfk ? 1 : 0)
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

// MARK: - Main Daemon Engine
let dbPath = "/Users/halil/code/erlik/erlik.db"
let db = ErlikDB(path: dbPath)

print("🛡️ ERLİK Core Native Daemon (Title + Project + Git Branch) aktifleştirildi.")
print("📦 Veritabanı: \(dbPath)")

let sampleInterval: TimeInterval = 2.0
var currentApp = ""
var currentBundle = ""
var currentTitle = ""
var currentProject = ""
var currentBranch = ""
var accumulatedSeconds = 0

Timer.scheduledTimer(withTimeInterval: sampleInterval, repeats: true) { _ in
    let idleSecs = getIdleSeconds()
    let isAfk = idleSecs >= 120.0

    var appName = "AFK / Dinlenme"
    var bundleId = "com.apple.idle"
    var windowTitle = ""
    var projName = "-"
    var branchName = "-"

    if !isAfk {
        if let front = NSWorkspace.shared.frontmostApplication {
            appName = front.localizedName ?? "Bilinmeyen"
            bundleId = front.bundleIdentifier ?? "unknown.app"
            windowTitle = getActiveWindowName(appName: appName)
            projName = detectProject(appName: appName, windowTitle: windowTitle)
            branchName = detectGitBranch(project: projName)
        }
    }

    if appName == currentApp && windowTitle == currentTitle {
        accumulatedSeconds += Int(sampleInterval)
    } else {
        if !currentApp.isEmpty && accumulatedSeconds > 0 {
            db.record(app: currentApp, bundleId: currentBundle, project: currentProject, branch: currentBranch, title: currentTitle, duration: accumulatedSeconds, isAfk: currentApp.starts(with: "AFK"))
        }
        currentApp = appName
        currentBundle = bundleId
        currentTitle = windowTitle
        currentProject = projName
        currentBranch = branchName
        accumulatedSeconds = Int(sampleInterval)
    }
}

RunLoop.main.run()
