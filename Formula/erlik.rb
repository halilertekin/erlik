class Erlik < Formula
  desc "Apple Silicon (ARM64) Native Activity & Focus Intelligence Tracker for macOS"
  homepage "https://github.com/halilertekin/erlik"
  url "https://github.com/halilertekin/erlik/archive/refs/tags/v3.2.3.tar.gz"
  sha256 "5b2561a3fdcb2476f9b9d7c606f29d8675d0ea49e5cd067edb2cbb09c4f927b6"
  license "MIT"
  head "https://github.com/halilertekin/erlik.git", branch: "main"

  depends_on :macos
  depends_on arch: :arm64
  depends_on "node"

  def install
    system "swiftc", "-O", "-target", "arm64-apple-macos14.0", "erlik_unified.swift", "-o", "erlik-app"
    system "swiftc", "-O", "-target", "arm64-apple-macos14.0", "erlik_core.swift", "-o", "erlik-daemon"
    system "swiftc", "-O", "-target", "arm64-apple-macos14.0", "erlik_menubar.swift", "-o", "erlik-menubar"
    
    libexec.install Dir["*"]
    bin.install_symlink libexec/"bin/erlik-cli.js" => "erlik"
  end

  def caveats
    <<~EOS
      🐺 ERLÍK kuruldu!
      Başlatmak için:
        erlik start
      Durdurmak için:
        erlik stop
      Durum kontrolü:
        erlik status
      
      Web Paneli: http://localhost:5757
    EOS
  end

  test do
    system "#{bin}/erlik", "status"
  end
end
