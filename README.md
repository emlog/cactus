## 仙人掌AI助手

仙人掌AI助手
Cactus AI Assistant

## 副标题：

基于大语言模型的智能文字助手，快速翻译、总结、解释选中文本
Translate, Summarize
基於大型語言模型的智慧文字助手，快速翻譯、摘要、解釋選取文字

## 关键词

翻译助手,AI总结,智能解释,文本处理,学习工具
AI Assistant,Text Tool,Translate,Summarize,Productivity
翻譯助手,AI 摘要,智慧解釋,文字處理,學習工具

### 简体中文介绍

仙人掌AI助手是一款基于大语言模型的智能文字助手，快速翻译、总结、解释选中文本。

核心功能：

• 快捷翻译：选中文本，按快捷键（默认 ⌥ + X），立即翻译
• 智能总结：提炼内容要点，一目了然
• 通俗解释：用简单语言讲清复杂内容

------

使用条款：https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
隐私策略：https://cactusai.cc/privacy-policy


### 英文介绍

Cactus AI Assistant is an AI-powered text assistant for quick translation, summarization, and explanation of selected content.

Key Features

• Quick Translate: Select text and press the shortcut key (default ⌥ + X) for instant translation
• Smart Summary: Extract key points at a glance
• Plain Explanation: Explain complex content in simple terms

------

Terms of Use：https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy：https://cactusai.cc/privacy-policy-en


### 繁体中文介绍

仙人掌 AI 助手是一款基於大型語言模型的智慧文字工具，能快速翻譯、摘要與解釋選取的文字內容。

主要功能：

• 快速翻譯：選取文字後，按下快捷鍵（預設 ⌥ + X），立即翻譯
• 智慧摘要：提煉重點內容，重點一目瞭然
• 白話解釋：以簡單易懂的語言說明複雜內容

------

使用條款：https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
隱私政策：https://cactusai.cc/privacy-policy



## 更新内容

修复已知问题，优化用户体验
Fix some issues, optimize user experience



## 开发者信息

Certificate Name：dawei xu
bundle-id：dawei-snow.cactus
app 专有密码：qbsl-pjfd-ugam-qtsq
备案号：京ICP备09000973号-6A

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


