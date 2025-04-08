//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 11/09/24.
//

import Foundation

public enum HTTPClientResult {
    case success(data: Data, response: HTTPURLResponse)
    case failure(error: Error)
}

public protocol HTTPClient {
    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
