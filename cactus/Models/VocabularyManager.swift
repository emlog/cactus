import Foundation
import CoreData

class VocabularyManager: ObservableObject {
    static let shared = VocabularyManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "VocabularyModel") // 这里的 name 参数应该指向您的数据模型文件（ .xcdatamodeld 文件）的名称，而不是 iCloud 容器的标识符
        
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
                // 创建新条目
                let newEntry = WordEntry(context: context)
                newEntry.word = word
                newEntry.definition = definition
                newEntry.timestamp = Date()
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
        fetchWordEntries()
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
}
