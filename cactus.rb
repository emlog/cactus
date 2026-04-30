cask "cactus" do
  version "1.4.4"
  sha256 "dd5db5ad877f078cd28b040779d6e4086c52d6b1fa276976470208694859776c"

  url "https://github.com/emlog/cactus/releases/download/v#{version}/cactus-#{version}-arm64.dmg"
  name "Cactus"
  desc "Intelligent text assistant | 智能文字助手"
  homepage "https://github.com/emlog/cactus"

  app "Cactus.app"

  zap trash: [
    "~/Library/Application Support/Cactus",
    "~/Library/Preferences/com.dawei.cactus.plist",
    "~/Library/Caches/com.dawei.cactus",
  ]
end
