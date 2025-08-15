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
                        .background(Color.accentColor.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                // AI消息：左对齐
                // AI图标
                Image(systemName: "shareplay")
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
}