//
//  cactus
//
//  窗口：生词本
//  Created by 许大伟 on 2025/2/21.
//

import SwiftUI
import CoreData

struct VocabularyView: View {
    @ObservedObject private var vocabularyManager = VocabularyManager.shared
    @State private var selectedWord: WordEntry?
    @FocusState private var isViewFocused: Bool
    
    var body: some View {
        HSplitView {
            // 左侧单词列表 - 占比约20%
            VStack(spacing: 0) {
                List(vocabularyManager.wordEntries, id: \.objectID) { wordEntry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(wordEntry.word ?? "")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading) // 确保文本占据可用宽度
                            .padding(.vertical, 4) // 增加一些垂直内边距使点击区域更友好
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(selectedWord?.objectID == wordEntry.objectID ? Color.accentColor.opacity(0.2) : Color.clear)
                            )
                            .contentShape(Rectangle()) // 确保整个区域可点击
                            .onTapGesture {
                                selectedWord = wordEntry
                            }
                    }
                    .id(wordEntry.objectID) // 为VStack本身添加ID，增强稳定性
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selectedWord?.objectID == wordEntry.objectID ? Color.accentColor.opacity(0.2) : Color.clear)
                    )
                    .onTapGesture {
                        selectedWord = wordEntry
                    }
                }
                .listStyle(PlainListStyle())
                
                // 底部显示总单词数量
                HStack {
                    Text("共 \(vocabularyManager.wordEntries.count) 个单词")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 120, idealWidth: 120, maxWidth: 150)
            
            // 右侧单词详情 - 占比约80%
            VStack {
                if let selectedWord = selectedWord {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(selectedWord.word ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .textSelection(.enabled)
                        
                        ScrollView {
                            Text(selectedWord.definition ?? "")
                                .font(.body)
                                .lineSpacing(4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        // .fixedSize(horizontal: false, vertical: true) // 移除这一行
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            Button("删除") {
                                vocabularyManager.deleteWord(selectedWord)
                                // 删除后选择下一个单词，如果没有则选择第一个
                                if let currentIndex = vocabularyManager.wordEntries.firstIndex(of: selectedWord) {
                                    if currentIndex < vocabularyManager.wordEntries.count - 1 {
                                        self.selectedWord = vocabularyManager.wordEntries[currentIndex + 1]
                                    } else if !vocabularyManager.wordEntries.isEmpty && currentIndex > 0 {
                                        self.selectedWord = vocabularyManager.wordEntries[currentIndex - 1]
                                    } else {
                                        self.selectedWord = nil
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.regular)
                        }
                    }
                    .padding()
                } else {
                    VStack {
                        Spacer()
                        Text("选择一个单词查看详情")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .frame(minWidth: 400)
        }
        .frame(width: 600, height: 400)
        .focusable()
        .focused($isViewFocused)
        .overlay(
            // 隐藏的按钮用于键盘快捷键
            VStack {
                Button("Previous") {
                    selectPreviousWord()
                }
                .keyboardShortcut(.upArrow, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
                
                Button("Next") {
                    selectNextWord()
                }
                .keyboardShortcut(.downArrow, modifiers: [])
                .opacity(0)
                .allowsHitTesting(false)
            }
        )
        .onAppear {
            vocabularyManager.fetchWordEntries()
            // 默认选择第一个单词
            if selectedWord == nil && !vocabularyManager.wordEntries.isEmpty {
                selectedWord = vocabularyManager.wordEntries.first
            }
            // 设置焦点以接收键盘事件
            isViewFocused = true
        }
        .onChange(of: vocabularyManager.wordEntries) { newEntries in
            // 当单词列表更新时，如果没有选中的单词且列表不为空，则选择第一个
            if selectedWord == nil && !newEntries.isEmpty {
                selectedWord = newEntries.first
            }
            // 如果当前选中的单词不在新列表中，则重新选择第一个
            if let selected = selectedWord, !newEntries.contains(selected) {
                selectedWord = newEntries.first
            }
        }
    }
    
    private func selectPreviousWord() {
        guard !vocabularyManager.wordEntries.isEmpty else { return }
        
        guard let currentWord = selectedWord,
              let currentIndex = vocabularyManager.wordEntries.firstIndex(of: currentWord) else {
            selectedWord = vocabularyManager.wordEntries.last
            return
        }
        
        if currentIndex > 0 {
            selectedWord = vocabularyManager.wordEntries[currentIndex - 1]
        } else {
            selectedWord = vocabularyManager.wordEntries.last
        }
    }
    
    private func selectNextWord() {
        guard !vocabularyManager.wordEntries.isEmpty else { return }
        
        guard let currentWord = selectedWord,
              let currentIndex = vocabularyManager.wordEntries.firstIndex(of: currentWord) else {
            selectedWord = vocabularyManager.wordEntries.first
            return
        }
        
        if currentIndex < vocabularyManager.wordEntries.count - 1 {
            selectedWord = vocabularyManager.wordEntries[currentIndex + 1]
        } else {
            selectedWord = vocabularyManager.wordEntries.first
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 为了支持通知，需要添加扩展
extension Notification.Name {
    static let upArrowPressed = Notification.Name("upArrowPressed")
    static let downArrowPressed = Notification.Name("downArrowPressed")
}
