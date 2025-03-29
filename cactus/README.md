## 仙人掌

仙人掌
Cactus

仙人掌 - AI阅读助手
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



Certificate Name：dawei xu
bundle-id：dawei-snow.cactus
app 专有密码：qbsl-pjfd-ugam-qtsq

## Membership Details

| Field        | Value                   |
| ------------ | ----------------------- |
| Team ID      | MYB38L5YW9              |
| Plan         | Apple Developer Program |
| Type         | Individual              |
| Renewal Date | March 23, 2026          |
| Annual Fee   | RMB688                  |


## 签名和公证（可选但推荐）
为了让您的应用在 macOS 上顺利运行，建议进行代码签名和公证：

1. 使用您的开发者证书签名应用：
```bash
codesign --force --options runtime --timestamp --sign "Developer ID Application: dawei xu (MYB38L5YW9)" /Users/xudawei/Downloads/cactus/cactus.app
```

2. 创建DMG文件：

```bash
create-dmg cactus.dmg ./cactus
```

3. 公证您的 DMG 文件：
```bash
xcrun notarytool submit ./cactus.dmg --apple-id emlog@qq.com --password qbsl-pjfd-ugam-qtsq --team-id MYB38L5YW9
```

4. 检查公证状态：
```bash
xcrun notarytool history --apple-id emlog@qq.com --password qbsl-pjfd-ugam-qtsq --team-id MYB38L5YW9
```

4. 在 DMG 上添加公证票据：
```bash
xcrun stapler staple Cactus.dmg
 ```

## 4. 测试安装包
最后，测试您的 DMG 文件，确保它能正常打开和安装应用程序。



### create-dmg 工具
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


 ## 生成签名证书

 1. 打开钥匙串访问

在您的 Mac 上打开 钥匙串访问 应用程序，可以在 应用程序 -> 实用工具 中找到它。

2. 生成 CSR 文件
	1.	在钥匙串访问中，选择 证书助理 -> 从证书颁发机构请求证书。
	2.	在弹出的窗口中，您需要填写以下内容：
	•	电子邮件地址：输入与您的 Apple Developer 帐号相关联的邮箱地址。
	•	常用名称：输入您的名字或组织名称，通常选择您自己或您公司名。
	•	CA 证书颁发机构：选择 保存到磁盘。
	3.	保存证书请求文件：点击 继续，并选择保存位置，将生成的 CSR 文件保存到您的电脑。文件的扩展名应该是 .certSigningRequest。


