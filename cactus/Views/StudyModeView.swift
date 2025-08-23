//
//  StudyModeView.swift
//  cactus
//
//  背单词模式主视图
//  Created by AI Assistant on 2025/2/21.
//

import SwiftUI
import CoreData
import Foundation

/// 学习统计数据结构
struct StudyStats {
    var totalWords: Int = 0
    var completedCount: Int = 0
    var rememberedCount: Int = 0
    var forgottenCount: Int = 0
    
    var accuracy: Double {
        guard completedCount > 0 else { return 0 }
        return Double(rememberedCount) / Double(completedCount)
    }
}

/// 背单词模式视图
struct StudyModeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var vocabularyManager = VocabularyManager.shared
    @State private var wordsToReview: [WordEntry] = []
    @State private var currentWordIndex = 0
    @State private var showCard = false
    @State private var studyCompleted = false
    @State private var studyStats = StudyStats()
    

    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            if wordsToReview.isEmpty {
                noWordsView
            } else if studyCompleted {
                completionView
            } else {
                studyView
            }
        }
        .frame(width: 600, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay(
            // 卡片弹窗
            Group {
                if showCard && currentWordIndex < wordsToReview.count {
                    StudyCardView(
                        word: wordsToReview[currentWordIndex],
                        onRemembered: {
                            handleWordResult(remembered: true)
                        },
                        onForgotten: {
                            handleWordResult(remembered: false)
                        },
                        onClose: {
                            showCard = false
                        },
                        onNextWord: {
                            handleNextWord()
                        }
                    )
                    .zIndex(1)
                    .id("word_\(currentWordIndex)") // 使用字符串id确保视图更新时重新朗读
                }
            }
        )
        .onAppear {
            loadWordsForReview()
        }
    }
    
    /// 学习主界面
    private var studyView: some View {
        VStack(spacing: 30) {
            // 统计信息
            studyHeader
            
            Spacer()
            
            // 中央开始按钮区域
            VStack(spacing: 20) {
                // 开始学习按钮
                Button(action: {
                    showCard = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle")
                            .font(.title2)
                        Text(NSLocalizedString("start", comment: "开始学习"))
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.accentColor)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(showCard ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: showCard)
            }
            
            Spacer()
            
            // 底部进度信息
            studyProgress
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 10)
    }
    
    /// 标题栏视图 - 参考提示词库样式
    private var headerView: some View {
        HStack {
            Text(NSLocalizedString("study_mode", comment: "背单词"))
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
    
    /// 顶部统计信息
    private var studyHeader: some View {
        VStack(spacing: 16) {
            // 移除这里的标题，因为已经在headerView中显示了
            
            HStack(spacing: 30) {
                StatCard(
                    title: NSLocalizedString("total_words", comment: "总单词数"),
                    value: "\(studyStats.totalWords)",
                    icon: "book",
                    color: .blue
                )
                
                StatCard(
                    title: NSLocalizedString("remembered", comment: "记得单词数"),
                    value: "\(studyStats.rememberedCount)",
                    icon: "checkmark.circle",
                    color: .green
                )
                
                StatCard(
                    title: NSLocalizedString("forgot", comment: "不记得单词数"),
                    value: "\(studyStats.forgottenCount)",
                    icon: "xmark.circle",
                    color: .red
                )
            }
        }
    }
    
    /// 学习进度
    private var studyProgress: some View {
        VStack(spacing: 12) {
            // 进度条
            ProgressView(value: Double(currentWordIndex), total: Double(studyStats.totalWords))
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                .scaleEffect(y: 2)
            
            // 进度文本
            Text("\(currentWordIndex) / \(studyStats.totalWords)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
    
    /// 无单词需要复习界面
    private var noWordsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("暂无需要复习的单词")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("请先添加一些单词到词汇本")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
    
    /// 完成界面
    private var completionView: some View {
        VStack(spacing: 30) {
            // 完成图标
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            // 完成标题
            Text("学习完成！")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 统计信息卡片
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    StatCard(
                        title: "总单词数",
                        value: "\(studyStats.totalWords)",
                        icon: "book",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "已完成",
                        value: "\(studyStats.completedCount)",
                        icon: "checkmark.circle",
                        color: .green
                    )
                }
                
                HStack(spacing: 20) {
                    StatCard(
                        title: "记住了",
                        value: "\(studyStats.rememberedCount)",
                        icon: "brain",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "准确率",
                        value: String(format: "%.1f%%", studyStats.accuracy * 100),
                        icon: "target",
                        color: .purple
                    )
                }
            }
            .padding(.horizontal, 20)
            
            // 操作按钮
            HStack(spacing: 16) {
                Button("重新开始") {
                    resetStudySession()
                }
                .buttonStyle(.borderedProminent)
                
                Button("关闭") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
    
    // MARK: - 私有方法
    
    /// 加载需要复习的单词
    private func loadWordsForReview() {
        wordsToReview = vocabularyManager.getWordsForReview()
        studyStats.totalWords = wordsToReview.count
        currentWordIndex = 0
        studyCompleted = false
    }
    
    /// 处理单词学习结果
    private func handleWordResult(remembered: Bool) {
        guard currentWordIndex < wordsToReview.count else { return }
        
        let currentWord = wordsToReview[currentWordIndex]
        vocabularyManager.updateWordReviewStatus(currentWord, remembered: remembered)
        
        // 更新统计
        if remembered {
            studyStats.rememberedCount += 1
        } else {
            studyStats.forgottenCount += 1
        }
        studyStats.completedCount += 1
        
        // 如果是"记得"按钮，移动到下一个单词
        if remembered {
            // 移动到下一个单词
            currentWordIndex += 1
            
            // 检查是否完成所有单词
            if currentWordIndex >= wordsToReview.count {
                studyCompleted = true
                showCard = false
            } else {
                // 保持showCard = true，让卡片继续显示下一个单词
                // 通过改变id来强制重新创建StudyCardView，确保新单词被朗读
                showCard = true
            }
        }
        // 如果是"不记得"按钮，不移动到下一个单词，保持当前卡片显示以便查看释义
        // 用户需要点击"下一个单词"按钮来继续
    }
    
    /// 处理下一个单词按钮点击
    private func handleNextWord() {
        guard currentWordIndex < wordsToReview.count else { return }
        
        // 移动到下一个单词
        currentWordIndex += 1
        
        // 检查是否完成所有单词
        if currentWordIndex >= wordsToReview.count {
            studyCompleted = true
            showCard = false
        } else {
            // 保持showCard = true，通过id变化强制重新创建StudyCardView以触发朗读
            showCard = true
        }
    }
    
    /// 重置学习会话
    private func resetStudySession() {
        studyStats = StudyStats()
        loadWordsForReview()
    }
}

/// 统计卡片组件
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 140, height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
    }
}
