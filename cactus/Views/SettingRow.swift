import SwiftUI

// 自定义设置行组件
struct SettingRow<Content: View>: View {
    let label: String
    let description: String?
    let content: Content
    
    init(label: String, description: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // 左对齐的标签
                Text(label)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 右对齐的设置内容
                content
                    .frame(alignment: .trailing)
            }
            
            // 描述文字（如果有的话）
            if let description = description {
                HStack {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
            }
        }
    }
}
