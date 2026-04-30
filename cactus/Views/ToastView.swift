import SwiftUI

/// 自定义吐司提示组件
struct ToastView: View {
    let message: String
    let type: ToastType
    let isShowing: Bool
    
    /// 吐司类型枚举
    enum ToastType {
        case success
        case error
        case info
        
        /// 获取对应的图标
        var icon: String {
            switch self {
            case .success:
                return "checkmark.circle.fill"
            case .error:
                return "xmark.circle.fill"
            case .info:
                return "info.circle.fill"
            }
        }
        
        /// 获取对应的颜色
        var color: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            case .info:
                return .accentColor
            }
        }
    }
    
    var body: some View {
        if isShowing {
            HStack(spacing: 8) {
                Image(systemName: type.icon)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .transition(
                .asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                )
            )
            .animation(.easeInOut(duration: 0.3), value: isShowing)
        }
    }
}

/// 吐司提示管理器
class ToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    @Published var type: ToastView.ToastType = .success
    
    private var hideTimer: Timer?
    
    /// 单例实例，确保在整个应用中只有一个 ToastManager 实例
    static let shared = ToastManager()
    
    /// 私有初始化方法，防止外部创建多个实例
    private init() {}
    
    /// 显示成功提示
    /// - Parameter message: 提示消息
    func showSuccess(_ message: String) {
        show(message: message, type: .success)
    }
    
    /// 显示错误提示
    /// - Parameter message: 提示消息
    func showError(_ message: String) {
        show(message: message, type: .error)
    }
    
    /// 显示信息提示
    /// - Parameter message: 提示消息
    func showInfo(_ message: String) {
        show(message: message, type: .info)
    }
    
    /// 显示提示
    /// - Parameters:
    ///   - message: 提示消息
    ///   - type: 提示类型
    ///   - duration: 显示时长（秒），默认2秒
    private func show(message: String, type: ToastView.ToastType, duration: TimeInterval = 2.0) {
        // 取消之前的定时器
        hideTimer?.invalidate()
        
        // 如果当前已经有吐司显示，先隐藏它
        if isShowing {
            withAnimation(.easeOut(duration: 0.2)) {
                self.isShowing = false
            }
            
            // 延迟显示新的吐司，确保旧的完全消失
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showNewToast(message: message, type: type, duration: duration)
            }
        } else {
            showNewToast(message: message, type: type, duration: duration)
        }
    }
    
    /// 显示新的吐司提示
    /// - Parameters:
    ///   - message: 提示消息
    ///   - type: 提示类型
    ///   - duration: 显示时长
    private func showNewToast(message: String, type: ToastView.ToastType, duration: TimeInterval) {
        // 更新状态
        self.message = message
        self.type = type
        
        withAnimation(.easeInOut(duration: 0.3)) {
            self.isShowing = true
        }
        
        // 设置自动隐藏定时器
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                self.isShowing = false
            }
        }
    }
    
    /// 手动隐藏提示
    func hide() {
        hideTimer?.invalidate()
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
    }
}

/// 吐司提示修饰符
struct ToastModifier: ViewModifier {
    @ObservedObject var toastManager: ToastManager
    
    /// 构建带吐司提示的视图层，并确保不拦截底层交互事件
    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    ToastView(
                        message: toastManager.message,
                        type: toastManager.type,
                        isShowing: toastManager.isShowing
                    )
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .allowsHitTesting(false)
            )
    }
}

/// View 扩展，方便使用吐司提示
extension View {
    /// 添加吐司提示功能
    /// - Parameter toastManager: 吐司管理器
    /// - Returns: 带有吐司提示功能的视图
    func toast(_ toastManager: ToastManager) -> some View {
        self.modifier(ToastModifier(toastManager: toastManager))
    }
}
