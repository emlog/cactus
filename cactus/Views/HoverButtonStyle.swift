import SwiftUI

// 自定义按钮样式，实现悬停效果
struct HoverButtonStyle: ButtonStyle {
    @State private var isHovering = false // 跟踪悬停状态

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8) // 左右内边距
            .padding(.vertical, 4)   // 上下内边距
            .background(isHovering ? Color.gray.opacity(0.2) : Color.clear) // 悬停时背景变灰
            .clipShape(RoundedRectangle(cornerRadius: 4)) // 圆角
            .contentShape(Rectangle()) // 确保整个区域都响应悬停
            .onHover { hovering in
                isHovering = hovering
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0) // 按下时缩小效果
            .animation(.easeInOut(duration: 0.1), value: isHovering) // 添加动画
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed) // 按下动画
    }
}