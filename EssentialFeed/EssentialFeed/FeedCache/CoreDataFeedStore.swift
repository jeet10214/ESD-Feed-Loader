//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 13/04/25.
//

import Foundation

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
