//
//  FavoriteView.swift
//  cactus
//
//  收藏夹
//  Created by 许大伟 on 2025/2/21.
//

import SwiftUI
import CoreData
import MarkdownUI

struct FavoriteView: View {
    @ObservedObject private var favoriteManager = FavoriteManager.shared
    @State private var selectedFavorite: FavoriteEntry?
    @FocusState private var isViewFocused: Bool
    
    // 复制成功状态，用于按钮图标动画
    @State private var showInputCopySuccess = false
    @State private var showOutputCopySuccess = false
    
    var body: some View {
        HSplitView {
            // 左侧收藏列表 - 占比约30%
            VStack(spacing: 0) {
                List(favoriteManager.favoriteEntries, id: \.objectID) { favoriteEntry in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(getPreviewText(favoriteEntry.inputContent ?? ""))
                            .font(.system(size: 14, weight: .medium))
                            .lineSpacing(4)
                            .lineLimit(2)
                        
                        Text(formatDate(favoriteEntry.timestamp))
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
                            .fill(selectedFavorite?.objectID == favoriteEntry.objectID
                                  ? Color.accentColor.opacity(0.2)
                                  : Color.clear)
                            .padding(.vertical, 0)
                    )
                    .onTapGesture {
                        selectedFavorite = favoriteEntry
                    }
                    .contextMenu {
                        Button(action: {
                            deleteSelectedFavorite(favoriteEntry)
                        }) {
                            Label(NSLocalizedString("delete", comment: "删除"), systemImage: "trash")
                        }
                    }
                }
                .listStyle(PlainListStyle())
                
                // 底部显示总收藏数量
                HStack {
                    Text(NSLocalizedString("sum", comment: "共计") + "： \(favoriteManager.favoriteEntries.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 180, idealWidth: 220, maxWidth: 280)
            
            // 右侧收藏详情 - 占比约70%
            VStack(spacing: 0) {
                if let selectedFavorite = selectedFavorite {
                    VStack(spacing: 12) {
                        // 输入内容区域
                        VStack(alignment: .leading, spacing: 8) {
                            ZStack(alignment: .bottomTrailing) {
                                ScrollView {
                                    Text(selectedFavorite.inputContent ?? "")
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
                                        copyToClipboard(selectedFavorite.inputContent ?? "")
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
                                        deleteSelectedFavorite(selectedFavorite)
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
                                    Markdown(selectedFavorite.outputContent ?? "")
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
                                        copyToClipboard(selectedFavorite.outputContent ?? "")
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
                    selectPreviousFavorite()
                }
                .keyboardShortcut(.upArrow, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
                
                Button("Next") {
                    selectNextFavorite()
                }
                .keyboardShortcut(.downArrow, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
                
                Button("Delete") {
                    deleteCurrentFavorite()
                }
                .keyboardShortcut(.delete, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
            }
        )
        .onAppear {
            favoriteManager.fetchFavoriteEntries()
            // 默认选择第一个收藏
            if selectedFavorite == nil && !favoriteManager.favoriteEntries.isEmpty {
                selectedFavorite = favoriteManager.favoriteEntries.first
            }
            // 设置焦点以接收键盘事件
            isViewFocused = true
        }
        .onChange(of: favoriteManager.favoriteEntries) { newEntries in
            // 当收藏列表更新时，如果没有选中的收藏且列表不为空，则选择第一个
            if selectedFavorite == nil && !newEntries.isEmpty {
                selectedFavorite = newEntries.first
            }
            // 如果当前选中的收藏不在新列表中，则重新选择第一个
            if let selected = selectedFavorite, !newEntries.contains(selected) {
                selectedFavorite = newEntries.first
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
    
    // 选择上一个收藏
    private func selectPreviousFavorite() {
        guard !favoriteManager.favoriteEntries.isEmpty else { return }
        
        guard let currentFavorite = selectedFavorite,
              let currentIndex = favoriteManager.favoriteEntries.firstIndex(of: currentFavorite) else {
            selectedFavorite = favoriteManager.favoriteEntries.last
            return
        }
        
        if currentIndex > 0 {
            selectedFavorite = favoriteManager.favoriteEntries[currentIndex - 1]
        } else {
            selectedFavorite = favoriteManager.favoriteEntries.last
        }
    }
    
    // 选择下一个收藏
    private func selectNextFavorite() {
        guard !favoriteManager.favoriteEntries.isEmpty else { return }
        
        guard let currentFavorite = selectedFavorite,
              let currentIndex = favoriteManager.favoriteEntries.firstIndex(of: currentFavorite) else {
            selectedFavorite = favoriteManager.favoriteEntries.first
            return
        }
        
        if currentIndex < favoriteManager.favoriteEntries.count - 1 {
            selectedFavorite = favoriteManager.favoriteEntries[currentIndex + 1]
        } else {
            selectedFavorite = favoriteManager.favoriteEntries.first
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
    
    // 删除当前选中的收藏
    private func deleteCurrentFavorite() {
        guard let selectedFavorite = selectedFavorite else { return }
        deleteSelectedFavorite(selectedFavorite)
    }
    
    // 删除指定收藏
    private func deleteSelectedFavorite(_ favoriteToDelete: FavoriteEntry) {
        // 执行删除
        favoriteManager.deleteFavorite(favoriteToDelete)
    }
}
