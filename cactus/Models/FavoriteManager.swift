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
    
    /// 获取所有收藏数据用于导出
    func getAllFavoritesForExport() -> [[String: Any]] {
        let request: NSFetchRequest<FavoriteEntry> = FavoriteEntry.fetchRequest()
        do {
            let entries = try context.fetch(request)
            return entries.map { entry in
                var dict: [String: Any] = [:]
                dict["inputContent"] = entry.inputContent
                dict["outputContent"] = entry.outputContent
                dict["timestamp"] = entry.timestamp?.timeIntervalSince1970
                return dict
            }
        } catch {
            return []
        }
    }
    
    /// 从导出的数据导入收藏
    func importFavorites(from data: [[String: Any]]) {
        for dict in data {
            guard let inputContent = dict["inputContent"] as? String else { continue }
            
            let request: NSFetchRequest<FavoriteEntry> = FavoriteEntry.fetchRequest()
            request.predicate = NSPredicate(format: "inputContent == %@", inputContent)
            
            do {
                let existingEntries = try context.fetch(request)
                let entry: FavoriteEntry
                if let existing = existingEntries.first {
                    entry = existing
                } else {
                    entry = FavoriteEntry(context: context)
                }
                
                entry.inputContent = inputContent
                entry.outputContent = dict["outputContent"] as? String ?? ""
                if let ts = dict["timestamp"] as? TimeInterval {
                    entry.timestamp = Date(timeIntervalSince1970: ts)
                }
                
            } catch {
                print("Import favorite error: \(error)")
            }
        }
        saveContext()
        fetchFavoriteEntries()
    }
}
