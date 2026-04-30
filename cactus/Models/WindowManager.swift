import AppKit
import SwiftUI
import Settings
import Foundation
import ApplicationServices
import Vision

class WindowManager: NSObject, NSWindowDelegate {
    var settingsWindow: NSWindow?
    var mainWindow: NSWindow?
    var vocabularyWindow: NSWindow? // 保留此窗口定义，虽然数据管理移到设置，但可能仍有直接打开此独立窗口的逻辑
    var favoriteWindow: NSWindow? // 保留此窗口定义，理由同上
    private var isMainWindowPinned = false
    private var pinnedWindowOrigin: NSPoint?
    private var pinButton: NSButton?
    private var settingsWindowController: SettingsWindowController?
    var accessibilityWindow: NSWindow?
    
    func checkAccessibilityAndShowAlert() {
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            showAccessibilityWindow()
        }
    }
    
    // 首次启动：权限请求窗口
    private func showAccessibilityWindow() {
        if accessibilityWindow == nil {
            accessibilityWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 450, height: 400),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            
            accessibilityWindow?.level = .floating
            accessibilityWindow?.center()
            accessibilityWindow?.titlebarAppearsTransparent = true
            accessibilityWindow?.titleVisibility = .hidden
            accessibilityWindow?.isReleasedWhenClosed = false
            accessibilityWindow?.collectionBehavior = [.canJoinAllSpaces]
            accessibilityWindow?.hidesOnDeactivate = false
            
            let accessibilityView = AccessibilityRequestView(onOpenMainWindow: { [weak self] in
                self?.showMainWindow()
                self?.accessibilityWindow?.close()
            })
            let hostingController = NSHostingController(rootView: accessibilityView)
            accessibilityWindow?.contentViewController = hostingController
        }
        
        accessibilityWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func initializeWindows() {
        initializeMainWindow()
    }
    
    private func initializeMainWindow() {
        // 初始化主窗口
        mainWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 690, height: 600),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        
        // 使标题栏透明并隐藏标题文本
        mainWindow?.titlebarAppearsTransparent = true
        mainWindow?.titleVisibility = .hidden
        
        // 设置窗口始终置顶
        mainWindow?.level = .floating
        mainWindow?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let mainView = MainView()
        let hostingController = NSHostingController(rootView: mainView)
        mainWindow?.contentViewController = hostingController
        mainWindow?.isReleasedWhenClosed = false
        mainWindow?.delegate = self
        
        // 动态调整窗口高度
        let contentSize = hostingController.view.intrinsicContentSize
        mainWindow?.setContentSize(contentSize)
        
        // 添加通知监听器来响应文本高度变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(adjustWindowSize),
            name: NSNotification.Name("AdjustWindowSize"),
            object: nil
        )
        
        // 添加通知监听器来响应打开偏好设置的请求
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(openPreferencesFromNotification),
            name: NSNotification.Name("OpenPreferences"),
            object: nil
        )
        
        setupTopBarButton()
    }
    
    // 初始化顶部栏按钮
    private func setupTopBarButton() {
        // 添加左侧按钮到标题栏
        let leftTitlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        leftTitlebarAccessoryViewController.layoutAttribute = .leading  // 将按钮放在左侧
        
        // 创建左侧容器视图，调整宽度以容纳三个按钮
        let leftContainerView = NSView(frame: NSRect(x: 0, y: 0, width: 80, height: 50))
        
        // Pin 按钮
        pinButton = NSButton()
        pinButton?.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: NSLocalizedString("help_pin", comment: "置顶窗口"))
        pinButton?.bezelStyle = .texturedRounded
        pinButton?.isBordered = false
        pinButton?.imageScaling = .scaleProportionallyDown
        pinButton?.target = self
        pinButton?.action = #selector(pinButtonTapped)
        pinButton?.toolTip = NSLocalizedString("help_pin", comment: "置顶窗口")
        pinButton?.sendAction(on: .leftMouseDown)
        pinButton?.frame = NSRect(x: 0, y: -5, width: 35, height: 35)
        
        leftContainerView.addSubview(pinButton!)
        leftTitlebarAccessoryViewController.view = leftContainerView
        mainWindow?.addTitlebarAccessoryViewController(leftTitlebarAccessoryViewController)
        
        // 添加右侧 ModelSelectionMenuView 到标题栏
        let rightTitlebarAccessoryViewController = NSTitlebarAccessoryViewController()
        rightTitlebarAccessoryViewController.layoutAttribute = .trailing  // 将按钮放在右侧
        
        // 创建 SwiftUI 视图的 NSHostingController
        let modelSelectionView = ModelSelectionMenuView()
        let hostingController = NSHostingController(rootView: modelSelectionView)
        
        // 设置容器视图大小
        let rightContainerView = NSView(frame: NSRect(x: 0, y: 0, width: 40, height: 50))
        hostingController.view.frame = NSRect(x: 0, y: -5, width: 35, height: 35)
        rightContainerView.addSubview(hostingController.view)
        
        rightTitlebarAccessoryViewController.view = rightContainerView
        mainWindow?.addTitlebarAccessoryViewController(rightTitlebarAccessoryViewController)
    }
    
    @objc private func adjustWindowSize() {
        // 取消之前的请求，实现防抖，避免频繁调整窗口大小导致CPU飙升
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performAdjustWindowSize), object: nil)
        // 延迟0.1秒执行，合并短时间内的多次请求
        self.perform(#selector(performAdjustWindowSize), with: nil, afterDelay: 0.1)
    }
    
    @objc private func performAdjustWindowSize() {
        guard let hostingController = mainWindow?.contentViewController as? NSHostingController<MainView> else {
            return
        }
        
        let contentSize = hostingController.sizeThatFits(in: NSSize(width: mainWindow?.frame.width ?? 500, height: CGFloat.greatestFiniteMagnitude))
        
        if let window = mainWindow, window.isVisible {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.2
                window.animator().setContentSize(contentSize)
            }
        } else {
            mainWindow?.setContentSize(contentSize)
        }
    }
    
    /// 响应通知打开偏好设置窗口
    @objc private func openPreferencesFromNotification() {
        openPreferences()
    }
    
    func openMain(action: ActionType = .translate) {
        // 根据操作类型先执行主任务
        if action == .screenshotTranslate {
            performScreenshotAndOCR(completion: handleCompletion(action: action))
        } else {
            checkAccessibilityPermissionAndGetClipboard(action: action, completion: handleCompletion(action: action))
        }
    }
    
    private func handleCompletion(action: ActionType) -> (Bool) -> Void {
        return { [weak self] success in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if success {
                    self.showMainWindow()
                } else {
                    if action == .screenshotTranslate {
                        print("截图翻译失败或用户取消了操作。")
                    } else {
                        print("未能成功获取选中文本或用户取消了操作。")
                    }
                }
            }
        }
    }
    
    func showMainWindow() {
        guard let window = self.mainWindow else { return }
        
        if self.isMainWindowPinned, let pinnedOrigin = self.pinnedWindowOrigin {
            window.setFrameOrigin(pinnedOrigin)
        } else {
            // 先居中窗口
            window.center()
            
            // 获取当前窗口位置并向上移动150个像素点
            var currentFrame = window.frame
            currentFrame.origin.y += 150
            window.setFrame(currentFrame, display: true)
        }
        
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func openFavorites() {
        if let existingController = settingsWindowController {
            existingController.window?.close()
            settingsWindowController = nil
        }
        
        createSettingsWindowController()
        
        if let window = settingsWindowController?.window {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: window
            )
        }
        
        // 直接显示收藏面板，避免闪烁
        settingsWindowController?.show(pane: .favorites)
        settingsWindowController?.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func openVocabulary() {
        if let existingController = settingsWindowController {
            existingController.window?.close()
            settingsWindowController = nil
        }
        
        createSettingsWindowController()
        
        if let window = settingsWindowController?.window {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: window
            )
        }
        
        // 直接显示生词本面板，避免闪烁
        settingsWindowController?.show(pane: .vocabulary)
        settingsWindowController?.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func openHistory() {
        if let existingController = settingsWindowController {
            existingController.window?.close()
            settingsWindowController = nil
        }
        
        createSettingsWindowController()
        
        if let window = settingsWindowController?.window {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: window
            )
        }
        
        // 直接显示历史记录面板，避免闪烁
        settingsWindowController?.show(pane: .history)
        settingsWindowController?.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func openPreferences() {
        if let existingController = settingsWindowController {
            existingController.window?.close()
            settingsWindowController = nil
        }
        
        createSettingsWindowController()
        
        if let window = settingsWindowController?.window {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(settingsWindowWillClose),
                name: NSWindow.willCloseNotification,
                object: window
            )
        }
        
        settingsWindowController?.show()
        settingsWindowController?.window?.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)  // 确保应用获得焦点
    }
    
    // 创建设置窗口控制器
    private func createSettingsWindowController() {
        let generalIcon = IconManager.shared.getGeneralSettingsIcon() ?? NSImage()
        let aiIcon = IconManager.shared.getAiSettingsIcon() ?? NSImage()
        let aboutIcon = IconManager.shared.getAboutSettingsIcon() ?? NSImage()
        let dataIcon = IconManager.shared.getDataIcon() ?? NSImage()
        // 添加数据管理相关的图标
        let vocabularyIcon = IconManager.shared.getVocabularyIcon() ?? NSImage()
        let favoritesIcon = IconManager.shared.getFavoritesIcon() ?? NSImage()
        let historyIcon = IconManager.shared.getHistoryIcon() ?? NSImage()
        
        settingsWindowController = SettingsWindowController(
            panes: [
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.general,
                    title: NSLocalizedString("general", comment: "通用"),
                    toolbarIcon: generalIcon
                ) {
                    GeneralSettingsPane()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.ai,
                    title: NSLocalizedString("service", comment: "服务"),
                    toolbarIcon: aiIcon
                ) {
                    GeneralAiPane()
                },
                // 添加数据管理相关的窗格
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.vocabulary,
                    title: NSLocalizedString("vocabulary", comment: "生词本"),
                    toolbarIcon: vocabularyIcon
                ) {
                    VocabularyView()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.favorites,
                    title: NSLocalizedString("favorites", comment: "收藏夹"),
                    toolbarIcon: favoritesIcon
                ) {
                    FavoriteView()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.history,
                    title: NSLocalizedString("history", comment: "历史记录"),
                    toolbarIcon: historyIcon
                ) {
                    HistoryView()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.data,
                    title: NSLocalizedString("data_management", comment: "数据"),
                    toolbarIcon: dataIcon
                ) {
                    DataManagementPane()
                },
                Settings.Pane(
                    identifier: Settings.PaneIdentifier.about,
                    title: NSLocalizedString("about", comment: "关于"),
                    toolbarIcon: aboutIcon
                ) {
                    AboutPane()
                }
            ]
        )
        // 配置窗口支持最小化到dock栏
        if let window = self.settingsWindowController?.window {
            window.styleMask.insert([.miniaturizable, .resizable])
        }
    }
    
    @objc private func settingsWindowWillClose(_ notification: Notification) {
        NotificationCenter.default.removeObserver(
            self,
            name: NSWindow.willCloseNotification,
            object: notification.object
        )
        settingsWindowController = nil
    }
    
    // MARK: - Accessibility and Clipboard Methods
    func checkAccessibilityPermissionAndGetClipboard(action: ActionType = .nothing, completion: @escaping (Bool) -> Void) {
        // 检查辅助功能权限
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        let options = [checkOptPrompt: false]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if accessEnabled {
            // 如果有权限，尝试获取剪贴板内容
            getClipboardContent(action: action) { _ in
                completion(true)
            }
        } else {
            // 使用统一的权限请求窗口
            showAccessibilityWindow()
            completion(false)
        }
    }
    
    // 截图和 OCR
    private func performScreenshotAndOCR(completion: @escaping (Bool) -> Void) {
        // 创建临时文件路径
        let tempDirectory = NSTemporaryDirectory()
        let screenshotPath = tempDirectory + "screenshot_\(Date().timeIntervalSince1970).png"
        
        // 使用 NSTask 调用系统截图命令
        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", "-r", screenshotPath]  // -i 交互式选择区域，-r 不显示鼠标指针
        
        task.terminationHandler = { [weak self] process in
            DispatchQueue.main.async {
                if process.terminationStatus == 0 {
                    // 截图成功，使用专门的中文OCR识别
                    self?.performChineseOCROnImage(at: screenshotPath) { success in
                        // 删除临时文件
                        try? FileManager.default.removeItem(atPath: screenshotPath)
                        completion(success)
                    }
                } else {
                    // 截图失败或用户取消
                    completion(false)
                }
            }
        }
        
        task.launch()
    }
    
    // OCR 文字识别功能
    private func performChineseOCROnImage(at imagePath: String, completion: @escaping (Bool) -> Void) {
        guard let image = NSImage(contentsOfFile: imagePath),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            completion(false)
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            // 提取识别到的文字
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let recognizedText = recognizedStrings.joined(separator: "\n")
            
            DispatchQueue.main.async {
                if !recognizedText.isEmpty {
                    // 将识别的文字填充到主窗口并触发翻译
                    guard let mainViewController = self?.mainWindow?.contentViewController as? NSHostingController<MainView> else {
                        completion(false)
                        return
                    }
                    
                    let mainView = mainViewController.rootView
                    mainView.fillText(recognizedText)
                    
                    // 延迟一下确保文字已填充，然后触发翻译
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        mainView.translateText()
                    }
                    
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        // 按照常用语言配置OCR识别语言优先级
        let preferredLanguage = PreferencesModel.shared.preferredLanguage
        switch preferredLanguage {
        case "zh-Hans":
            request.recognitionLanguages = ["zh-Hans", "en"]
        case "zh-Hant":
            request.recognitionLanguages = ["zh-Hant", "en"]
        case "ja":
            request.recognitionLanguages = ["ja", "en"]
        case "ko":
            request.recognitionLanguages = ["ko", "en"]
        case "fr":
            request.recognitionLanguages = ["fr", "en"]
        case "de":
            request.recognitionLanguages = ["de", "en"]
        case "es":
            request.recognitionLanguages = ["es", "en"]
        case "id":
            request.recognitionLanguages = ["id", "en"]
        case "pt-PT":
            request.recognitionLanguages = ["pt-PT", "en"]
        case "ru":
            request.recognitionLanguages = ["ru", "en"]
        case "it":
            request.recognitionLanguages = ["it", "en"]
        case "th":
            request.recognitionLanguages = ["th", "en"]
        case "vi":
            request.recognitionLanguages = ["vi", "en"]
        case "ar":
            request.recognitionLanguages = ["ar", "en"]
        default:
            request.recognitionLanguages = ["zh-Hans", "en"]
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        // 使用最新的 revision 以获得更好的准确性
        request.revision = VNRecognizeTextRequestRevision3
        // 执行 OCR 请求
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    // 获取剪贴板内容
    private func getClipboardContent(action: ActionType, completion: @escaping (Bool) -> Void) {
        // 保存当前剪贴板内容
        let pasteboard = NSPasteboard.general
        let originalContent = pasteboard.string(forType: .string)
        
        // 使用模拟复制功能获取选中文本
        simulateCopy()
        
        // 给系统一点时间处理复制操作，然后读取剪贴板
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            guard let mainViewController = self.mainWindow?.contentViewController as? NSHostingController<MainView> else {
                if let originalContent = originalContent {
                    self.copyToClipBoard(textToCopy: originalContent)
                }
                completion(false)
                return
            }
            
            let mainView = mainViewController.rootView
            let newContent = pasteboard.string(forType: .string)
            var success = false
            
            // 如果有新内容，且与原内容不同
            if let newContent = newContent, !newContent.isEmpty, newContent != originalContent {
                mainView.fillText(newContent)
                
                // 添加延迟以确保文本已填充
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 根据 action 调用不同的方法
                    switch action {
                    case .translate:
                        mainView.translateText()
                    case .summarize:
                        mainView.summaryText()
                    case .dictionary:
                        mainView.dictionaryText()
                    case .chat:
                        mainView.chatText()
                    case .nothing:
                        mainView.noactionText()
                    case .screenshotTranslate:
                        // 截图翻译在 performScreenshotAndOCR 中处理
                        break
                    }
                }
                success = true
            }
            
            // 恢复原始剪贴板内容
            if let originalContent = originalContent {
                self.copyToClipBoard(textToCopy: originalContent)
            }
            
            completion(success)
        }
    }
    
    // 模拟复制操作
    private func simulateCopy() {
        // 模拟 Command+C 复制操作
        let source = CGEventSource(stateID: .combinedSessionState)
        
        guard let eventSource = source else {
            print("无法创建事件源")
            return
        }
        
        // 按下 Command+C
        guard let keyDownC = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x08, keyDown: true) else {
            print("无法创建按键事件")
            return
        }
        keyDownC.flags = .maskCommand
        
        // 释放 Command+C
        guard let keyUpC = CGEvent(keyboardEventSource: eventSource, virtualKey: 0x08, keyDown: false) else {
            print("无法创建释放事件")
            return
        }
        keyUpC.flags = .maskCommand
        
        // 发送事件
        keyDownC.post(tap: .cgAnnotatedSessionEventTap)
        usleep(10000)  // 10毫秒延迟
        keyUpC.post(tap: .cgAnnotatedSessionEventTap)
    }
    
    private func copyToClipBoard(textToCopy: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(textToCopy, forType: .string)
    }
    
    /// 获取主视图的辅助方法
    private func getMainView() -> MainView? {
        guard let hostingController = mainWindow?.contentViewController as? NSHostingController<MainView> else {
            return nil
        }
        return hostingController.rootView
    }
    
    /// 重置输入和输出窗口内容（快捷键专用）
    func resetInputOutput() {
        DispatchQueue.main.async {
            if let mainView = self.getMainView() {
                mainView.clearAll()
            }
        }
    }
    
    /// 复制输出内容到剪贴板（快捷键专用）
    func copyOutputToClipboard() {
        DispatchQueue.main.async {
            let contentModel = TextContentModel.shared
            if let promptText = contentModel.resultText, !promptText.isEmpty {
                let pasteboard = NSPasteboard.general
                pasteboard.clearContents()
                pasteboard.setString(promptText, forType: .string)
                
                // 通过通知中心通知MainView显示成功吐司提示
                NotificationCenter.default.post(name: NSNotification.Name("ShowCopySuccessToast"), object: nil)
            } else {
                // 通过通知中心通知MainView显示错误吐司提示
                NotificationCenter.default.post(name: NSNotification.Name("ShowCopyErrorToast"), object: nil)
            }
        }
    }
    
    // MARK: - Pin Functionality
    @objc private func pinButtonTapped() {
        isMainWindowPinned.toggle()
        updatePinState()
    }
    
    @objc private func historyButtonTapped() {
        openHistory()
    }
    
    @objc private func favoritesButtonTapped() {
        openFavorites()
    }
    
    private func updatePinState() {
        guard let window = mainWindow else { return }
        
        if isMainWindowPinned {
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary, .ignoresCycle]
            pinnedWindowOrigin = window.frame.origin
            
            pinButton?.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: NSLocalizedString("help_unpin", comment: "取消置顶"))
            pinButton?.contentTintColor = .red
            pinButton?.toolTip = NSLocalizedString("help_unpin", comment: "取消置顶")
        } else {
            window.level = .normal
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .fullScreenPrimary]
            pinnedWindowOrigin = nil
            
            pinButton?.image = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: NSLocalizedString("help_pin", comment: "置顶窗口"))
            pinButton?.contentTintColor = nil
            pinButton?.toolTip = NSLocalizedString("help_pin", comment: "置顶窗口")
            
            if !window.isKeyWindow {
                window.close()
            }
        }
    }
    
    // MARK: - NSWindowDelegate
    func windowDidMove(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow, isMainWindowPinned {
            self.pinnedWindowOrigin = window.frame.origin
        }
    }
    
    func windowDidResignKey(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == mainWindow {
            if !isMainWindowPinned {
                window.close()
            }
        }
    }
}
