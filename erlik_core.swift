import Cocoa
import SQLite3
import Foundation

// MARK: - App Category Resolver
enum AppCategory: String {
    case coding = "Yazılım & IDE"
    case agentic = "AI & AGI Ajanları"
    case design = "Tasarım & Medya"
    case browsing = "Tarayıcı & Web"
    case communication = "İletişim & Chat"
    case productivity = "Notlar & Ofis"
    case system = "Sistem & Diğer"
}

func categorizeApp(bundleId: String, appName: String) -> String {
    let lowerBundle = bundleId.lowercased()
    let lowerName = appName.lowercased()

    // 1. Autonomous AI Coding Agents & AGI Engines (Priority match)
    if lowerBundle.contains("antigravity") || lowerBundle.contains("cursor") || lowerBundle.contains("codex") ||
       lowerBundle.contains("hermes") || lowerBundle.contains("openclaw") || lowerBundle.contains("claude") ||
       lowerBundle.contains("chatgpt") || lowerBundle.contains("copilot") || lowerBundle.contains("windsurf") ||
       lowerBundle.contains("devin") || lowerBundle.contains("aider") || lowerBundle.contains("ollama") ||
       lowerBundle.contains("lmstudio") || lowerName.contains("antigravity") || lowerName.contains("cursor") ||
       lowerName.contains("codex") || lowerName.contains("hermes") || lowerName.contains("openclaw") ||
       lowerName.contains("claude") || lowerName.contains("chatgpt") || lowerName.contains("windsurf") ||
       lowerName.contains("copilot") || lowerName.contains("aider") || lowerName.contains("gemini") {
        return AppCategory.agentic.rawValue
    }

    // 2. Comprehensive IDEs, Editors & Terminals
    if lowerBundle.contains("vscode") || lowerBundle.contains("vscodium") || lowerBundle.contains("code") ||
       lowerBundle.contains("zed") || lowerBundle.contains("xcode") || lowerBundle.contains("sublime") ||
       lowerBundle.contains("jetbrains") || lowerBundle.contains("intellij") || lowerBundle.contains("pycharm") ||
       lowerBundle.contains("webstorm") || lowerBundle.contains("goland") || lowerBundle.contains("clion") ||
       lowerBundle.contains("rider") || lowerBundle.contains("datagrip") || lowerBundle.contains("fleet") ||
       lowerBundle.contains("iterm") || lowerBundle.contains("terminal") || lowerBundle.contains("warp") ||
       lowerBundle.contains("alacritty") || lowerBundle.contains("kitty") || lowerBundle.contains("wezterm") ||
       lowerBundle.contains("hyper") || lowerBundle.contains("neovim") || lowerBundle.contains("macvim") ||
       lowerBundle.contains("emacs") || lowerBundle.contains("nova") || lowerBundle.contains("textmate") ||
       lowerBundle.contains("postman") || lowerBundle.contains("insomnia") || lowerBundle.contains("tableplus") ||
       lowerBundle.contains("dbeaver") || lowerBundle.contains("docker") || lowerBundle.contains("sourcetree") ||
       lowerBundle.contains("fork") || lowerName.contains("xcode") || lowerName.contains("code") ||
       lowerName.contains("zed") || lowerName.contains("terminal") || lowerName.contains("warp") ||
       lowerName.contains("iterm") || lowerName.contains("studio") || lowerName.contains("sublime") {
        return AppCategory.coding.rawValue
    }

    // 3. Browsers
    if lowerBundle.contains("chrome") || lowerBundle.contains("safari") || lowerBundle.contains("arc") ||
       lowerBundle.contains("brave") || lowerBundle.contains("firefox") || lowerBundle.contains("edge") ||
       lowerBundle.contains("orion") || lowerBundle.contains("opera") || lowerBundle.contains("vivaldi") ||
       lowerBundle.contains("browser") || lowerName.contains("chrome") || lowerName.contains("safari") ||
       lowerName.contains("arc") || lowerName.contains("brave") || lowerName.contains("firefox") {
        return AppCategory.browsing.rawValue
    }

    // 4. Design & Creative
    if lowerBundle.contains("figma") || lowerBundle.contains("canva") || lowerBundle.contains("photoshop") ||
       lowerBundle.contains("illustrator") || lowerBundle.contains("bambustudio") || lowerBundle.contains("blender") ||
       lowerBundle.contains("sketch") || lowerBundle.contains("affinity") || lowerBundle.contains("premiere") ||
       lowerBundle.contains("aftereffects") || lowerBundle.contains("finalcut") || lowerBundle.contains("davinci") {
        return AppCategory.design.rawValue
    }

    // 5. Communication & Team Chat
    if lowerBundle.contains("slack") || lowerBundle.contains("discord") || lowerBundle.contains("whatsapp") ||
       lowerBundle.contains("telegram") || lowerBundle.contains("messages") || lowerBundle.contains("spark") ||
       lowerBundle.contains("mail") || lowerBundle.contains("zoom") || lowerBundle.contains("teams") ||
       lowerBundle.contains("mattermost") {
        return AppCategory.communication.rawValue
    }

    // 6. Notes & Productivity
    if lowerBundle.contains("notion") || lowerBundle.contains("notes") || lowerBundle.contains("linear") ||
       lowerBundle.contains("word") || lowerBundle.contains("excel") || lowerBundle.contains("obsidian") ||
       lowerBundle.contains("craft") || lowerBundle.contains("bear") || lowerBundle.contains("reminders") ||
       lowerBundle.contains("calendar") || lowerBundle.contains("trello") || lowerBundle.contains("jira") {
        return AppCategory.productivity.rawValue
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
    let proj = project.lowercased()
    let candidates = [
        "\(home)/code/\(proj)",
        "\(home)/Projects/\(proj)",
        "\(home)/Developer/\(proj)",
        "\(home)/Documents/Projects/\(proj)",
        "\(home)/code/habil/\(proj).be",
        "\(home)/code/habil/\(proj)",
        "\(home)/code/probex/\(proj)"
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

    private static func getComputerName() -> String {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/scutil")
        task.arguments = ["--get", "ComputerName"]
        let pipe = Pipe()
        task.standardOutput = pipe
        try? task.run()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let name = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty {
            return name
        }
        return Host.current().localizedName ?? "Mac"
    }

    private func setupTables() {
        let defaultDev = ErlikDB.getComputerName()
        let sql = """
        CREATE TABLE IF NOT EXISTS erlik_heartbeats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            device_id TEXT DEFAULT '\(defaultDev)',
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
        CREATE INDEX IF NOT EXISTS idx_erlik_device ON erlik_heartbeats(device_id);
        CREATE INDEX IF NOT EXISTS idx_erlik_app ON erlik_heartbeats(app_name);
        CREATE INDEX IF NOT EXISTS idx_erlik_project ON erlik_heartbeats(project_name);
        CREATE INDEX IF NOT EXISTS idx_erlik_category ON erlik_heartbeats(category);
        """
        sqlite3_exec(db, sql, nil, nil, nil)
        sqlite3_exec(db, "ALTER TABLE erlik_heartbeats ADD COLUMN git_branch TEXT DEFAULT '-';", nil, nil, nil)
        sqlite3_exec(db, "ALTER TABLE erlik_heartbeats ADD COLUMN device_id TEXT DEFAULT '\(defaultDev)';", nil, nil, nil)
    }

    func record(app: String, bundleId: String, project: String, branch: String, title: String, duration: Int, isAfk: Bool, deviceId: String? = nil) {
        let actualDev = deviceId ?? ErlikDB.getComputerName()
        let cat = isAfk ? "Boşta (AFK)" : categorizeApp(bundleId: bundleId, appName: app)
        let proj = isAfk ? "-" : project
        let br = isAfk ? "-" : branch
        let sql = "INSERT INTO erlik_heartbeats (device_id, app_name, bundle_id, category, project_name, git_branch, window_title, duration_seconds, is_afk) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (actualDev as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (app as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 3, (bundleId as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (cat as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (proj as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (br as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 8, Int32(duration))
            sqlite3_bind_int(stmt, 9, isAfk ? 1 : 0)
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
let fileManager = FileManager.default
let currentDir = fileManager.currentDirectoryPath
let defaultPath = "\(currentDir)/erlik.db"
let envDb = ProcessInfo.processInfo.environment["ERLIK_DB_PATH"]
let dbPath = envDb ?? (fileManager.fileExists(atPath: defaultPath) ? defaultPath : "\(fileManager.homeDirectoryForCurrentUser.path)/.erlik/erlik.db")

// Ensure parent directory exists if using home
if dbPath.contains("/.erlik/") {
    try? fileManager.createDirectory(atPath: "\(fileManager.homeDirectoryForCurrentUser.path)/.erlik", withIntermediateDirectories: true)
}

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
