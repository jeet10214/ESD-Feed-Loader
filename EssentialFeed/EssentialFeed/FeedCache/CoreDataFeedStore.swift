//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 13/04/25.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    
    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "FeedStore", in: bundle)
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionsCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionsCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private extension NSPersistentContainer {
    
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        
        try loadError.map { error in
            throw LoadingError.failedToLoadPersistentStores(error)
        }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

// The below code is generate by xcode as we have selected codeGen option of xcode
//private class ManagedCache: NSManagedObject {
//    @NSManaged var timestamp: Date
//    @NSManaged var feed: NSOrderedSet
//}
//
//private class ManagedFeedCache: NSManagedObject {
//    @NSManaged var id: UUID
//    @NSManaged var imageDiscription: String?
//    @NSManaged var location: String?
//    @NSManaged var url: URL
//    @NSManaged var cache: ManagedCache
//}
