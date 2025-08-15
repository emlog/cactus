//
//  ChatMessageView.swift
//  cactus
//
//  Created by AI Assistant on 2024.
//

import SwiftUI
import Foundation
import MarkdownUI

/// 聊天消息数据模型
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    /// 初始化聊天消息
    /// - Parameters:
    ///   - content: 消息内容
    ///   - isUser: 是否为用户消息
    init(content: String, isUser: Bool) {
        self.content = content
        self.isUser = isUser
        self.timestamp = Date()
    }
}

/// 单个聊天消息视图组件
struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if message.isUser {
                // 用户消息：右对齐
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    // 消息内容
                    Text(message.content)
                        .textSelection(.enabled)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // 用户头像
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                    .frame(width: 20, height: 20)
                    .padding(.leading, 8)
            } else {
                // AI消息：左对齐
                // AI图标
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.green)
                    .font(.system(size: 16))
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    // 消息内容
                    Markdown(message.content)
                        .markdownTheme(.cactusMD)
                        .textSelection(.enabled)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 格式化时间戳
    /// - Parameter date: 要格式化的日期
    /// - Returns: 格式化后的时间字符串
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    VStack(spacing: 12) {
        ChatMessageView(message: ChatMessage(content: "你好，这是一条用户消息", isUser: true))
        ChatMessageView(message: ChatMessage(content: "你好！我是AI助手，很高兴为您服务。这是一条**Markdown**格式的回复。", isUser: false))
    }
    .padding()
}