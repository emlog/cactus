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
                        .alert("确认清空", isPresented: $showClearAllConfirmation) {
                            Button("取消", role: .cancel) { }
                            Button("清空全部", role: .destructive) {
                                historyManager.clearAllHistory()
                                selectedHistory = nil
                            }
                        } message: {
                            Text("确定要清空所有历史记录吗？此操作无法撤销。")
                        }
                    }
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 180, idealWidth: 220, maxWidth: 280)
            
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
                                    
                                    // 删除按钮
                                    Button(action: {
                                        historyManager.deleteHistory(selectedHistory)
                                        // 删除后重新选择
                                        if let currentIndex = historyManager.historyEntries.firstIndex(of: selectedHistory) {
                                            if currentIndex < historyManager.historyEntries.count - 1 {
                                                self.selectedHistory = historyManager.historyEntries[currentIndex + 1]
                                            } else if !historyManager.historyEntries.isEmpty && currentIndex > 0 {
                                                self.selectedHistory = historyManager.historyEntries[currentIndex - 1]
                                            } else {
                                                self.selectedHistory = nil
                                            }
                                        }
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
                                        .markdownTheme(.gitHub)
                                        .markdownTextStyle(\.text) {
                                            FontSize(.em(0.95))
                                            ForegroundColor(.primary)
                                        }
                                        .markdownTextStyle(\.code) {
                                            FontFamilyVariant(.monospaced)
                                            FontSize(.em(0.85))
                                            ForegroundColor(.purple)
                                            BackgroundColor(.purple.opacity(0.1))
                                        }
                                        .markdownBlockStyle(\.codeBlock) { configuration in
                                            configuration.label
                                                .padding()
                                                .background(Color(.controlBackgroundColor))
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                        }
                                        .markdownBlockStyle(\.blockquote) { configuration in
                                            configuration.label
                                                .padding()
                                                .overlay(alignment: .leading) {
                                                    Rectangle()
                                                        .fill(Color.blue)
                                                        .frame(width: 4)
                                                }
                                                .background(Color.blue.opacity(0.1))
                                        }
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
        .frame(minWidth: 1000, minHeight: 800)
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
        .onChange(of: historyManager.historyEntries) { newEntries in
            // 当历史记录列表更新时，如果没有选中的记录且列表不为空，则选择第一个
            if selectedHistory == nil && !newEntries.isEmpty {
                selectedHistory = newEntries.first
            }
            // 如果当前选中的记录不在新列表中，则重新选择第一个
            if let selected = selectedHistory, !newEntries.contains(selected) {
                selectedHistory = newEntries.first
            }
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
}

#Preview {
    HistoryView()
}