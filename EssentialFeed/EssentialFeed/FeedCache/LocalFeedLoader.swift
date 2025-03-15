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
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed.toLocal(), with: completion)
            }
        }
    }
    
    public func load() {
        store.load()
    }
    
    private func cache(_ feed: [LocalFeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return}
            completion(error)
        }
    }
}

extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        self.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
