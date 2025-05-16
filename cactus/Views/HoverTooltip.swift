import SwiftUI

// 理悬浮提示
struct HoverTooltipModifier: ViewModifier {
    let tooltipText: String // 提示文本
    @State private var isHovering = false
    
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
                            .fixedSize(horizontal: true, vertical: false) // <--- 新增：确保宽度根据内容自适应，并保持单行
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)) // 调整内边距
                            .background(
                                RoundedRectangle(cornerRadius: 8) // 使用圆角矩形背景
                                    .fill(Color.black.opacity(0.85)) // 背景颜色和透明度
                                    .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2) // 添加阴影
                            )
                            .foregroundColor(Color(white: 0.85)) // 文本颜色，降低亮度
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
