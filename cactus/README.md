## 仙人掌

仙人掌
Cactus

仙人掌 - AI阅读辅助工具
AI text translation, summarization, interpretation

仙人掌 - 是一款基于AI大模型对文字快速进行翻译、总结、解释的阅读辅助工具

Cactus - is a reading assistant tool based on an AI large model that quickly translates, summarizes, and explains text.

【主要功能】

文本翻译：选中任意文本，按下快捷键，快速完成翻译
摘要总结：对选中的文本进行精炼的总结
解释说明：用更易于理解的语言解释选中文本中的概念


【Main Features】

Text translation: Select any text and press the shortcut key to quickly complete the translation
Text summary: a concise summary of the selected text
Text explanation: Explain the concepts in the selected text in more understandable language



## 测试内容

London's Heathrow Airport resumed operations late Friday after an electrical fire at a nearby substation forced a full-day closure, causing global travel chaos with hundreds of canceled flights and thousands of stranded passengers. The explosion at a Hayes substation 1.5 miles from the airport knocked out power early Thursday, requiring 70 firefighters to battle a blaze in a transformer containing 25,000 liters of cooling oil.

Despite backup generators, Europe's busiest airport couldn't maintain normal operations, forcing flights to divert to airports across Europe and as far as Bangor, Maine. "Contingencies of certain sizes we cannot guard ourselves against 100%," Heathrow CEO Thomas Woldbye told the BBC. "This is as big as it gets for our airport." British Airways, which planned to carry 100,000 passengers Friday, prioritized long-haul flights to Australia, Brazil and South Africa when operations resumed after 4 p.m.



# 将 macOS App 项目发布为 DMG 安装包
要将您的 macOS 应用程序打包成 DMG 安装包，需要经过以下几个步骤：

## 1. 构建发布版本的应用程序
首先，您需要在 Xcode 中构建一个发布版本的应用程序：

1. 在 Xcode 中打开您的项目
2. 选择 Product > Archive
3. 等待构建完成后，会打开 Organizer 窗口
4. 在 Organizer 中，选择您刚刚创建的归档文件，然后点击 "Distribute App"，选·择 Custom 选项
5. 选择 "Copy App"，然后按照向导完成导出应用程序

### 使用 create-dmg 工具
这是一个更自动化的方法：

1. 安装 create-dmg 工具：
```bash
brew install create-dmg
 ```

2. 使用以下命令创建 DMG：
```bash
create-dmg \
  --volname "Cactus" \
  --volicon "/Users/xudawei/cactus/AppIcon.icns" \
  --background "/Users/xudawei/cactus/background.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "Cactus.app" 200 190 \
  --hide-extension "Cactus.app" \
  --app-drop-link 600 185 \
  "Cactus.dmg" \
  "/path/to/exported/Cactus.app/"
 ```

## 3. 签名和公证（可选但推荐）
为了让您的应用在 macOS 上顺利运行，建议进行代码签名和公证：

1. 使用您的开发者证书签名应用：
```bash
codesign --force --sign "Developer ID Application: Your Name (TEAM_ID)" /path/to/Cactus.app
```

2. 公证您的 DMG 文件：
```bash
xcrun altool --notarize-app --primary-bundle-id "com.yourcompany.cactus" --username "your@apple.id" --password "app-specific-password" --file Cactus.dmg
```

3. 检查公证状态：
```bash
xcrun altool --notarization-info [REQUEST_UUID] --username "your@apple.id" --password "app-specific-password"
```

4. 在 DMG 上添加公证票据：
```bash
xcrun stapler staple Cactus.dmg
 ```

## 4. 测试安装包
最后，测试您的 DMG 文件，确保它能正常打开和安装应用程序。

