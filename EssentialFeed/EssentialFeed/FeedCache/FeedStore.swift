//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 08/03/25.
//


import Foundation

public enum RetrieveCacheFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(error: Error)
}

public protocol FeedStore: AnyObject {
    typealias DeletionsCompletion = (Error?) -> (Void)
    typealias InsertionsCompletion = (Error?) -> (Void)
    typealias RetrievalCompletion = (RetrieveCacheFeedResult) -> (Void)
    
    func deleteCachedFeed(completion: @escaping DeletionsCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionsCompletion)
    func retrieve(completion: @escaping RetrievalCompletion)
}


