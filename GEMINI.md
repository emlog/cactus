# Cactus (仙人掌 AI 助手) 项目指南

本项目是一款基于 macOS 的智能 AI 助手，提供翻译、总结、词典查询及 OCR 识别等功能。

## 1. 项目简介
- **名称**：Cactus (仙人掌 AI 助手)
- **目标**：提升办公与学习效率，通过 AI 赋能文字处理流程。
- **Bundle ID**：`com.dawei.cactus`
- **当前版本**：1.4.3 (参考 `cactus.rb`)

## 2. 技术栈
- **语言**：Swift 5.x
- **框架**：SwiftUI (主要 UI 框架), AppKit (macOS 原生能力)
- **数据持久化**：Core Data (用于收藏和历史记录)
- **依赖管理**：Swift Package Manager (SPM)
- **AI 交互**：支持 OpenAI, DeepSeek, Claude, Gemini, 智谱 AI, 火山引擎等多种模型。

## 3. 核心功能与快捷键
- **快捷翻译** (`⌥ + X`)：选中文本瞬间翻译。
- **智能总结** (`⌥ + S`)：提炼文章要点。
- **上下文词典** (`⌥ + Z`)：深入解释词义与用法。
- **截图 OCR** (`⌥ + A`)：识别屏幕区域文字并翻译。
- **主窗口** (`⌥ + C`)：打开助手交互主界面。

## 4. 开发环境
- **操作系统**：macOS (建议 13.0+)
- **开发工具**：Xcode (建议 15.0+)
- **包管理**：需要联网以通过 SPM 下载依赖。

## 5. 运行与构建

## 测试运行

```bash
xcodebuild -scheme cactus -configuration Debug -derivedDataPath ./build build
open ./build/Build/Products/Debug/Cactus.app
```

### 打包发布
项目提供了一个极简打包脚本 `build.sh`，用于生成 DMG 文件：
```bash
# 给予执行权限
chmod +x build.sh

# 运行打包脚本 (可选择性传入版本号)
./build.sh 1.4.3
```
**注意**：`build.sh` 会执行 Ad-hoc 本地自签名，以解决非开发者证书环境下的运行问题。

## 8. 开发规范
- **注释**：生成代码时需添加函数级注释（见全局 `gemini.md`）。
- **语言**：UI 文本需支持中英文多语言（见 `en.lproj` 和 `zh-Hans.lproj`）。
- **性能**：由于涉及 OCR 和 AI 交互，需关注内存占用及异步处理，避免阻塞主线程。
