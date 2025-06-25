//
//  HistoryView.swift
//  cactus
//
//  历史记录
//  Created by 许大伟 on 2025/2/21.
//

import SwiftUI
import CoreData
import MarkdownUI

struct HistoryView: View {
    @StateObject private var historyManager = HistoryManager.shared
    @StateObject private var favoriteManager = FavoriteManager.shared
    @State private var selectedHistory: HistoryEntry?
    @FocusState private var isViewFocused: Bool
    
    // 复制成功状态，用于按钮图标动画
    @State private var showInputCopySuccess = false
    @State private var showOutputCopySuccess = false
    
    // 添加清空确认对话框状态
    @State private var showClearAllConfirmation = false
    
    var body: some View {
        HSplitView {
            // 左侧历史记录列表 - 占比约30%
            VStack(spacing: 0) {
                if historyManager.historyEntries.isEmpty {
                    VStack {
                        Spacer()
                    }
                } else {
                    List(historyManager.historyEntries, id: \.objectID) { historyEntry in
                        VStack(alignment: .leading, spacing: 0) {
                            Text(getPreviewText(historyEntry.inputContent ?? ""))
                                .font(.system(size: 14, weight: .medium))
                                .lineSpacing(4)
                                .lineLimit(2)
                            
                            Text(formatDate(historyEntry.timestamp))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(selectedHistory?.objectID == historyEntry.objectID
                                      ? Color.accentColor.opacity(0.2)
                                      : Color.clear)
                                .padding(.vertical, 0)
                        )
                        .onTapGesture {
                            selectedHistory = historyEntry
                        }
                        .contextMenu {
                            Button(action: {
                                deleteSelectedHistory(historyEntry)
                            }) {
                                Label(NSLocalizedString("delete", comment: "删除"), systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // 底部显示总历史记录数量
                HStack {
                    Text(NSLocalizedString("sum", comment: "共计") + "： \(historyManager.historyEntries.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    Spacer()
                    
                    // 清空全部按钮 - 添加二次确认
                    if !historyManager.historyEntries.isEmpty {
                        Button(NSLocalizedString("clear_all", comment: "清空全部")) {
                            showClearAllConfirmation = true
                        }
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .alert(NSLocalizedString("clear_all_history_message", comment: "确定要清空所有历史记录吗？"), isPresented: $showClearAllConfirmation) {
                            Button(NSLocalizedString("cancle", comment: "取消"), role: .cancel) { }
                            Button(NSLocalizedString("confirm", comment: "确定"), role: .destructive) {
                                historyManager.clearAllHistory()
                                selectedHistory = nil
                            }
                        }
                    }
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 120, idealWidth: 120, maxWidth: 190)
            
            // 右侧历史记录详情 - 占比约70%
            VStack(spacing: 0) {
                if let selectedHistory = selectedHistory {
                    VStack(spacing: 12) {
                        // 输入内容区域
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                ScrollView {
                                    Text(selectedHistory.inputContent ?? "")
                                        .font(.system(size: 15))
                                        .lineSpacing(8)
                                        .textSelection(.enabled)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.bottom, 40) // 增加底部内边距，确保文本不被按钮遮挡
                                        .padding(.horizontal, 12)
                                        .padding(.top, 12)
                                }
                                .background(Color(.textBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.separatorColor), lineWidth: 1)
                                )
                                .frame(maxHeight: 160)
                                
                                // 输入内容操作按钮
                                HStack(spacing: 8) {
                                    Button(action: {
                                        copyToClipboard(selectedHistory.inputContent ?? "")
                                        // 触发成功动画
                                        withAnimation {
                                            showInputCopySuccess = true
                                        }
                                        // 1.5秒后恢复图标
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            withAnimation {
                                                showInputCopySuccess = false
                                            }
                                        }
                                    }) {
                                        Image(systemName: showInputCopySuccess ? "checkmark" : "square.on.square")
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(showInputCopySuccess ? .green : .secondary)
                                    }
                                    .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                                    .animation(.easeInOut, value: showInputCopySuccess)
                                    
                                    // 收藏按钮
                                    Button(action: {
                                        toggleFavorite(selectedHistory)
                                    }) {
                                        Image(systemName: isFavorited(selectedHistory) ? "heart.fill" : "heart")
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(isFavorited(selectedHistory) ? .red : .secondary)
                                    }
                                    .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                                    .animation(.easeInOut, value: isFavorited(selectedHistory))
                                    
                                    // 删除按钮
                                    Button(action: {
                                        deleteSelectedHistory(selectedHistory)
                                    }) {
                                        Image(systemName: "trash")
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(HoverButtonStyle(horizontalPadding: 4, verticalPadding: 4))
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.textBackgroundColor).opacity(1.0))
                                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                )
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                            }
                        }
                        
                        // 输出内容区域
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                ScrollView {
                                    Markdown(selectedHistory.outputContent ?? "")
                                        .markdownTheme(.cactusMD)
                                        .textSelection(.enabled)
                                        .padding(.horizontal, 12)
                                        .padding(.top, 10)
                                        .padding(.bottom, 30) // 增加底部内边距，为按钮留出空间
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                                .background(Color(.textBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color(.separatorColor), lineWidth: 1)
                                )
                                
                                // 输出内容操作按钮
                                HStack(spacing: 8) {
                                    Button(action: {
                                        copyToClipboard(selectedHistory.outputContent ?? "")
                                        // 触发成功动画
                                        withAnimation {
                                            showOutputCopySuccess = true
                                        }
                                        // 1.5秒后恢复图标
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            withAnimation {
                                                showOutputCopySuccess = false
                                            }
                                        }
                                    }) {
                                        Image(systemName: showOutputCopySuccess ? "checkmark" : "square.on.square")
                                            .frame(width: 15, height: 15)
                                            .foregroundColor(showOutputCopySuccess ? .green : .secondary)
                                    }
                                    .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                                    .animation(.easeInOut, value: showOutputCopySuccess)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color(.textBackgroundColor).opacity(1.0))
                                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                )
                                .padding(.horizontal, 15)
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding()
                    
                } else {
                    // 空状态
                    VStack {
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .background(
                Color(NSColor.controlBackgroundColor).opacity(0.1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .frame(minWidth: 800, minHeight: 600)
        .focusable()
        .focused($isViewFocused)
        .overlay(
            // 隐藏的按钮用于键盘快捷键
            VStack {
                Button("Previous") {
                    selectPreviousHistory()
                }
                .keyboardShortcut(.upArrow, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
                
                Button("Next") {
                    selectNextHistory()
                }
                .keyboardShortcut(.downArrow, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
                
                Button("Delete") {
                    deleteCurrentHistory()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
            }
        )
        .onAppear {
            historyManager.fetchHistoryEntries()
            // 默认选择第一个历史记录
            if selectedHistory == nil && !historyManager.historyEntries.isEmpty {
                selectedHistory = historyManager.historyEntries.first
            }
            // 设置焦点以接收键盘事件
            isViewFocused = true
        }
    }
    
    // 获取预览文本（前50个字符）
    private func getPreviewText(_ text: String) -> String {
        if text.count > 50 {
            return String(text.prefix(50)) + "..."
        }
        return text
    }
    
    // 复制到剪贴板
    private func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
    }
    
    // 选择上一个历史记录
    private func selectPreviousHistory() {
        guard !historyManager.historyEntries.isEmpty else { return }
        
        guard let currentHistory = selectedHistory,
              let currentIndex = historyManager.historyEntries.firstIndex(of: currentHistory) else {
            selectedHistory = historyManager.historyEntries.last
            return
        }
        
        if currentIndex > 0 {
            selectedHistory = historyManager.historyEntries[currentIndex - 1]
        } else {
            selectedHistory = historyManager.historyEntries.last
        }
    }
    
    // 选择下一个历史记录
    private func selectNextHistory() {
        guard !historyManager.historyEntries.isEmpty else { return }
        
        guard let currentHistory = selectedHistory,
              let currentIndex = historyManager.historyEntries.firstIndex(of: currentHistory) else {
            selectedHistory = historyManager.historyEntries.first
            return
        }
        
        if currentIndex < historyManager.historyEntries.count - 1 {
            selectedHistory = historyManager.historyEntries[currentIndex + 1]
        } else {
            selectedHistory = historyManager.historyEntries.first
        }
    }
    
    // 格式化日期
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // 删除当前选中的历史记录
    private func deleteCurrentHistory() {
        guard let selectedHistory = selectedHistory else { return }
        deleteSelectedHistory(selectedHistory)
    }
    
    // 删除指定历史记录
    private func deleteSelectedHistory(_ historyToDelete: HistoryEntry) {
        // 验证条目是否存在
        guard historyManager.historyEntries.contains(historyToDelete) else { return }
        
        // 记录当前索引以便选择下一个条目
        let currentIndex = historyManager.historyEntries.firstIndex(of: historyToDelete)
        
        // 异步执行删除操作
        DispatchQueue.global().async {
            historyManager.deleteHistory(historyToDelete)
        }
        
        // 立即在主线程更新UI
        // 从列表中移除该条目，以便UI立即响应
        if let index = currentIndex {
            historyManager.historyEntries.remove(at: index)
        }
        
        // 智能选择下一个条目
        if self.historyManager.historyEntries.isEmpty {
            self.selectedHistory = nil
        } else if let index = currentIndex {
            // 如果删除的是最后一个元素，且列表不为空，则选择新的最后一个元素
            if index >= self.historyManager.historyEntries.count && !self.historyManager.historyEntries.isEmpty {
                self.selectedHistory = self.historyManager.historyEntries.last
            } 
            // 如果删除的不是最后一个元素，则选择原来的下一个元素（现在是当前索引的元素）
            else if index < self.historyManager.historyEntries.count {
                self.selectedHistory = self.historyManager.historyEntries[index]
            } 
            // 如果删除了唯一的元素后列表为空，selectedHistory 已在上面设为 nil
            // 如果列表不为空，但由于某种原因索引无效（理论上不应发生），则选择第一个
            else if !self.historyManager.historyEntries.isEmpty {
                self.selectedHistory = self.historyManager.historyEntries.first
            }
        } else if !self.historyManager.historyEntries.isEmpty {
            // 如果 currentIndex 为 nil （例如，historyToDelete 不在数组中，尽管我们已经检查过），
            // 并且列表不为空，则选择第一个条目作为回退。
            self.selectedHistory = self.historyManager.historyEntries.first
        }
    }
    
    // 检查历史记录是否已收藏
    private func isFavorited(_ historyEntry: HistoryEntry) -> Bool {
        return favoriteManager.favoriteEntries.contains { favorite in
            favorite.inputContent == historyEntry.inputContent &&
            favorite.outputContent == historyEntry.outputContent
        }
    }
    
    // 切换收藏状态
    private func toggleFavorite(_ historyEntry: HistoryEntry) {
        let inputContent = historyEntry.inputContent ?? ""
        let outputContent = historyEntry.outputContent ?? ""
        
        if isFavorited(historyEntry) {
            // 取消收藏
            if let favoriteToRemove = favoriteManager.favoriteEntries.first(where: { favorite in
                favorite.inputContent == inputContent &&
                favorite.outputContent == outputContent
            }) {
                favoriteManager.deleteFavorite(favoriteToRemove)
            }
        } else {
            // 添加收藏
            favoriteManager.addFavorite(inputContent: inputContent, outputContent: outputContent)
        }
    }
}
