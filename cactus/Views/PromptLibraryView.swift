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
            name: NSLocalizedString("preset_prompt_psychologist_name", comment: "心理健康顾问"),
            content: NSLocalizedString("preset_prompt_psychologist_content", comment: "心理健康顾问提示词内容"),
            icon: "heart",
            category: NSLocalizedString("category_health", comment: "健康")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_code_reviewer_name", comment: "代码审查员"),
            content: NSLocalizedString("preset_prompt_code_reviewer_content", comment: "代码审查员提示词内容"),
            icon: "doc.text.magnifyingglass",
            category: NSLocalizedString("category_programming", comment: "编程")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_copywriter_name", comment: "文案创作师"),
            content: NSLocalizedString("preset_prompt_copywriter_content", comment: "文案创作师提示词内容"),
            icon: "pencil.and.outline",
            category: NSLocalizedString("category_writing", comment: "写作")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_writing_assistant_name", comment: "写作助手"),
            content: NSLocalizedString("preset_prompt_writing_assistant_content", comment: "写作助手提示词内容"),
            icon: "graduationcap",
            category: NSLocalizedString("category_writing", comment: "写作")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_fitness_trainer_name", comment: "健身教练"),
            content: NSLocalizedString("preset_prompt_fitness_trainer_content", comment: "健身教练提示词内容"),
            icon: "dumbbell",
            category: NSLocalizedString("category_health", comment: "健康")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_creative_consultant_name", comment: "创意顾问"),
            content: NSLocalizedString("preset_prompt_creative_consultant_content", comment: "创意顾问提示词内容"),
            icon: "lightbulb",
            category: NSLocalizedString("category_creative", comment: "创意")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_title_generator_name", comment: "文章标题生成"),
            content: NSLocalizedString("preset_prompt_title_generator_content", comment: "文章标题生成提示词内容"),
            icon: "text.bubble",
            category: NSLocalizedString("category_writing", comment: "写作")
        ),
        PresetPrompt(
            name: NSLocalizedString("preset_prompt_product_manager_name", comment: "产品经理"),
            content: NSLocalizedString("preset_prompt_product_manager_content", comment: "产品经理提示词内容"),
            icon: "cube.box",
            category: NSLocalizedString("category_product", comment: "产品")
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
                        Text(NSLocalizedString("add_ok", comment: "添加成功"))
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
            Text(NSLocalizedString("prompt_lib", comment: "提示词库"))
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
    }
}
