import Cocoa
import Foundation
import Darwin
import SQLite3

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

    if lowerBundle.contains("chrome") || lowerBundle.contains("safari") || lowerBundle.contains("arc") ||
       lowerBundle.contains("brave") || lowerBundle.contains("firefox") || lowerBundle.contains("edge") ||
       lowerBundle.contains("orion") || lowerBundle.contains("opera") || lowerBundle.contains("vivaldi") ||
       lowerBundle.contains("browser") || lowerName.contains("chrome") || lowerName.contains("safari") ||
       lowerName.contains("arc") || lowerName.contains("brave") || lowerName.contains("firefox") {
        return AppCategory.browsing.rawValue
    }

    if lowerBundle.contains("figma") || lowerBundle.contains("canva") || lowerBundle.contains("photoshop") ||
       lowerBundle.contains("illustrator") || lowerBundle.contains("bambustudio") || lowerBundle.contains("blender") ||
       lowerBundle.contains("sketch") || lowerBundle.contains("affinity") || lowerBundle.contains("premiere") ||
       lowerBundle.contains("aftereffects") || lowerBundle.contains("finalcut") || lowerBundle.contains("davinci") {
        return AppCategory.design.rawValue
    }

    if lowerBundle.contains("slack") || lowerBundle.contains("discord") || lowerBundle.contains("whatsapp") ||
       lowerBundle.contains("telegram") || lowerBundle.contains("messages") || lowerBundle.contains("spark") ||
       lowerBundle.contains("mail") || lowerBundle.contains("zoom") || lowerBundle.contains("teams") ||
       lowerBundle.contains("mattermost") {
        return AppCategory.communication.rawValue
    }

    if lowerBundle.contains("notion") || lowerBundle.contains("notes") || lowerBundle.contains("linear") ||
       lowerBundle.contains("word") || lowerBundle.contains("excel") || lowerBundle.contains("obsidian") ||
       lowerBundle.contains("craft") || lowerBundle.contains("bear") || lowerBundle.contains("reminders") ||
       lowerBundle.contains("calendar") || lowerBundle.contains("trello") || lowerBundle.contains("jira") {
        return AppCategory.productivity.rawValue
    }

    return AppCategory.system.rawValue
}

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
    let lock = NSLock()

    static func getComputerName() -> String {
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

    init(path: String) {
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("❌ Erlik DB acilamadi: \(path)")
        }
        setupTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func setupTables() {
        lock.lock()
        defer { lock.unlock() }
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
        CREATE UNIQUE INDEX IF NOT EXISTS idx_erlik_unique_heartbeat ON erlik_heartbeats(timestamp, device_id, app_name);
        UPDATE erlik_heartbeats SET device_id = 'Halil MBP' WHERE device_id = 'MacBookPro-Local';
        """
        sqlite3_exec(db, sql, nil, nil, nil)
    }

    func record(app: String, bundleId: String, project: String, branch: String, title: String, duration: Int, isAfk: Bool, deviceId: String? = nil) {
        lock.lock()
        defer { lock.unlock() }
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

    func queryJSON(sql: String) -> String {
        lock.lock()
        defer { lock.unlock() }
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            return "[]"
        }
        defer { sqlite3_finalize(stmt) }

        var rows: [[String: Any]] = []
        let columnCount = sqlite3_column_count(stmt)

        while sqlite3_step(stmt) == SQLITE_ROW {
            var row: [String: Any] = [:]
            for i in 0..<columnCount {
                let name = String(cString: sqlite3_column_name(stmt, i))
                let type = sqlite3_column_type(stmt, i)
                switch type {
                case SQLITE_INTEGER:
                    row[name] = sqlite3_column_int64(stmt, i)
                case SQLITE_FLOAT:
                    row[name] = sqlite3_column_double(stmt, i)
                case SQLITE_TEXT:
                    if let cStr = sqlite3_column_text(stmt, i) {
                        row[name] = String(cString: cStr)
                    } else {
                        row[name] = ""
                    }
                case SQLITE_NULL:
                    row[name] = NSNull()
                default:
                    row[name] = ""
                }
            }
            rows.append(row)
        }

        if let data = try? JSONSerialization.data(withJSONObject: rows, options: []),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "[]"
    }
}

// MARK: - Native POSIX BSD HTTP Server (0 MB External Overhead, Pure POSIX Sockets)
class ErlikHTTPServer {
    let port: UInt16
    let baseDir: String
    let db: ErlikDB
    var serverSocket: Int32 = -1

    init(port: UInt16, baseDir: String, db: ErlikDB) {
        self.port = port
        self.baseDir = baseDir
        self.db = db
    }

    func start() {
        serverSocket = socket(AF_INET, SOCK_STREAM, 0)
        var opt: Int32 = 1
        setsockopt(serverSocket, SOL_SOCKET, SO_REUSEADDR, &opt, socklen_t(MemoryLayout<Int32>.size))

        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = in_port_t(port).bigEndian
        addr.sin_addr.s_addr = inet_addr("127.0.0.1")

        let bindRes = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                bind(serverSocket, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
            }
        }

        guard bindRes == 0 else {
            print("❌ HTTP Server bind hatasi: \(errno)")
            return
        }

        listen(serverSocket, 128)
        print("🚀 ERLİK Native BSD HTTP Server devrede: http://127.0.0.1:\(port)")

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            while true {
                var clientAddr = sockaddr_in()
                var clientLen = socklen_t(MemoryLayout<sockaddr_in>.size)
                let clientSocket = withUnsafeMutablePointer(to: &clientAddr) {
                    $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                        accept(self.serverSocket, $0, &clientLen)
                    }
                }
                guard clientSocket >= 0 else { continue }

                DispatchQueue.global(qos: .userInitiated).async {
                    self.handleClient(clientSocket)
                }
            }
        }
    }

    private func handleClient(_ clientSocket: Int32) {
        defer { close(clientSocket) }

        var buffer = [UInt8](repeating: 0, count: 8192)
        let bytesRead = read(clientSocket, &buffer, buffer.count)
        guard bytesRead > 0, let reqStr = String(bytes: buffer[0..<bytesRead], encoding: .utf8) else {
            return
        }

        let lines = reqStr.components(separatedBy: "\r\n")
        guard let firstLine = lines.first else { return }
        let parts = firstLine.components(separatedBy: " ")
        guard parts.count >= 2 else { return }

        let method = parts[0]
        let rawPath = parts[1]

        guard let url = URL(string: "http://127.0.0.1\(rawPath)") else { return }
        let path = url.path

        var body = Data()
        var contentType = "text/html; charset=utf-8"
        var statusCode = 200

        if path == "/" || path == "/index.html" {
            let htmlFile = "\(baseDir)/index.html"
            if let d = try? Data(contentsOf: URL(fileURLWithPath: htmlFile)) {
                body = d
                contentType = "text/html; charset=utf-8"
            } else {
                statusCode = 404
                body = "Not Found".data(using: .utf8)!
            }
        } else if path == "/assets/erlik_logo.jpg" {
            let logoFile = "\(baseDir)/assets/erlik_logo.jpg"
            if let d = try? Data(contentsOf: URL(fileURLWithPath: logoFile)) {
                body = d
                contentType = "image/jpeg"
            } else {
                statusCode = 404
                body = "Not Found".data(using: .utf8)!
            }
        } else if path == "/api/devices" {
            let json = db.queryJSON(sql: "SELECT DISTINCT IFNULL(device_id, 'Halil Mac mini') as device FROM erlik_heartbeats ORDER BY device ASC;")
            let devNames: [String]
            if let data = json.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                devNames = arr.compactMap { $0["device"] as? String }
            } else {
                devNames = ["Halil Mac mini"]
            }
            body = (try? JSONSerialization.data(withJSONObject: devNames)) ?? "[]".data(using: .utf8)!
            contentType = "application/json"
        } else if path == "/api/stats" {
            let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
            let range = queryItems.first(where: { $0.name == "range" })?.value ?? "day"
            let device = queryItems.first(where: { $0.name == "device" })?.value ?? ""

            var timeFilter = "timestamp >= datetime('now', 'localtime', 'start of day', 'utc')"
            var timeGroup = "strftime('%H:00', timestamp)"
            if range == "week" {
                timeFilter = "timestamp >= datetime('now', '-7 days')"
                timeGroup = "strftime('%Y-%m-%d', timestamp)"
            } else if range == "month" {
                timeFilter = "timestamp >= datetime('now', '-30 days')"
                timeGroup = "strftime('%Y-%m-%d', timestamp)"
            }

            var baseFilter = timeFilter
            if !device.isEmpty && device != "all" {
                let escaped = device.replacingOccurrences(of: "'", with: "''")
                baseFilter += " AND device_id = '\(escaped)'"
            }

            // Active and AFK duration calculation (capped at 60s per minute slot)
            let activeSql = """
            SELECT IFNULL(SUM(sec), 0) as total FROM (
                SELECT strftime('%Y-%m-%d %H:%M', timestamp) as slot, MIN(60, SUM(duration_seconds)) as sec
                FROM erlik_heartbeats 
                WHERE is_afk = 0 AND \(baseFilter)
                GROUP BY slot
            );
            """
            let afkSql = """
            SELECT IFNULL(SUM(sec), 0) as total FROM (
                SELECT strftime('%Y-%m-%d %H:%M', timestamp) as slot, MIN(60, SUM(duration_seconds)) as sec
                FROM erlik_heartbeats 
                WHERE is_afk = 1 AND \(baseFilter)
                GROUP BY slot
            );
            """
            let activeJson = db.queryJSON(sql: activeSql)
            let afkJson = db.queryJSON(sql: afkSql)
            let countJson = db.queryJSON(sql: "SELECT COUNT(*) as total FROM erlik_heartbeats WHERE \(baseFilter);")

            var totalActive = 0
            if let data = activeJson.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let tot = arr.first?["total"] as? Int {
                totalActive = tot
            }

            var totalAfk = 0
            if let data = afkJson.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let tot = arr.first?["total"] as? Int {
                totalAfk = tot
            }

            var totalCount = 0
            if let data = countJson.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
               let tot = arr.first?["total"] as? Int {
                totalCount = tot
            }

            // Multi-device active union calculation when "all" is selected
            if device.isEmpty || device == "all" {
                let unionJson = db.queryJSON(sql: """
                    SELECT IFNULL(SUM(sec), 0) as total FROM (
                        SELECT strftime('%Y-%m-%d %H:%M', timestamp) as slot, MIN(60, SUM(duration_seconds)) as sec
                        FROM erlik_heartbeats 
                        WHERE is_afk = 0 AND \(timeFilter)
                        GROUP BY slot
                    );
                """)
                if let data = unionJson.data(using: .utf8),
                   let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                   let uTot = arr.first?["total"] as? Int, uTot > 0 {
                    totalActive = uTot
                }
            }

            // Agents
            let agentSql = """
            SELECT app_name, SUM(duration_seconds) as total_sec 
            FROM erlik_heartbeats 
            WHERE is_afk = 0 AND \(baseFilter) AND (category LIKE '%AI%' OR category LIKE '%AGI%' OR app_name LIKE '%Antigravity%' OR app_name LIKE '%Cursor%' OR app_name LIKE '%Codex%' OR app_name LIKE '%Windsurf%' OR app_name LIKE '%Devin%' OR app_name LIKE '%Aider%' OR app_name LIKE '%Hermes%' OR app_name LIKE '%OpenClaw%' OR app_name LIKE '%ChatGPT%' OR app_name LIKE '%Claude%' OR app_name LIKE '%Copilot%') 
            GROUP BY app_name ORDER BY total_sec DESC;
            """
            let agentJson = db.queryJSON(sql: agentSql)
            var agentsBreakdown: [[String: Any]] = []
            var totalAiSec = 0
            if let data = agentJson.data(using: .utf8),
               let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                for item in arr {
                    let name = item["app_name"] as? String ?? ""
                    let sec = item["total_sec"] as? Int ?? 0
                    totalAiSec += sec
                    let tokens = sec * 35
                    let cost = Double(tokens) / 1000.0 * 0.003
                    agentsBreakdown.append([
                        "agent": name,
                        "duration_seconds": sec,
                        "tokens": tokens,
                        "cost_usd": Double(String(format: "%.2f", cost)) ?? 0.0
                    ])
                }
            }

            let humanSec = max(0, totalActive - totalAiSec)
            let aiRatio = totalActive > 0 ? Int(round(Double(totalAiSec) / Double(totalActive) * 100.0)) : 0
            let totalTokens = agentsBreakdown.reduce(0) { $0 + ($1["tokens"] as? Int ?? 0) }
            let totalCostUsd = agentsBreakdown.reduce(0.0) { $0 + ($1["cost_usd"] as? Double ?? 0.0) }

            let catJson = db.queryJSON(sql: "SELECT category, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND \(baseFilter) GROUP BY category ORDER BY total_sec DESC;")
            let appJson = db.queryJSON(sql: "SELECT app_name, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND \(baseFilter) GROUP BY app_name ORDER BY total_sec DESC LIMIT 10;")
            let proJson = db.queryJSON(sql: "SELECT IFNULL(project_name, 'Genel') as project, IFNULL(git_branch, '-') as branch, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND \(baseFilter) GROUP BY project ORDER BY total_sec DESC LIMIT 8;")
            let streakJson = db.queryJSON(sql: "SELECT strftime('%Y-%m-%d', timestamp) as day, SUM(duration_seconds) as total_sec FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= datetime('now', '-14 days') GROUP BY day ORDER BY day ASC;")
            let recJson = db.queryJSON(sql: "SELECT timestamp, IFNULL(device_id, 'Halil Mac mini') as device_id, app_name, category, IFNULL(project_name, 'Genel') as project_name, IFNULL(git_branch, '-') as git_branch, window_title, duration_seconds FROM erlik_heartbeats WHERE \(baseFilter) ORDER BY id DESC LIMIT 25;")
            let timeJson = db.queryJSON(sql: "SELECT \(timeGroup) as period, SUM(duration_seconds) as duration FROM erlik_heartbeats WHERE is_afk = 0 AND \(baseFilter) GROUP BY period ORDER BY period ASC;")
            let devJson = db.queryJSON(sql: "SELECT DISTINCT IFNULL(device_id, 'Halil Mac mini') as device FROM erlik_heartbeats ORDER BY device ASC;")

            let parseArr: (String) -> Any = { str in
                if let d = str.data(using: .utf8), let obj = try? JSONSerialization.jsonObject(with: d) {
                    return obj
                }
                return []
            }

            var devList: [String] = []
            if let arr = parseArr(devJson) as? [[String: Any]] {
                devList = arr.compactMap { $0["device"] as? String }
            }

            let payload: [String: Any] = [
                "total_active_seconds": totalActive,
                "total_afk_seconds": totalAfk,
                "total_ai_coding_seconds": totalAiSec,
                "human_seconds": humanSec,
                "ai_ratio_pct": aiRatio,
                "total_estimated_tokens": totalTokens,
                "total_estimated_cost_usd": Double(String(format: "%.2f", totalCostUsd)) ?? 0.0,
                "agents_breakdown": agentsBreakdown,
                "total_events": totalCount,
                "daily_goal_hours": 4,
                "selected_device": device.isEmpty ? "all" : device,
                "devices": devList,
                "categories": parseArr(catJson),
                "apps": parseArr(appJson),
                "projects": parseArr(proJson),
                "streak": parseArr(streakJson),
                "recent": parseArr(recJson),
                "timeline": parseArr(timeJson)
            ]

            if let respData = try? JSONSerialization.data(withJSONObject: payload) {
                body = respData
                contentType = "application/json"
            }
        } else if (path == "/api/clean-cache" || path == "/api/purge-ram") && (method == "POST" || method == "GET") {
            let scriptPath = FileManager.default.fileExists(atPath: "\(baseDir)/erlik_clean.sh") ? "\(baseDir)/erlik_clean.sh" : "/Users/halil/code/erlik/erlik_clean.sh"
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = [scriptPath, "all"]
            try? task.run()
            body = "{\"success\": true, \"message\": \"Sistem onbellegi & RAM temizligi basariyla tetiklendi!\"}".data(using: .utf8)!
            contentType = "application/json"
        } else {
            statusCode = 404
            body = "Not Found".data(using: .utf8)!
        }

        let header = "HTTP/1.1 \(statusCode) OK\r\nContent-Type: \(contentType)\r\nContent-Length: \(body.count)\r\nAccess-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n"
        var resData = header.data(using: .utf8)!
        resData.append(body)
        _ = resData.withUnsafeBytes { ptr in
            write(clientSocket, ptr.baseAddress, resData.count)
        }
    }
}

// MARK: - Menubar & Application Companion
enum ErlikLang: String { case tr, en, nl }

struct I18n {
    static func t(_ key: String, lang: ErlikLang) -> String {
        let dict: [String: [ErlikLang: String]] = [
            "title": [.tr: "🐺 ERLİK Sistem & Odak Zekâsı", .en: "🐺 ERLİK System & Focus Intelligence", .nl: "🐺 ERLİK Systeem & Focus Intelligentie"],
            "open_dashboard": [.tr: "📊 Web Dashboard'u Aç", .en: "📊 Open Web Dashboard", .nl: "📊 Open Web Dashboard"],
            "pomodoro": [.tr: "🍅 Pomodoro Başlat/Durdur", .en: "🍅 Toggle Pomodoro", .nl: "🍅 Schakel Pomodoro In/Uit"],
            "purge_ram": [.tr: "🧹 RAM & Önbellek Temizle", .en: "🧹 Free RAM & Purge Memory", .nl: "🧹 RAM Vrijmaken & Geheugen Opschonen"],
            "clean_disk": [.tr: "🗑️ Sistem & Disk Önbelleğini Temizle", .en: "🗑️ Clean System & Disk Caches", .nl: "🗑️ Systeem & Schijfcache Opschonen"],
            "toggle_hardware": [.tr: "👁️ Disk/RAM Göster/Gizle", .en: "👁️ Toggle Disk/RAM Display", .nl: "👁️ Toon/Verberg Schijf & RAM"],
            "lang_select": [.tr: "🌐 Dil / Language / Taal", .en: "🌐 Dil / Language / Taal", .nl: "🌐 Dil / Language / Taal"],
            "quit": [.tr: "Çıkış", .en: "Quit", .nl: "Afsluiten"],
            "purging": [.tr: "Temizleniyor...", .en: "Cleaning...", .nl: "Opschonen..."],
            "purged": [.tr: "Bellek ve Önbellek Başarıyla Rahatlatıldı!", .en: "Memory & Caches Freed Successfully!", .nl: "Geheugen en Caches Succesvol Opgeschoond!"]
        ]
        return dict[key]?[lang] ?? key
    }
}

class ErlikApp: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var timer: Timer?
    var showHardwareMetrics = true
    var currentLang: ErlikLang = .tr

    let db: ErlikDB
    let httpServer: ErlikHTTPServer

    var currentApp = ""
    var currentBundle = ""
    var currentTitle = ""
    var currentProject = ""
    var currentBranch = ""
    var accumulatedSeconds = 0

    init(db: ErlikDB, server: ErlikHTTPServer) {
        self.db = db
        self.httpServer = server
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        loadPreferences()
        buildMenu()
        updateStatus()

        // 1. Activity tracker loop (2 seconds)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.trackActivity()
        }

        // 2. Menubar status update loop (3 seconds)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.updateStatus()
        }
    }

    func loadPreferences() {
        if let savedShow = UserDefaults.standard.object(forKey: "erlik_show_hardware") as? Bool {
            showHardwareMetrics = savedShow
        }
        if let savedLang = UserDefaults.standard.string(forKey: "erlik_lang"),
           let lang = ErlikLang(rawValue: savedLang) {
            currentLang = lang
        }
    }

    func savePreferences() {
        UserDefaults.standard.set(showHardwareMetrics, forKey: "erlik_show_hardware")
        UserDefaults.standard.set(currentLang.rawValue, forKey: "erlik_lang")
    }

    func buildMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: I18n.t("title", lang: currentLang), action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: I18n.t("open_dashboard", lang: currentLang), action: #selector(openDashboard), keyEquivalent: "d"))
        menu.addItem(NSMenuItem(title: I18n.t("pomodoro", lang: currentLang), action: #selector(togglePomodoro), keyEquivalent: "p"))
        menu.addItem(NSMenuItem(title: I18n.t("purge_ram", lang: currentLang), action: #selector(purgeRAM), keyEquivalent: "r"))
        menu.addItem(NSMenuItem(title: I18n.t("clean_disk", lang: currentLang), action: #selector(cleanDisk), keyEquivalent: "c"))
        menu.addItem(NSMenuItem.separator())
        
        let toggleHW = NSMenuItem(title: "\(I18n.t("toggle_hardware", lang: currentLang)) [\(showHardwareMetrics ? "✓" : "✗")]", action: #selector(toggleHardware), keyEquivalent: "h")
        menu.addItem(toggleHW)

        let langMenu = NSMenu()
        let trItem = NSMenuItem(title: "🇹🇷 Türkçe \(currentLang == .tr ? "✓" : "")", action: #selector(setLangTR), keyEquivalent: "")
        let enItem = NSMenuItem(title: "🇬🇧 English \(currentLang == .en ? "✓" : "")", action: #selector(setLangEN), keyEquivalent: "")
        let nlItem = NSMenuItem(title: "🇳🇱 Nederlands \(currentLang == .nl ? "✓" : "")", action: #selector(setLangNL), keyEquivalent: "")
        langMenu.addItem(trItem)
        langMenu.addItem(enItem)
        langMenu.addItem(nlItem)

        let langParent = NSMenuItem(title: I18n.t("lang_select", lang: currentLang), action: nil, keyEquivalent: "")
        langParent.submenu = langMenu
        menu.addItem(langParent)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: I18n.t("quit", lang: currentLang), action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    func getDiskFreeSpace() -> String {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: "/System/Volumes/Data")
            if let freeBytes = attrs[.systemFreeSize] as? Int64 {
                let gb = Double(freeBytes) / 1_073_741_824.0
                return String(format: "%.0fG", gb)
            }
        } catch {}
        return "--"
    }

    func getRAMUsage() -> String {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64_data_t>.size / MemoryLayout<integer_t>.size)
        let kerr = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        if kerr == KERN_SUCCESS {
            let pageSize = UInt64(vm_kernel_page_size)
            let active = UInt64(stats.active_count) * pageSize
            let wired = UInt64(stats.wire_count) * pageSize
            let compressed = UInt64(stats.compressor_page_count) * pageSize
            let usedBytes = active + wired + compressed
            let totalBytes = ProcessInfo.processInfo.physicalMemory
            let usedGB = Double(usedBytes) / 1_073_741_824.0
            let pct = Double(usedBytes) / Double(totalBytes) * 100.0
            return String(format: "%.0f%% (%.0fG)", pct, usedGB)
        }
        return "--"
    }

    func trackActivity() {
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
            accumulatedSeconds += 2
        } else {
            if !currentApp.isEmpty && accumulatedSeconds > 0 {
                db.record(app: currentApp, bundleId: currentBundle, project: currentProject, branch: currentBranch, title: currentTitle, duration: accumulatedSeconds, isAfk: currentApp.starts(with: "AFK"))
            }
            currentApp = appName
            currentBundle = bundleId
            currentTitle = windowTitle
            currentProject = projName
            currentBranch = branchName
            accumulatedSeconds = 2
        }
    }

    func getIdleSeconds() -> Double {
        let matching = IOServiceMatching("IOHIDSystem")
        let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
        guard service != 0 else { return 0 }
        defer { IOObjectRelease(service) }

        let entry: io_registry_entry_t = service
        var unmanagedDict: Unmanaged<CFMutableDictionary>? = nil
        if IORegistryEntryCreateCFProperties(entry, &unmanagedDict, kCFAllocatorDefault, 0) == KERN_SUCCESS,
           let dict = unmanagedDict?.takeRetainedValue() as? [String: Any],
           let idleNanos = dict["HIDIdleTime"] as? Int64 {
            return Double(idleNanos) / 1_000_000_000.0
        }
        return 0
    }

    @objc func updateStatus() {
        let diskStr = getDiskFreeSpace()
        let ramStr = getRAMUsage()

        // Calculate today's active seconds directly from SQLite without network lag
        let activeJson = db.queryJSON(sql: "SELECT IFNULL(SUM(duration_seconds), 0) as total FROM erlik_heartbeats WHERE is_afk = 0 AND timestamp >= date('now', 'start of day');")
        var mins = 0
        if let data = activeJson.data(using: .utf8),
           let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           let tot = arr.first?["total"] as? Int {
            mins = tot / 60
        }

        let hrs = Double(mins) / 60.0
        let hrUnit = currentLang == .nl ? "u" : (currentLang == .en ? "h" : "sa")
        let minUnit = currentLang == .nl ? "m" : (currentLang == .en ? "m" : "dk")
        let timeStr = mins > 90 ? String(format: "%.1f %@", hrs, hrUnit) : "\(mins) \(minUnit)"

        DispatchQueue.main.async {
            if self.showHardwareMetrics {
                self.statusItem?.button?.title = "🐺 \(timeStr) | 💾 \(diskStr) | 🧠 \(ramStr)"
            } else {
                self.statusItem?.button?.title = "🐺 \(timeStr)"
            }
        }
    }

    @objc func toggleHardware() {
        showHardwareMetrics.toggle()
        savePreferences()
        buildMenu()
        updateStatus()
    }

    @objc func setLangTR() { currentLang = .tr; savePreferences(); buildMenu(); updateStatus() }
    @objc func setLangEN() { currentLang = .en; savePreferences(); buildMenu(); updateStatus() }
    @objc func setLangNL() { currentLang = .nl; savePreferences(); buildMenu(); updateStatus() }

    @objc func purgeRAM() {
        statusItem?.button?.title = "🐺 🧹 \(I18n.t("purging", lang: currentLang))"
        DispatchQueue.global(qos: .userInitiated).async {
            // 1. Try safe non-root system purge or user-space malloc zone relief
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/bin/bash")
            task.arguments = ["-c", """
                python3 -c "import ctypes; libc = ctypes.CDLL(None); libc.malloc_zone_pressure_relief(0, 0)" 2>/dev/null || true
            """]
            try? task.run()
            task.waitUntilExit()

            DispatchQueue.main.async {
                self.updateStatus()
            }
        }
    }

    @objc func cleanDisk() {
        statusItem?.button?.title = "🐺 🗑️ \(I18n.t("purging", lang: currentLang))"
        DispatchQueue.global(qos: .userInitiated).async {
            let cleanScript = "\(self.httpServer.baseDir)/erlik_clean.sh"
            if FileManager.default.fileExists(atPath: cleanScript) {
                let task = Process()
                task.executableURL = URL(fileURLWithPath: "/bin/bash")
                task.arguments = [cleanScript, "all"]
                try? task.run()
                task.waitUntilExit()
            }

            DispatchQueue.main.async {
                self.updateStatus()
            }
        }
    }

    @objc func openDashboard() {
        if let url = URL(string: "http://localhost:5757") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc func togglePomodoro() {
        openDashboard()
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

// MARK: - Application Entry Point
let baseDir = "/Users/halil/code/erlik"
let dbPath = "\(baseDir)/erlik.db"
let db = ErlikDB(path: dbPath)

let server = ErlikHTTPServer(port: 5757, baseDir: baseDir, db: db)
server.start()

let app = NSApplication.shared
let delegate = ErlikApp(db: db, server: server)
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
