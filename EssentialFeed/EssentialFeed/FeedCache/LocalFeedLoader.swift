//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 08/03/25.
//
import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (Error?) -> Void) {
        store.insert(items, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return}
            completion(error)
        }
    }
}

public protocol FeedStore: AnyObject {
    typealias DeletionsCompletion = (Error?) -> (Void)
    typealias InsertionsCompletion = (Error?) -> (Void)

    func deleteCachedFeed(completion: @escaping DeletionsCompletion)
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionsCompletion)
}
