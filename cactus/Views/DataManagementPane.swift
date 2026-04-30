//
//  DataManagementPane.swift
//  cactus
//
//  Created by AI Assistant on 2025/3/10.
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct DataManagementPane: View {
    @State private var isImporting = false
    @State private var showImportConfirmation = false
    @State private var selectedFileURL: URL?
    
    // 吐司提示管理器
    @ObservedObject private var toastManager = ToastManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(NSLocalizedString("data_management", comment: "数据管理"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(NSLocalizedString("data_backup_description", comment: "数据备份描述"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        // 导出按钮
                        Button(action: {
                            print("DEBUG: Export button clicked")
                            exportData()
                        }) {
                            Label(NSLocalizedString("export_data", comment: "导出数据"), systemImage: "square.and.arrow.up")
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        // 导入按钮
                        Button(action: {
                            print("DEBUG: Import button clicked")
                            isImporting = true
                        }) {
                            Label(NSLocalizedString("import_data", comment: "导入数据"), systemImage: "square.and.arrow.down")
                                .frame(minWidth: 100)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                    .padding(.top, 10)
                }
                .padding(24)
                .background(Color(NSColor.gridColor))
                .cornerRadius(12)
                .padding(16)
                
                Spacer()
            }
        }
        .frame(width: 800, height: 680)
        .toast(toastManager)
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                print("DEBUG: File selected: \(urls)")
                if let url = urls.first {
                    self.selectedFileURL = url
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.showImportConfirmation = true
                    }
                }
            case .failure(let error):
                print("DEBUG: File selection failed: \(error.localizedDescription)")
                toastManager.showError(NSLocalizedString("import_failed", comment: "导入失败"))
            }
        }
        .alert(NSLocalizedString("confirm_import_title", comment: "确认导入"), isPresented: $showImportConfirmation) {
            Button(NSLocalizedString("confirm", comment: "确定"), role: .destructive) {
                if let url = selectedFileURL {
                    importData(from: url)
                }
            }
            Button(NSLocalizedString("cancel", comment: "取消"), role: .cancel) {}
        } message: {
            Text(NSLocalizedString("confirm_import_message", comment: "导入消息"))
        }
    }
    
    private func exportData() {
        // 导出操作
        let vocabularyData = VocabularyManager.shared.getAllWordsForExport()
        let favoriteData = FavoriteManager.shared.getAllFavoritesForExport()
        
        let exportDict: [String: Any] = [
            "version": "1.0",
            "exportDate": Date().timeIntervalSince1970,
            "vocabulary": vocabularyData,
            "favorites": favoriteData
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportDict, options: .prettyPrinted)
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [UTType.json]
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let dateString = formatter.string(from: Date())
            savePanel.nameFieldStringValue = "cactus_backup_\(dateString).json"
            
            savePanel.title = NSLocalizedString("export_data", comment: "导出数据")
            
            print("DEBUG: Running save panel modal")
            savePanel.begin { response in
                if response == .OK, let url = savePanel.url {
                    print("DEBUG: Saving to \(url)")
                    do {
                        try jsonData.write(to: url)
                        DispatchQueue.main.async {
                            self.toastManager.showSuccess(NSLocalizedString("export_success", comment: "导出成功"))
                        }
                    } catch {
                        print("DEBUG: Write error: \(error)")
                        DispatchQueue.main.async {
                            self.toastManager.showError(error.localizedDescription)
                        }
                    }
                } else {
                    print("DEBUG: Save panel cancelled or failed")
                }
            }
        } catch {
            print("DEBUG: Serialization error: \(error)")
        }
    }
    
    private func importData(from url: URL) {
        print("DEBUG: Importing from \(url)")
        guard url.startAccessingSecurityScopedResource() else {
            print("DEBUG: Access denied")
            toastManager.showError("Permission denied")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        do {
            let jsonData = try Data(contentsOf: url)
            guard let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                toastManager.showError(NSLocalizedString("import_failed", comment: "导入失败"))
                return
            }
            
            if let vocabularyData = dict["vocabulary"] as? [[String: Any]] {
                VocabularyManager.shared.importWords(from: vocabularyData)
            }
            
            if let favoriteData = dict["favorites"] as? [[String: Any]] {
                FavoriteManager.shared.importFavorites(from: favoriteData)
            }
            
            toastManager.showSuccess(NSLocalizedString("import_success", comment: "导入成功"))
        } catch {
            print("DEBUG: Import error: \(error)")
            toastManager.showError(NSLocalizedString("import_failed", comment: "导入失败"))
        }
    }
}
