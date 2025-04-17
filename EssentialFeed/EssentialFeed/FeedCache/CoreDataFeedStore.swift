//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 13/04/25.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func deleteCachedFeed(completion: @escaping DeletionsCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionsCompletion) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
}

private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedCache: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDiscription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
