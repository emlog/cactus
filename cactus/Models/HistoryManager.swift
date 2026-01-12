import Foundation
import CoreData

class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "CoreDataModel")
        
        guard let privateStoreDescription = container.persistentStoreDescriptions.first else {
            fatalError("###<persistentContainer>: Failed to get a persistent store description.")
        }
        
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        privateStoreDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { storeDescription, error in
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
    
    @Published var historyEntries: [HistoryEntry] = []
    
    private init() {
        fetchHistoryEntries()
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
    
    /// 添加历史记录
    /// 使用后台context处理保存操作,避免阻塞主线程
    /// - Parameters:
    ///   - inputContent: 输入内容
    ///   - outputContent: 输出内容
    func addHistory(inputContent: String, outputContent: String) {
        // 使用后台context处理保存操作,避免阻塞主线程
        let backgroundContext = persistentContainer.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        backgroundContext.perform {
            // 在后台context中创建新条目
            let newEntry = HistoryEntry(context: backgroundContext)
            newEntry.inputContent = inputContent
            newEntry.outputContent = outputContent
            newEntry.timestamp = Date()
            
            do {
                try backgroundContext.save()
                // 保存成功后在主线程更新UI
                DispatchQueue.main.async {
                    self.fetchHistoryEntries()
                }
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    func deleteHistory(_ historyEntry: HistoryEntry) {
        context.delete(historyEntry)
        saveContext()
    }
    
    func clearAllHistory() {
        let request: NSFetchRequest<NSFetchRequestResult> = HistoryEntry.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
            fetchHistoryEntries()
        } catch {
            print("Clear history error: \(error)")
        }
    }
    
    func fetchHistoryEntries() {
        let request: NSFetchRequest<HistoryEntry> = HistoryEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \HistoryEntry.timestamp, ascending: false)]
        
        do {
            historyEntries = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }
}