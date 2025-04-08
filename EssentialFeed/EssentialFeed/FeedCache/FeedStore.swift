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
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionsCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionsCompletion)
    
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping RetrievalCompletion)
}


