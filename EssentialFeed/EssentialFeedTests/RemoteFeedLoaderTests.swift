//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Jeet Kapadia on 04/09/24.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client)  = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url =  URL(string: "https://a-given-url.com")!
        let (sut, client)  = makeSUT(url:url)
        
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url =  URL(string: "https://a-given-url.com")!
        let (sut, client)  = makeSUT(url:url)
        
        sut.load{ _ in }
        sut.load{ _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client)  = makeSUT()
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load{ capturedError.append($0) }
        
        let clientError = NSError(domain: "Test", code: 0)
        client.completeWithError(error: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var completions: [(Error) -> Void] = []
        
        var messages = [(url: URL, completion: (Error) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map({$0 .url})
        }
        
        func get(from url: URL, completion: @escaping(Error) -> Void) {
            messages.append((url, completion))
        }
        
        func completeWithError(error: Error, at index: Int = 0) {
            messages[0].completion(error)
        }
    }
    
}
