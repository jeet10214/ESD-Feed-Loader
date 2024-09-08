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
        
        expect(sut, toCompleteWithError: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.completeWithError(error: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200Response() {
        let (sut, client)  = makeSUT()
        
        let sampleCodes = [199, 201, 300, 400, 404, 500]
        sampleCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithError: .invalidData) {
                client.completeWithResponse(code: code, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200ResponseInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithError: .invalidData) {
            let invalidJson = Data("Inavlid Json".utf8)
            client.completeWithResponse(code: 200, jsonData: invalidJson)
        }
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithError error: RemoteFeedLoader.Error, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load { capturedError.append($0) }
        
        action()
        
        XCTAssertEqual(capturedError, [error], file: file, line: line)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        var completions: [(Error) -> Void] = []
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map({$0 .url})
        }
        
        func get(from url: URL, completion: @escaping(HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func completeWithError(error: Error, at index: Int = 0) {
            messages[0].completion(.failur(error: error))
        }
        
        func completeWithResponse(code: Int, jsonData: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data: jsonData, response: response))
        }
    }
    
}
