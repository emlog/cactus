//
//  ContentView.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/19.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedText: String = ""
    
    var body: some View {
        VStack {
            Text("选中文本:")
                .font(.headline)
            Text(selectedText)
                .padding()
            Button("翻译") {
                TranslationService.translate(text: selectedText) { result in
                    switch result {
                    case .success(let translation):
                        selectedText = translation
                    case .failure(let error):
                        print("翻译错误: \(error)")
                    }
                }
            }
        }
        .padding()
        .onAppear {
            // 获取选中的文本
            selectedText = ClipboardManager.getSelectedText()
        }
    }
}
