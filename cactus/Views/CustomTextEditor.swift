import SwiftUI
import AppKit

struct CustomTextEditor: NSViewRepresentable {
    @Binding var text: String
    var onCommit: () -> Void // 回车键提交时的回调
    @Binding var calculatedHeight: CGFloat // 用于传递计算出的高度
    let minHeight: CGFloat = 100 // 最小高度
    let maxHeight: CGFloat = 200 // 最大高度
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        textView.delegate = context.coordinator
        textView.font = NSFont.systemFont(ofSize: 15)
        textView.textColor = NSColor.textColor
        textView.backgroundColor = NSColor.textBackgroundColor
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false // 纯文本模式
        textView.allowsUndo = true
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.containerSize = NSSize(width: scrollView.contentSize.width, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.string = text // 初始化文本
        
        // 设置内边距和行间距
        textView.textContainerInset = NSSize(width: 5, height: 5) // 调整内边距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8 // 设置行间距
        textView.defaultParagraphStyle = paragraphStyle
        
        // 初始高度计算
        // Corrected the method call here
        context.coordinator.textDidChange(Notification(name: NSText.didChangeNotification, object: textView))
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        // 确保 NSTextView 的内容与 SwiftUI 的状态同步
        if textView.string != text {
            let selectedRange = textView.selectedRange // 保存光标位置
            textView.string = text
            textView.setSelectedRange(selectedRange) // 恢复光标位置
        }
        // 更新高度约束
        let newHeight = max(minHeight, min(calculatedHeight, maxHeight))
        if nsView.frame.height != newHeight {
            DispatchQueue.main.async { // 确保在主线程更新UI
                nsView.setFrameSize(NSSize(width: nsView.frame.width, height: newHeight))
                // 可能需要通知父视图调整布局
                NotificationCenter.default.post(name: NSNotification.Name("AdjustWindowSize"), object: nil)
            }
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CustomTextEditor
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        // 处理键盘命令
        func textView(_ textView: NSTextView, doCommandBy selector: Selector) -> Bool {
            if selector == #selector(NSResponder.insertNewline(_:)) {
                // 当接收到 insertNewline 命令时，检查 Shift 修饰键是否按下
                if NSEvent.modifierFlags.contains(.shift) {
                    // 如果 Shift + Enter，执行换行操作
                    if let textStorage = textView.textStorage {
                        let currentRange = textView.selectedRange
                        textStorage.replaceCharacters(in: currentRange, with: "\n")
                        textView.setSelectedRange(NSRange(location: currentRange.location + 1, length: 0))
                        // 手动触发文本变化通知，确保高度等更新
                        textView.didChangeText()
                        return true // 已处理为换行
                    }
                    return false // 无法处理
                } else {
                    // 如果是普通的 Enter，执行提交操作
                    parent.onCommit() // 调用提交回调
                    return true // 已处理为提交
                }
            } else if selector == #selector(NSResponder.insertLineBreak(_:)) {
                // 保留对 insertLineBreak 的显式处理作为备用，
                // 尽管 Shift+Enter 可能主要被上面的逻辑捕获
                if let textStorage = textView.textStorage {
                    let currentRange = textView.selectedRange
                    textStorage.replaceCharacters(in: currentRange, with: "\n")
                    textView.setSelectedRange(NSRange(location: currentRange.location + 1, length: 0))
                    // 手动触发文本变化通知
                    textView.didChangeText()
                    return true // 已处理为换行
                }
                return false // 无法处理
            }
            // 其他命令按默认方式处理
            return false
        }
        
        // 文本变化时更新 SwiftUI 状态和计算高度
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // 更新 SwiftUI 的 @Binding text
            // 避免在 textStorage 更新时再次设置 text，可能导致循环
            if parent.text != textView.string {
                parent.text = textView.string
            }
            // 计算并更新高度
            calculateAndUpdateHeight(textView: textView)
        }
        
        // 文本存储变化时（例如粘贴）也需要更新
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            // 在选择变化时也可能需要重新计算高度，特别是对于多行文本编辑器
            calculateAndUpdateHeight(textView: textView)
        }
        
        private func calculateAndUpdateHeight(textView: NSTextView) {
            let layoutManager = textView.layoutManager!
            let textContainer = textView.textContainer!
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            
            // 加上内边距和一些额外空间
            let newHeight = usedRect.height + (textView.textContainerInset.height * 2) + 10 // 增加一点额外空间
            
            // 更新绑定高度，限制在最小和最大值之间
            let clampedHeight = max(parent.minHeight, min(newHeight, parent.maxHeight))
            
            // 避免不必要的更新和潜在的循环
            if abs(parent.calculatedHeight - clampedHeight) > 1 { // 只有当高度变化显著时才更新
                DispatchQueue.main.async {
                    self.parent.calculatedHeight = clampedHeight
                }
            }
        }
    }
}
