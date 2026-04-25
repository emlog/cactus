cask "cactus" do
  version "1.4.3"
  sha256 "601f103cfa2268a1e12dd90d881ccaacd7951df3bce0f13d822195ebd087134b"

  url "https://github.com/emlog/cactus/releases/download/v#{version}/Cactus.dmg"
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
