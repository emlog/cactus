import Foundation
import CoreData

class FavoriteManager: ObservableObject {
    static let shared = FavoriteManager()
    
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
    
    @Published var favoriteEntries: [FavoriteEntry] = []
    
    private init() {
        fetchFavoriteEntries()
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
    
    func addFavorite(inputContent: String, outputContent: String) {
        let isPremium = PurchaseManager.shared.isPremiumUser
        
        // 检查是否已存在相同的输入内容
        let request: NSFetchRequest<FavoriteEntry> = FavoriteEntry.fetchRequest()
        request.predicate = NSPredicate(format: "inputContent == %@", inputContent)
        
        do {
            let existingEntries = try context.fetch(request)
            if !existingEntries.isEmpty {
                // 如果已存在，更新输出内容和时间戳
                existingEntries.first?.outputContent = outputContent
                existingEntries.first?.timestamp = Date()
            } else {
                // 检查非高级用户的条目数量限制
                if !isPremium {
                    let countRequest: NSFetchRequest<FavoriteEntry> = FavoriteEntry.fetchRequest()
                    let currentCount = try context.count(for: countRequest)
                    if currentCount >= 50 {
                        print("Non-premium users can only save up to 50 favorite entries")
                        return
                    }
                }
                
                // 创建新条目
                let newEntry = FavoriteEntry(context: context)
                newEntry.inputContent = inputContent
                newEntry.outputContent = outputContent
                newEntry.timestamp = Date()
            }
            
            saveContext()
            fetchFavoriteEntries()
        } catch {
            print("Add favorite error: \(error)")
        }
    }
    
    func deleteFavorite(_ favoriteEntry: FavoriteEntry) {
        context.delete(favoriteEntry)
        saveContext()
    }
    
    func fetchFavoriteEntries() {
        let request: NSFetchRequest<FavoriteEntry> = FavoriteEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FavoriteEntry.timestamp, ascending: false)]
        
        do {
            favoriteEntries = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }
}
