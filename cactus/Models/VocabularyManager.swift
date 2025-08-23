import Foundation
import CoreData
import SwiftUI

class VocabularyManager: ObservableObject {
    static let shared = VocabularyManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "CoreDataModel") // 这里的 name 参数应该指向您的数据模型文件（ .xcdatamodeld 文件）的名称，而不是 iCloud 容器的标识符
        
        // Get the App Group store URL
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("###<persistentContainer>: Failed to get a persistent store description.")
        }
        // Enable history tracking and remote notifications
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // storeDescription is added
        container.loadPersistentStores { storeDescription, error in
            // Cast to NSError for more details
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @Published var wordEntries: [WordEntry] = []
    
    private init() {
        fetchWordEntries()
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func addWord(_ word: String, definition: String) {
        let isPremium = PurchaseManager.shared.isPremiumUser
        
        // 检查是否已存在
        let request: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        request.predicate = NSPredicate(format: "word == %@", word)
        
        do {
            let existingEntries = try context.fetch(request)
            if !existingEntries.isEmpty {
                // 如果已存在，更新时间戳
                existingEntries.first?.timestamp = Date()
                existingEntries.first?.definition = definition
            } else {
                // 检查非高级用户的条目数量限制
                if !isPremium {
                    let countRequest: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
                    let currentCount = try context.count(for: countRequest)
                    if currentCount >= 50 {
                        print("Non-premium users can only save up to 50 vocabulary entries")
                        return
                    }
                }
                
                // 创建新条目
                let newEntry = WordEntry(context: context)
                newEntry.word = word
                newEntry.definition = definition
                newEntry.timestamp = Date()
                // 初始化复习参数
                initializeReviewParameters(for: newEntry)
            }
            
            saveContext()
            fetchWordEntries()
        } catch {
            print("Add word error: \(error)")
        }
    }
    
    func deleteWord(_ wordEntry: WordEntry) {
        context.delete(wordEntry)
        saveContext()
    }
    
    func fetchWordEntries() {
        let request: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \WordEntry.timestamp, ascending: false)]
        
        do {
            wordEntries = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }
    
    // MARK: - 艾宾浩斯遗忘曲线相关方法
    
    /// 获取需要复习的单词
    func getWordsForReview() -> [WordEntry] {
        let request: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        let now = Date()
        
        // 获取所有单词，然后筛选需要复习的
        do {
            let allWords = try context.fetch(request)
            return allWords.filter { word in
                // 如果从未复习过，则需要复习
                guard let nextReviewDate = word.nextReviewDate else {
                    return true
                }
                // 如果到了复习时间，则需要复习
                return now >= nextReviewDate
            }
        } catch {
            print("获取复习单词失败: \(error)")
            return []
        }
    }
    
    /// 更新单词的复习状态
    /// - Parameters:
    ///   - word: 要更新的单词
    ///   - remembered: 是否记住了（true: 记得, false: 不记得）
    func updateWordReviewStatus(_ word: WordEntry, remembered: Bool) {
        let now = Date()
        word.lastReviewDate = now
        word.reviewCount += 1
        
        if remembered {
            // 记住了，增加间隔
            if word.reviewCount == 1 {
                word.interval = 1
            } else if word.reviewCount == 2 {
                word.interval = 6
            } else {
                // 使用艾宾浩斯公式：新间隔 = 旧间隔 × 难度系数
                let newInterval = Int32(Float(word.interval) * word.easeFactor)
                word.interval = max(newInterval, word.interval + 1)
            }
            
            // 调整难度系数（记住了就稍微增加难度系数）
            word.easeFactor = max(1.3, word.easeFactor + 0.1)
        } else {
            // 没记住，重置间隔并降低难度系数
            word.interval = 1
            word.easeFactor = max(1.3, word.easeFactor - 0.2)
        }
        
        // 计算下次复习时间
        let nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(word.interval), to: now) ?? now
        word.nextReviewDate = nextReviewDate
        
        saveContext()
    }
    
    /// 初始化新单词的复习参数
    private func initializeReviewParameters(for word: WordEntry) {
        if word.nextReviewDate == nil {
            word.reviewCount = 0
            word.easeFactor = 2.5
            word.interval = 1
            word.nextReviewDate = Date() // 新单词立即可以复习
        }
    }
}
