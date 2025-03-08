//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 08/03/25.
//


import Foundation

public protocol FeedStore: AnyObject {
    typealias DeletionsCompletion = (Error?) -> (Void)
    typealias InsertionsCompletion = (Error?) -> (Void)

    func deleteCachedFeed(completion: @escaping DeletionsCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionsCompletion)
}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
