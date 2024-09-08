//
//  RemoeFeedLoader.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 04/09/24.
//

import Foundation

public enum HTTPClientResult {
    case success(data: Data, response: HTTPURLResponse)
    case failur(error: Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
   
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping(Error) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let response):
                completion(.invalidData)
            case .failur(let error):
                completion(.connectivity)
            }
        }
    }
}


