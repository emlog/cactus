import SwiftUI

// 鼠标悬浮提示（使用 popover 实现，避免被裁剪）
struct HoverTooltipModifier: ViewModifier {
    let tooltipText: String
    let delay: TimeInterval
    @State private var isHovering = false
    @State private var showPopover = false
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .onHover { hovering in
                self.workItem?.cancel()
                
                if hovering {
                    if delay > 0 {
                        let task = DispatchWorkItem {
                            withAnimation {
                                self.showPopover = true
                            }
                        }
                        self.workItem = task
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: task)
                    } else {
                        withAnimation {
                            self.showPopover = true
                        }
                    }
                } else {
                    withAnimation {
                        self.showPopover = false
                    }
                }
            }
            .popover(isPresented: $showPopover, arrowEdge: .bottom) {
                TooltipContentView(text: tooltipText)
            }
    }
}

// 提示内容视图，可以根据需要自定义样式
struct TooltipContentView: View {
    let text: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text(text)
            .font(.body)
            .fixedSize(horizontal: true, vertical: false)
            .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.9))
                    .shadow(color: (colorScheme == .dark ? Color.black.opacity(0.2) : Color.gray.opacity(0.4)), radius: 5, x: 0, y: 2)
            )
            .foregroundColor(colorScheme == .dark ? Color(white: 0.75) : Color.black.opacity(0.8))
    }
}

// 视图扩展，方便使用
extension View {
    func hoverTooltip(_ text: String, delay: TimeInterval = 0.0) -> some View {
        self.modifier(HoverTooltipModifier(tooltipText: text, delay: delay))
    }
}
