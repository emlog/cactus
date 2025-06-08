//
//  cactus
//
//  生词本
//  Created by 许大伟 on 2025/2/21.
//

import SwiftUI
import CoreData

struct VocabularyView: View {
    @ObservedObject private var vocabularyManager = VocabularyManager.shared
    @State private var selectedWord: WordEntry?
    @FocusState private var isViewFocused: Bool
    
    // 添加语音朗读相关状态
    @State private var isSpeakingWord = false
    private let speechService = SpeechService.shared
    
    var body: some View {
        HSplitView {
            // 左侧单词列表 - 占比约20%
            VStack(spacing: 0) {
                List(vocabularyManager.wordEntries, id: \.objectID) { wordEntry in
                    VStack(alignment: .leading, spacing: 0) {
                        Text(wordEntry.word ?? "")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading) // 新增
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 0)
                            .fill(selectedWord?.objectID == wordEntry.objectID 
                                ? Color.accentColor.opacity(0.2) 
                                : Color.clear)
                            .padding(.vertical, 0)
                    )
                    .onTapGesture {
                        selectedWord = wordEntry
                    }
                }
                .listStyle(.plain)
                
                // 底部显示总单词数量
                HStack {
                    Text(NSLocalizedString("sum", comment: "共计") + "： \(vocabularyManager.wordEntries.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                    Spacer()
                }
                .background(Color(NSColor.controlBackgroundColor))
            }
            .frame(minWidth: 120, idealWidth: 120, maxWidth: 190)
            
            // 右侧单词详情 - 占比约80%
            VStack(spacing: 0) {
                if let selectedWord = selectedWord {
                    // 头部区域
                    VStack(alignment: .leading, spacing: 12) {
                        // 单词标题
                        Text(selectedWord.word ?? "")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .textSelection(.enabled)
                            .foregroundColor(.primary)
                        // 操作按钮区域
                        HStack(spacing: 12) {
                            Button(action: {
                                speakWord(selectedWord.word ?? "")
                            }) {
                                Label("", systemImage: "speaker.wave.2")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                            .disabled((selectedWord.word ?? "").isEmpty)
                            
                            Spacer()
                            
                            Button(action: {
                                vocabularyManager.deleteWord(selectedWord)
                                if let currentIndex = vocabularyManager.wordEntries.firstIndex(of: selectedWord) {
                                    if currentIndex < vocabularyManager.wordEntries.count - 1 {
                                        self.selectedWord = vocabularyManager.wordEntries[currentIndex + 1]
                                    } else if !vocabularyManager.wordEntries.isEmpty && currentIndex > 0 {
                                        self.selectedWord = vocabularyManager.wordEntries[currentIndex - 1]
                                    } else {
                                        self.selectedWord = nil
                                    }
                                }
                            }) {
                                Label("delete", systemImage: "trash")
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(HoverButtonStyle(horizontalPadding: 2, verticalPadding: 2))
                        }
                    }
                    .padding()
                    
                    // 细微的分隔线
                    Rectangle()
                        .fill(Color(NSColor.separatorColor).opacity(0.5))
                        .frame(height: 0.5)
                    
                    TextEditor(text: .constant(selectedWord.definition ?? ""))
                        .font(.body)
                        .lineSpacing(4)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(12) // 内边距
                        .background(
                            RoundedRectangle(cornerRadius: 0)
                                .fill(Color(NSColor.textBackgroundColor))
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                        )
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
        .onDisappear {
            // 窗口关闭时停止朗读
            stopSpeaking()
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
    
    // 添加朗读功能
    private func speakWord(_ word: String) {
        guard !word.isEmpty else { return }
        speechService.speak(word, langCode: "en-US")
    }
    
    private func stopSpeaking() {
        speechService.stopSpeaking()
        isSpeakingWord = false
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
