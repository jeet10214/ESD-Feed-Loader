//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Jeet Kapadia on 23/01/25.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deletedCachedFeedCallCount = 0
    
    func deleteCachedFeed() {
        deletedCachedFeedCallCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed()
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deletedCachedFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items: [FeedItem] = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deletedCachedFeedCallCount, 1)
    }
    
    //MARK: Helpers
    private func makeSUT() -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any description", location: "any location", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
}
