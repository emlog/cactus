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
    
    func addHistory(inputContent: String, outputContent: String) {
        // 检查是否已存在相同的输入内容
        let request: NSFetchRequest<HistoryEntry> = HistoryEntry.fetchRequest()
        request.predicate = NSPredicate(format: "inputContent == %@", inputContent)
        
        do {
            let existingEntries = try context.fetch(request)
            if !existingEntries.isEmpty {
                // 如果已存在，更新时间戳和输出内容
                existingEntries.first?.timestamp = Date()
                existingEntries.first?.outputContent = outputContent
            } else {
                // 创建新条目
                let newEntry = HistoryEntry(context: context)
                newEntry.inputContent = inputContent
                newEntry.outputContent = outputContent
                newEntry.timestamp = Date()
            }
            
            saveContext()
            fetchHistoryEntries()
        } catch {
            print("Add history error: \(error)")
        }
    }
    
    func deleteHistory(_ historyEntry: HistoryEntry) {
        context.delete(historyEntry)
        saveContext()
        fetchHistoryEntries()
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