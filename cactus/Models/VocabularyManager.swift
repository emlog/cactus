import Foundation
import CoreData

class VocabularyManager: ObservableObject {
    static let shared = VocabularyManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VocabularyModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
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