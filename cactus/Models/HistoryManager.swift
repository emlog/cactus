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
        // 直接创建新条目，不检查重复
        let newEntry = HistoryEntry(context: context)
        newEntry.inputContent = inputContent
        newEntry.outputContent = outputContent
        newEntry.timestamp = Date()
        
        saveContext()
        fetchHistoryEntries()
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