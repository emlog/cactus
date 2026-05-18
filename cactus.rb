cask "cactus" do
  version "1.4.6"
  sha256 "655038c88829a4a4a3b5f9fc665907a92118edef0a71c8ca52320721f0dcbc66"

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
