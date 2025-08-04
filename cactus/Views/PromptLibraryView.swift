import SwiftUI
import Foundation

/// 预设提示词数据结构
struct PresetPrompt: Identifiable {
    var id = UUID()
    var name: String
    var content: String
    var icon: String
    var category: String
}

/// 提示词库窗口视图
struct PromptLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 添加提示词的回调
    var onAddPrompt: ((String, String) -> Void)?
    
    @State private var selectedPrompt: PresetPrompt?
    @State private var showingPromptDetail = false
    @State private var showingSuccessToast = false
    
    /// 预设提示词库
    private let presetPrompts: [PresetPrompt] = [
        PresetPrompt(
            name: "翻译专家",
            content: "你是一位专业的翻译专家，精通多种语言。请将用户输入的文本翻译成目标语言，保持原文的语调、风格和含义。如果遇到专业术语或文化特定的表达，请提供最合适的翻译并在必要时给出简短解释。",
            icon: "globe",
            category: "翻译"
        ),
        PresetPrompt(
            name: "代码审查员",
            content: "你是一位经验丰富的代码审查员。请仔细分析用户提供的代码，从以下几个方面给出专业建议：1. 代码质量和可读性 2. 性能优化建议 3. 安全性问题 4. 最佳实践建议 5. 潜在的bug或问题。请提供具体的改进建议和示例代码。",
            icon: "doc.text.magnifyingglass",
            category: "编程"
        ),
        PresetPrompt(
            name: "文案创作师",
            content: "你是一位富有创意的文案创作师，擅长各种类型的文案写作。请根据用户的需求创作吸引人的文案，包括但不限于：广告文案、社交媒体内容、产品描述、邮件营销文案等。注重文案的吸引力、说服力和品牌调性。",
            icon: "pencil.and.outline",
            category: "写作"
        ),
        PresetPrompt(
            name: "学习导师",
            content: "你是一位耐心且知识渊博的学习导师。请用通俗易懂的方式解答用户的问题，提供清晰的解释和实用的学习建议。根据用户的学习水平调整解释的深度，并在适当时候提供相关的学习资源或练习建议。",
            icon: "graduationcap",
            category: "教育"
        ),
        PresetPrompt(
            name: "数据分析师",
            content: "你是一位专业的数据分析师，擅长从数据中发现有价值的洞察。请帮助用户分析数据，提供清晰的数据解读、趋势分析和actionable insights。使用图表、统计方法和可视化建议来支持你的分析结论。",
            icon: "chart.bar.xaxis",
            category: "分析"
        ),
        PresetPrompt(
            name: "创意顾问",
            content: "你是一位富有想象力的创意顾问，擅长跳出常规思维框架。请帮助用户进行头脑风暴，提供创新的想法和解决方案。运用各种创意思维技巧，如联想、类比、逆向思维等，激发用户的创造力。",
            icon: "lightbulb",
            category: "创意"
        ),
        PresetPrompt(
            name: "技术文档专家",
            content: "你是一位专业的技术文档专家，擅长编写清晰、准确的技术文档。请帮助用户创建或改进技术文档，包括API文档、用户手册、开发指南等。注重文档的结构性、可读性和实用性，提供具体的示例和最佳实践。",
            icon: "doc.text",
            category: "技术"
        ),
        PresetPrompt(
            name: "产品经理",
            content: "你是一位经验丰富的产品经理，具备敏锐的市场洞察力和用户思维。请帮助用户分析产品需求、制定产品策略、优化用户体验。从用户价值、商业价值和技术可行性三个维度来评估和建议产品方案。",
            icon: "cube.box",
            category: "产品"
        )
    ]
    
    /// 提示词列表
    private var filteredPrompts: [PresetPrompt] {
        return presetPrompts
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            headerView
            // 提示词列表
            promptListView
        }
        .frame(width: 700, height: 700)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            // 成功提示吐司
            VStack {
                Spacer()
                if showingSuccessToast {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("已成功添加到自定义提示词")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showingSuccessToast)
                }
            }
                .padding(.bottom, 20)
        )
        .sheet(item: $selectedPrompt) { prompt in
            PromptDetailView(prompt: prompt, onAddPrompt: onAddPrompt)
        }
    }
    
    /// 标题栏视图
    private var headerView: some View {
        HStack {
            Text("提示词库")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    /// 提示词列表视图
    private var promptListView: some View {
        ScrollView {
            if filteredPrompts.isEmpty {
                emptyStateView
            } else {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(filteredPrompts) { prompt in
                        promptCard(prompt: prompt)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .padding(.vertical, 10)
    }
    
    /// 空状态视图
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("未找到相关提示词")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    /// 提示词卡片
    private func promptCard(prompt: PresetPrompt) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图标和标题
            HStack(spacing: 10) {
                Image(systemName: prompt.icon)
                    .font(.system(size: 16))
                    .foregroundColor(.accentColor)
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(prompt.name)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(prompt.category)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 1)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(3)
                }
                
                Spacer()
            }
            
            // 内容预览（截断显示）
            Text(prompt.content)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // 操作按钮
            HStack(spacing: 6) {
                Spacer()
                
                Button(action: {
                    self.addToCustomPrompts(prompt)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .frame(height: 120)
        .onTapGesture {
            selectedPrompt = prompt
            showingPromptDetail = true
        }
        .onHover { isHovering in
            if isHovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
    
    /// 添加到自定义提示词并显示成功提示
    private func addToCustomPrompts(_ prompt: PresetPrompt) {
        onAddPrompt?(prompt.name, prompt.content)
        
        // 显示成功提示
        withAnimation(.easeInOut(duration: 0.3)) {
            showingSuccessToast = true
        }
        
        // 2秒后隐藏提示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingSuccessToast = false
            }
        }
    }
}

/// 提示词详情视图
struct PromptDetailView: View {
    let prompt: PresetPrompt
    var onAddPrompt: ((String, String) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showingSuccessToast = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Image(systemName: prompt.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(prompt.category)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color(NSColor.controlBackgroundColor))
            
            // 内容区域
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(prompt.content)
                            .font(.body)
                            .textSelection(.enabled)
                            .padding(12)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 16)
            }
        }
        .frame(width: 500, height: 300)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            VStack {
                Spacer()
                if showingSuccessToast {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("已成功添加到自定义提示词")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showingSuccessToast)
                }
            }
                .padding(.bottom, 20)
        )
    }
}
