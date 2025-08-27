//
//  StudyCardView.swift
//  cactus
//
//  背单词卡片视图
//  Created by AI Assistant on 2025/2/21.
//

import SwiftUI
import CoreData
import Foundation
import AVFoundation
import MarkdownUI

/// 背单词卡片视图
struct StudyCardView: View {
    let word: WordEntry
    let onRemembered: () -> Void
    let onForgotten: () -> Void
    let onClose: () -> Void
    let onNextWord: () -> Void
    
    @State private var showDefinition = false
    @State private var cardOffset: CGSize = .zero
    @State private var cardRotation: Double = 0
    @State private var hasForgotten = false // 跟踪是否已点击"不记得"按钮
    
    // 添加语音朗读相关状态
    @State private var isSpeaking = false
    private let speechService = SpeechService.shared
    
    var body: some View {
        ZStack {
            // 背景遮罩 - 适配黑暗模式
            Color.primary.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            // 卡片容器
            VStack(spacing: 0) {
                // 卡片内容
                cardContent
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                            .shadow(color: .primary.opacity(0.2), radius: 20, x: 0, y: 10)
                    )
                    .offset(cardOffset)
                    .rotationEffect(.degrees(cardRotation))
                    .scaleEffect(showDefinition ? 1.0 : 0.95)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showDefinition)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cardOffset)
            }
            .frame(maxWidth: 500, maxHeight: 400)
            .padding(.horizontal, 40)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                showDefinition = false
                hasForgotten = false
            }
            // 自动朗读单词
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speakWord(word.word ?? "")
            }
        }
    }
    
    /// 卡片内容区域
    private var cardContent: some View {
        VStack(spacing: 20) {
            // 关闭按钮
            HStack {
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
            
            // 单词显示区域
            VStack(spacing: 16) {
                // 单词文本
                HStack {
                    Text(word.word ?? "")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                HStack {
                    // 语音播放按钮
                    Button(action: {
                        speakWord(word.word ?? "")
                    }) {
                        Image(systemName: isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled((word.word ?? "").isEmpty)
                }
                
                // 点击查看释义链接
                if !showDefinition {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showDefinition = true
                        }
                    }) {
                        Text(NSLocalizedString("tap_to_show_definition", comment: "点击查看释义"))
                            .font(.body)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 8)
                }
                
                // 初始按钮区域 - 记得/不记得
                if !showDefinition {
                    initialButtonArea
                        .padding(.top, 20)
                }
                
                // 释义显示区域
                if showDefinition {
                    ScrollView {
                        Markdown(word.definition ?? "")
                            .markdownTheme(.cactusMD)
                            .textSelection(.enabled)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .padding(.horizontal, 12)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // 显示释义后的按钮区域
                    if hasForgotten {
                        // 如果已点击忘记，显示下一个按钮
                        nextButtonArea
                            .padding(.top, 10)
                    } else {
                        // 如果是点击显示释义，显示忘记和记得按钮
                        definitionButtonArea
                            .padding(.top, 10)
                    }
                }
            }
            .frame(minHeight: 260)
            .padding(.horizontal, 20)
            .contentShape(Rectangle())
            
            Spacer(minLength: 10)
        }
    }
    
    /// 初始按钮区域（记得/不记得）
    private var initialButtonArea: some View {
        HStack(spacing: 20) {
            // 不记得按钮
            Button(action: {
                // 记录"不记得"状态
                onForgotten()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    showDefinition = true
                    hasForgotten = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .font(.title3)
                    Text(NSLocalizedString("forgot", comment: "不记得"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.red)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 记得按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cardOffset = CGSize(width: 200, height: 0)
                    cardRotation = 15
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onRemembered()
                    // 重置卡片状态以显示下一个单词
                    resetCardState()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                    Text(NSLocalizedString("remembered", comment: "记得"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.accentColor)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cardOffset)
    }
    
    /// 显示释义后的按钮区域（忘记/记得）
    private var definitionButtonArea: some View {
        HStack(spacing: 20) {
            // 忘记按钮
            Button(action: {
                onForgotten()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    hasForgotten = true
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "xmark.circle")
                        .font(.title3)
                    Text(NSLocalizedString("forgot", comment: "忘记"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.red)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // 记得按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    cardOffset = CGSize(width: 200, height: 0)
                    cardRotation = 15
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onRemembered()
                    // 重置卡片状态以显示下一个单词
                    resetCardState()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                    Text(NSLocalizedString("remembered", comment: "记得"))
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.accentColor)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: cardOffset)
    }
    
    /// 下一个按钮区域
    private var nextButtonArea: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
                cardOffset = CGSize(width: -200, height: 0)
                cardRotation = -15
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onNextWord()
                // 重置卡片状态以显示下一个单词
                resetCardState()
            }
        }) {
            HStack(spacing: 8) {
                Text(NSLocalizedString("next_word", comment: "下一个"))
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
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    
    
    /// 语音播放功能
    private func speakWord(_ word: String) {
        guard !word.isEmpty else { return }
        
        // 防止重复播放：如果正在播放，先停止
        if isSpeaking {
            speechService.stopSpeaking()
        }
        
        isSpeaking = true
        speechService.speak(word, speechLanguageCode: "en-US")
        
        // 设置一个定时器来重置speaking状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isSpeaking = false
        }
    }
    
    /// 重置卡片状态以显示下一个单词
    private func resetCardState() {
        withAnimation(.easeOut(duration: 0.3)) {
            cardOffset = .zero
            cardRotation = 0
            showDefinition = false
            hasForgotten = false
        }
        
        // 移除自动朗读，避免重复播放
        // 新单词的朗读将由onAppear处理
    }
}
