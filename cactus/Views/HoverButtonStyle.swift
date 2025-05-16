import SwiftUI

// 主按钮样式 - 翻译、总结、解释、对话按钮
struct HoverButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) var isEnabled // 获取按钮的启用状态
    @State private var isHovering = false // 跟踪悬停状态

    // 自定义内边距属性
    var horizontalPadding: CGFloat = 4
    var verticalPadding: CGFloat = 4
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, horizontalPadding) // 使用自定义水平内边距
            .padding(.vertical, verticalPadding)   // 使用自定义垂直内边距
            .background(backgroundView(configuration: configuration)) // 使用新的背景视图逻辑
            .clipShape(RoundedRectangle(cornerRadius: 4)) // 圆角
            .contentShape(Rectangle()) // 确保整个区域都响应悬停
            .onHover { hovering in
                if isEnabled { // 仅在启用时响应悬停
                    isHovering = hovering
                }
            }
            .scaleEffect(isEnabled && configuration.isPressed ? 0.95 : 1.0) // 仅在启用时响应按下缩小效果
            .opacity(isEnabled ? 1.0 : 0.5) // 禁用时降低透明度
            .animation(.easeInOut(duration: 0.1), value: isHovering) // 添加动画
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) // 按下动画
            .animation(.easeInOut(duration: 0.1), value: isEnabled) // 启用/禁用状态变化动画
    }
    
    // 辅助方法来决定背景颜色
    @ViewBuilder
    private func backgroundView(configuration: Configuration) -> some View {
        if !isEnabled {
            Color.gray.opacity(0.1) // 禁用时的背景色
        } else if isHovering {
            Color.gray.opacity(0.2) // 悬停时背景变灰
        } else {
            Color.clear // 默认背景
        }
    }
}
