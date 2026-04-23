cask "cactus" do
  version "1.4.1"
  sha256 :no_check # 后续发布 release 后请更新为实际的 SHA256

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
