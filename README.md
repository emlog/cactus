# Cactus AI Assistant

[简体中文](./README.zh-CN.md)

Cactus is an intelligent text assistant for macOS designed to streamline your workflow with AI-powered translation, summarization, and OCR capabilities. **Completely free and open source under the MIT License.**

### ⚠️ Troubleshooting: "Cactus.app is damaged"
If you see a message saying **"Cactus.app is damaged and can't be opened"** when first running the app, this is a common macOS security warning for unsigned apps. Follow these steps to fix it:

1. Click **Cancel** (do NOT move to Trash).
2. Open **Terminal.app** (Found in Applications -> Utilities).
3. Paste and run the following command (enter your Mac password if prompted):
   ```bash
   sudo xattr -rd com.apple.quarantine /Applications/Cactus.app
   ```
4. Now you can open Cactus normally from your Applications folder.

---

### Key Features
- **Quick Translate**: Select text anywhere and press `⌥ + X` to get instant translations.
- **Smart Summarize**: Effortlessly condense long articles or documents into key points.
- **Contextual Dictionary**: Look up word definitions, etymology, and usage examples.
- **Screenshot OCR**: Capture any screen area to recognize and translate text instantly.
- **Vocabulary & Favorites**: Save important words and translated snippets for future review.
- **Privacy First**: Your data stays on your machine, interacting only with the AI providers you configure.

### Installation

#### Homebrew (Recommended)
You can easily install Cactus via Homebrew:
```bash
brew install emlog/cactus/cactus
```

#### Manual Installation
1. Download the latest release from the [GitHub Releases](https://github.com/emlog/cactus/releases) page.
2. Drag `Cactus.app` to your `Applications` folder.

### Usage
- **Shortcut Keys**:
  - `⌥ + X`: Translate selected text.
  - `⌥ + S`: Summarize selected content.
  - `⌥ + Z`: Dictionary lookup.
  - `⌥ + A`: Screenshot OCR translation.
  - `⌥ + C`: Open the main assistant window.

### Configuration
Cactus supports various AI providers including OpenAI, DeepSeek, Claude, Gemini, and more. Simply provide your own API key in the Preferences.

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
