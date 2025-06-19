//
//  cactus
//
//  生词本
//  Created by 许大伟 on 2025/2/21.
//

import SwiftUI
import CoreData
import MarkdownUI

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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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
                    .contextMenu {
                        Button(action: {
                            deleteSelectedWord(wordEntry)
                        }) {
                            Label(NSLocalizedString("delete", comment: "删除"), systemImage: "trash")
                        }
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
                    // 内容区域
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack(alignment: .topTrailing) {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 16) {
                                    // 单词定义
                                    Markdown(selectedWord.definition ?? "")
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
                                }
                                .padding(.horizontal, 12)
                                .padding(.top, 12)
                                .padding(.bottom, 20)
                            }
                            .background(Color(.textBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.separatorColor), lineWidth: 1)
                            )
                            
                            // 操作按钮 - 右上角
                            HStack(spacing: 8) {
                                Button(action: {
                                    speakWord(selectedWord.word ?? "")
                                }) {
                                    Image(systemName: "speaker.wave.2")
                                        .frame(width: 15, height: 15)
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(HoverButtonStyle(horizontalPadding: 4, verticalPadding: 4))
                                .disabled((selectedWord.word ?? "").isEmpty)
                                
                                // 删除按钮
                                Button(action: {
                                    deleteSelectedWord(selectedWord)
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
        .frame(minWidth: 800, minHeight: 800)
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
                
                Button("Delete") {
                    deleteCurrentWord()
                }
                .keyboardShortcut(.delete, modifiers: [])
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
    
    // 删除当前选中的单词
    private func deleteCurrentWord() {
        guard let selectedWord = selectedWord else { return }
        deleteSelectedWord(selectedWord)
    }
    
    // 删除指定单词
    private func deleteSelectedWord(_ wordToDelete: WordEntry) {
        // 验证条目是否存在
        guard vocabularyManager.wordEntries.contains(wordToDelete) else { return }
        
        // 记录当前索引以便选择下一个条目
        let currentIndex = vocabularyManager.wordEntries.firstIndex(of: wordToDelete)
        
        // 执行删除
        vocabularyManager.deleteWord(wordToDelete)
        
        // 智能选择下一个条目
        DispatchQueue.main.async {
            if self.vocabularyManager.wordEntries.isEmpty {
                self.selectedWord = nil
            } else if let index = currentIndex {
                // 选择下一个条目，如果是最后一个则选择前一个
                if index < self.vocabularyManager.wordEntries.count {
                    self.selectedWord = self.vocabularyManager.wordEntries[index]
                } else if index > 0 {
                    self.selectedWord = self.vocabularyManager.wordEntries[index - 1]
                } else {
                    self.selectedWord = self.vocabularyManager.wordEntries.first
                }
            }
        }
    }
}

// 为了支持通知，需要添加扩展
extension Notification.Name {
    static let upArrowPressed = Notification.Name("upArrowPressed")
    static let downArrowPressed = Notification.Name("downArrowPressed")
}
