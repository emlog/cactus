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
import AVFoundation
import MarkdownUI

/// 背单词模式视图
struct StudyModeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var vocabularyManager = VocabularyManager.shared
    @State private var wordsToReview: [WordEntry] = []
    @State private var currentWordIndex = 0
    @State private var showCard = false
    @State private var studyCompleted = false
    
    @State private var showConfetti = false
    @State private var isRandomQuiz = false
    
    /// 计算剩余待复习单词数
    private var remainingWordsCount: Int {
        return max(0, wordsToReview.count - currentWordIndex)
    }
    
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
                    title: NSLocalizedString("total_words", comment: "待复习单词数"),
                    value: "\(remainingWordsCount)",
                    icon: "book",
                    color: .blue
                )
            }
        }
    }
    
    /// 学习进度
    private var studyProgress: some View {
        VStack(spacing: 12) {
            // 进度条
            ProgressView(value: Double(currentWordIndex), total: Double(wordsToReview.count))
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                .scaleEffect(y: 2)
            
            // 进度文本
            Text("\(currentWordIndex) / \(wordsToReview.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
    
    /// 无单词需要复习界面
    private var noWordsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("no_words_to_review", comment: "暂无单词需要复习"))
                .font(.body)
                .foregroundColor(.secondary)
            
            // 随机抽查按钮
            Button(action: {
                startRandomQuiz()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "shuffle")
                        .font(.headline)
                    Text(NSLocalizedString("random_quiz", comment: "随机抽查"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.accentColor)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }
    
    /// 完成界面
    private var completionView: some View {
        ZStack {
            VStack(spacing: 30) {
                // 完成图标
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(showConfetti ? 1.2 : 1.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showConfetti)
                
                // 完成标题 - 彩色渐变
                Text(NSLocalizedString("study_completed", comment: "完成"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple, .blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(showConfetti ? 1.1 : 1.0)
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: showConfetti)
            }
            
            // 礼花效果
            if showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
        .onAppear {
            showConfetti = true
        }
    }
    
    // MARK: - 私有方法
    
    /// 加载需要复习的单词
    private func loadWordsForReview() {
        wordsToReview = vocabularyManager.getWordsForReview()
        currentWordIndex = 0
        studyCompleted = false
        isRandomQuiz = false // 重置随机抽查状态
    }
    
    /// 处理单词学习结果
    private func handleWordResult(remembered: Bool) {
        guard currentWordIndex < wordsToReview.count else { return }
        
        let currentWord = wordsToReview[currentWordIndex]
        vocabularyManager.updateWordReviewStatus(currentWord, remembered: remembered)
        
        // 不再需要统计正确率相关数据
        
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
        loadWordsForReview()
    }
    
    /// 开始随机复习
    /// 从所有单词中随机选择最多20个单词进行复习
    private func startRandomQuiz() {
        wordsToReview = vocabularyManager.getRandomWordsForQuiz()
        currentWordIndex = 0
        studyCompleted = false
        isRandomQuiz = true
        
        // 如果有单词可以抽查，直接开始学习
        if !wordsToReview.isEmpty {
            showCard = true
        }
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

/// 礼花庆祝效果视图
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces, id: \.id) { piece in
                Circle()
                    .fill(piece.color)
                    .frame(width: piece.size, height: piece.size)
                    .position(x: piece.x, y: piece.y)
                    .opacity(piece.opacity)
            }
        }
        .onAppear {
            generateConfetti()
            animateConfetti()
        }
    }
    
    /// 生成礼花粒子
    private func generateConfetti() {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink, .cyan]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                id: UUID(),
                x: Double.random(in: 0...600),
                y: -20,
                color: colors.randomElement() ?? .blue,
                size: Double.random(in: 4...12),
                opacity: 1.0
            )
            confettiPieces.append(piece)
        }
    }
    
    /// 动画礼花粒子
    private func animateConfetti() {
        withAnimation(.easeOut(duration: 3.0)) {
            for i in 0..<confettiPieces.count {
                confettiPieces[i].y = 450
                confettiPieces[i].x += Double.random(in: -100...100)
                confettiPieces[i].opacity = 0.0
            }
        }
    }
}

/// 礼花粒子数据结构
struct ConfettiPiece {
    let id: UUID
    var x: Double
    var y: Double
    let color: Color
    let size: Double
    var opacity: Double
}
