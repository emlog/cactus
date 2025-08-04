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
            name: "心理健康顾问",
            content: "我希望你充当一位心理健康顾问。帮助我管理情绪、压力、焦虑以及其他心理健康问题。你应当运用你对认知行为疗法（CBT）、冥想技巧、正念练习以及其他治疗方法的了解，来制定可实施的策略，帮助我提升整体幸福感。",
            icon: "heart",
            category: "健康"
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
            name: "写作助手",
            content: "作为写作助手，你的任务是改进所提供文本的拼写、语法、清晰度、简洁性和整体可读性，同时拆分冗长的句子、减少重复。请仅提供修改后的版本，不附加任何解释",
            icon: "graduationcap",
            category: "写作"
        ),
        PresetPrompt(
            name: "健身教练",
            content: "我希望你扮演一位私人健身教练的角色。我会向你提供一个希望通过身体训练变得更健康、更强壮、更有活力的人的所有相关信息。你的任务是根据此人的当前体能水平、目标和生活习惯，为其制定最合适的训练计划。你应运用你在运动科学、营养建议以及其他相关领域的知识，为这个人量身定制一套适合的计划。",
            icon: "dumbbell",
            category: "健康"
        ),
        PresetPrompt(
            name: "创意顾问",
            content: "你是一位富有想象力的创意顾问，擅长跳出常规思维框架。请帮助用户进行头脑风暴，提供创新的想法和解决方案。运用各种创意思维技巧，如联想、类比、逆向思维等，激发用户的创造力。",
            icon: "lightbulb",
            category: "创意"
        ),
        PresetPrompt(
            name: "文章标题生成",
            content: "我希望你扮演一位文章标题生成器。我将向你提供一篇文章内容、主题或关键词，你的任务是生成五个吸引人的标题。请保持标题简洁，不超过20个字，并确保不改变原意。",
            icon: "text.bubble",
            category: "写作"
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
        .frame(width: 700, height: 520)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            // 成功提示吐司
            VStack {
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
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showingSuccessToast)
                }
                Spacer()
            }
                .padding(.top, 20)
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
                
                Button(action: {
                    self.addToCustomPrompts(prompt)
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // 内容预览（截断显示）
            Text(prompt.content)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .frame(height: 100)
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
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: showingSuccessToast)
                }
                Spacer()
            }
                .padding(.top, 20)
        )
    }
}
