## 新版发布流程

- 1
- 2
- 3

## Testflight 测试流程

1. 正在处理
2. 缺少合规证明，提交合规证明操作后，开始合规证明审核。
3. 如果是只发布到TF的可以开始内测
4. 如果是发布到TF和AppStore的可以开始内侧
5. 准备提交，可以开始公测，需要通过审核
6. 审核通过，开始公测


## 打包发布

1、进入Product/achive
2、选择Distribute App
3、export 到处app到项目根目录
4、./build.sh 运行打包脚本

### 开发者信息

Certificate Name：dawei xu
bundle-id：dawei-snow.cactus
iCloud Container：iCloud.snow.cactusai
app 专有密码：qbsl-pjfd-ugam-qtsq
备案号：京ICP备09000973号-6A

### Membership Details

| Field        | Value                   |
| ------------ | ----------------------- |
| Team ID      | MYB38L5YW9              |
| Plan         | Apple Developer Program |
| Type         | Individual              |
| Renewal Date | March 23, 2026          |
| Annual Fee   | RMB688                  |


### 签名和公证（可选但推荐）
为了让您的应用在 macOS 上顺利运行，建议进行代码签名和公证

简单说：
- 签名 = 谁做的，签名用的证书（Developer ID Application / Developer ID Installer）只能通过付费账户生成，必须是苹果的付费开发者（Apple Developer Program 会员，一年 99 美元）
- 公证 = 苹果确认这个包没问题

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

### 4. 测试安装包
最后，测试您的 DMG 文件，确保它能正常打开和安装应用程序。



### 自建更新方案

- sparkle https://sparkle-project.org/

## 制作 appicons

- figma 模版（macOS Icon Template）：https://www.figma.com/community/file/857303226040719059/macos-big-sur-icon-template
- 状态栏图标
  - 尺寸：19x19 and 38x38
  - 设置为 Template Image
  - 设备选择：Mac

## 第三方库

### 已使用

- Settings 设置界面 https://github.com/sindresorhus/Settings
- AlertToast 吐司提示 https://github.com/elai950/AlertToast
- KeyboardShortcuts 快捷键 https://github.com/sindresorhus/KeyboardShortcuts
- LaunchAtLogin-Legacy 开机自动启动 https://github.com/sindresorhus/LaunchAtLogin-Legacy
- swift-markdown-ui Markdown解析 https://github.com/gonzalezreal/swift-markdown-ui

### 未使用

- loading动画 https://github.com/exyte/ActivityIndicatorView
- GRDB 数据库（替代CoreData） https://github.com/groue/GRDB.swift

## CoreData同步iCloud

- 参考文档：https://fatbobman.com/zh/posts/coredatawithcloudkit-2/
- 在线查看数据：https://icloud.developer.apple.com/dashboard/database/teams/MYB38L5YW9/containers/iCloud.dawei-snow.cactus/environments/DEVELOPMENT/records?database=private&using=fetchChanges&zone=_com.apple.coredata.cloudkit.zone%3A_1d454d06bfdc3e9def95aca801f39fcf%3AREGULAR_CUSTOM_ZONE&sortOrder=newest

## 学习资料

- 关于SSE：https://www.ruanyifeng.com/blog/2017/05/server-sent_events.html
