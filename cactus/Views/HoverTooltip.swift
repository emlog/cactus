import SwiftUI

// 鼠标悬浮提示
struct HoverTooltipModifier: ViewModifier {
    let tooltipText: String // 提示文本
    let delay: TimeInterval // 延迟时间，单位秒
    @State private var isHovering = false
    @State private var workItem: DispatchWorkItem? // 用于管理延迟任务
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                self.workItem?.cancel() // 先取消之前的任务
                
                if hovering {
                    if delay > 0 {
                        let task = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isHovering = true
                            }
                        }
                        self.workItem = task
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
                    } else {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.isHovering = true
                        }
                    }
                } else {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.isHovering = false
                    }
                }
            }
            .overlay(
                Group {
                    if isHovering && !tooltipText.isEmpty { // 仅当悬浮且文本不为空时显示
                        Text(tooltipText)
                            .font(.body) // 可以调整字体大小
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
                            .background(
                                RoundedRectangle(cornerRadius: 8) // 使用圆角矩形背景
                                    .fill(colorScheme == .dark ? Color.black.opacity(0.85) : Color.white.opacity(0.9)) // 根据颜色方案调整背景
                                    .shadow(color: (colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.4)), radius: 5, x: 0, y: 2) // 根据颜色方案调整阴影
                            )
                            .foregroundColor(colorScheme == .dark ? Color(white: 0.75) : Color.black.opacity(0.8)) // 根据颜色方案调整文本颜色
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
    func hoverTooltip(_ text: String, delay: TimeInterval = 0.0) -> some View { // 增加 delay 参数，默认0， 单位秒
        self.modifier(HoverTooltipModifier(tooltipText: text, delay: delay))
    }
}
