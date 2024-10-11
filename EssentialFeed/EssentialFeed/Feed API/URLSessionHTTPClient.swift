//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Jeet Kapadia on 12/10/24.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error: error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data: data, response: response))
            }
            else {
                completion(.failure(error: UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
