import SwiftUI

// 鼠标悬浮提示
struct HoverTooltipModifier: ViewModifier {
    let tooltipText: String // 提示文本
    @State private var isHovering = false
    @Environment(\.colorScheme) var colorScheme // <--- 新增：获取颜色方案

    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) { // 添加动画效果
                    isHovering = hovering
                }
            }
            .overlay(
                Group {
                    if isHovering && !tooltipText.isEmpty { // 仅当悬浮且文本不为空时显示
                        Text(tooltipText)
                            .font(.body) // 可以调整字体大小
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)) // 调整内边距
                            .background(
                                RoundedRectangle(cornerRadius: 8) // 使用圆角矩形背景
                                    .fill(colorScheme == .dark ? Color.black.opacity(0.85) : Color.white.opacity(0.9)) // <--- 修改：根据颜色方案调整背景
                                    .shadow(color: (colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.4)), radius: 5, x: 0, y: 2) // <--- 修改：根据颜色方案调整阴影
                            )
                            .foregroundColor(colorScheme == .dark ? Color(white: 0.75) : Color.black.opacity(0.8)) // <--- 修改：根据颜色方案调整文本颜色
                            .offset(y: -35) // 向上偏移量，可以根据需要调整
                            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .bottom))) // 更平滑的过渡动画
                            .zIndex(1) // 确保提示在最上层
                    }
                },
                alignment: .bottom // 将提示锚定在视图底部，然后通过 offset 调整
            )
    }
}

// 扩展 View 以方便使用
extension View {
    func hoverTooltip(_ text: String) -> some View {
        self.modifier(HoverTooltipModifier(tooltipText: text))
    }
}
