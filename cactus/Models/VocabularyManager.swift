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
    /// 基于艾宾浩斯遗忘曲线理论，筛选出需要复习的单词
    /// 算法逻辑：检查每个单词的nextReviewDate，如果为空或已到期则需要复习
    func getWordsForReview() -> [WordEntry] {
        let request: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        let now = Date()
        
        // 获取所有单词，然后筛选需要复习的
        do {
            let allWords = try context.fetch(request)
            return allWords.filter { word in
                // 算法判断1：如果从未复习过（nextReviewDate为nil），则需要复习
                // 这确保了新添加的单词会立即进入复习队列
                guard let nextReviewDate = word.nextReviewDate else {
                    return true
                }
                // 算法判断2：如果当前时间已达到或超过预定复习时间，则需要复习
                // 这是间隔重复算法的核心：按计算出的时间间隔进行复习
                return now >= nextReviewDate
            }
        } catch {
            print("获取复习单词失败: \(error)")
            return []
        }
    }
    
    /// 更新单词的复习状态
    /// 实现基于艾宾浩斯遗忘曲线的间隔重复算法（Spaced Repetition System, SRS）
    /// 算法核心：根据记忆效果动态调整复习间隔和难度系数
    /// - Parameters:
    ///   - word: 要更新的单词
    ///   - remembered: 是否记住了（true: 记得, false: 不记得）
    func updateWordReviewStatus(_ word: WordEntry, remembered: Bool) {
        let now = Date()
        word.lastReviewDate = now
        word.reviewCount += 1
        
        if remembered {
            // 算法分支1：记住单词时，采用递增间隔策略
            if word.reviewCount == 1 {
                // 第一次复习：间隔设为1天
                // 艾宾浩斯理论：初次学习后24小时内遗忘率最高
                word.interval = 1
            } else if word.reviewCount == 2 {
                // 第二次复习：间隔设为6天
                // 基于经验值，第二次复习间隔适中，巩固记忆
                word.interval = 6
            } else {
                // 第三次及以后：使用艾宾浩斯公式计算间隔
                // 公式：新间隔 = 旧间隔 × 难度系数（easeFactor）
                // 这确保了熟练掌握的单词复习间隔越来越长
                let newInterval = Int32(Float(word.interval) * word.easeFactor)
                // 保证间隔至少增加1天，避免间隔停滞
                word.interval = max(newInterval, word.interval + 1)
            }
            
            // 难度系数调整：记住单词时增加0.1
            // 范围控制：最小值1.3，确保间隔不会无限增长
            // 增加难度系数意味着下次间隔会更长
            word.easeFactor = max(1.3, word.easeFactor + 0.1)
        } else {
            // 算法分支2：忘记单词时，采用重置策略
            // 间隔重置为1天：立即安排复习，强化记忆
            word.interval = 1
            // 难度系数降低0.2：下次即使记住，间隔增长也会更慢
            // 最小值1.3：防止难度系数过低导致复习过于频繁
            word.easeFactor = max(1.3, word.easeFactor - 0.2)
        }
        
        // 计算下次复习时间：当前时间 + 间隔天数
        // 这是SRS算法的最终输出：确定具体的复习时间点
        let nextReviewDate = Calendar.current.date(byAdding: .day, value: Int(word.interval), to: now) ?? now
        word.nextReviewDate = nextReviewDate
        
        saveContext()
    }
    
    /// 获取随机单词用于抽查
    /// 从所有单词中随机选择最多20个单词进行复习
    /// - Returns: 随机选择的单词数组，最多20个
    func getRandomWordsForQuiz() -> [WordEntry] {
        let request: NSFetchRequest<WordEntry> = WordEntry.fetchRequest()
        
        do {
            let allWords = try context.fetch(request)
            let shuffledWords = allWords.shuffled()
            return Array(shuffledWords.prefix(20))
        } catch {
            print("获取随机单词失败: \(error)")
            return []
        }
    }
    
    /// 初始化新单词的复习参数
    /// 为新添加的单词设置艾宾浩斯算法的初始参数
    /// 算法初始化：建立单词的记忆追踪基线
    private func initializeReviewParameters(for word: WordEntry) {
        if word.nextReviewDate == nil {
            // 复习次数初始化为0：表示尚未开始复习循环
            word.reviewCount = 0
            // 难度系数初始化为2.5：这是SRS算法的标准初始值
            // 2.5意味着如果记住单词，下次间隔会是当前间隔的2.5倍
            word.easeFactor = 2.5
            // 初始间隔设为1天：新单词需要快速复习以建立初步记忆
            word.interval = 1
            // 下次复习时间设为当前时间：新单词立即可以复习
            // 这确保新单词会出现在复习队列中
            word.nextReviewDate = Date()
        }
    }
}
