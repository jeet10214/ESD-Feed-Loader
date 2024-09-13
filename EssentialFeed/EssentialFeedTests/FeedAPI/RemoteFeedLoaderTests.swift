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
        
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            let clientError = NSError(domain: "Test", code: 0)
            client.completeWithError(error: clientError)
        }
    }
    
    func test_load_deliversErrorOnNon200Response() {
        let (sut, client)  = makeSUT()
        
        let sampleCodes = [199, 201, 300, 400, 404, 500]
        sampleCodes.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemsJson([])
                client.completeWithResponse(code: code, jsonData: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200ResponseInvalidJson() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: failure(.invalidData)) {
            let invalidJson = Data("Inavlid Json".utf8)
            client.completeWithResponse(code: 200, jsonData: invalidJson)
        }
    }
    
    func test_load_deliversNoItemsOn200ResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWithResult: .success([])) {
            let validEmptyJson = makeItemsJson([])
            client.completeWithResponse(code: 200, jsonData: validEmptyJson)
        }
    }
    
    func test_load_deliversItemsOn200ResponseWithJSONItems() {
        let (sut, client) = makeSUT()
        
        let (item1, item1Json) = makeItem(id: UUID(),
                             imageURL: URL(string: "https://a-imageURL")!)
        
        let (item2, item2Json) = makeItem(id: UUID(),
                             description: "a description",
                             location: "a location",
                             imageURL: URL(string: "https://a-imageURL")!)
        
        expect(sut, toCompleteWithResult: .success([item1, item2])) {
            let json = makeItemsJson([item1Json, item2Json])
            client.completeWithResponse(code: 200, jsonData: json)
        }
    }
    
    func test_load_doesNotDeliverResultAfterClientInstanceHasBeenDeallocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedError = [RemoteFeedLoader.Result]()
        sut?.load {
            capturedError.append($0)
        }
        
        sut =  nil
        client.completeWithResponse(code: 200, jsonData: makeItemsJson([]))
        
        XCTAssertTrue(capturedError.isEmpty)
    }
    
    //MARK: HELPERS
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        return (sut, client)
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        if #available(macOS 10.15, *) {
            addTeardownBlock { [weak instance] in
                XCTAssertNil(instance, "Instance should have been nil. Potential Memory leak", file: file, line: line)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWithResult expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        
        var capturedError = [RemoteFeedLoader.Result]()
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedFailure as RemoteFeedLoader.Error), .failure(expectedFailure as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedFailure, expectedFailure, file: file, line: line)
            default:
                XCTFail("Expected Result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedItem, json: [String: Any]) {
        
        let item = FeedItem(id: id, description: description, location: location, imageURL: imageURL)
        
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString,
        ].compactMapValues {$0}
        
        return (item, json)
    }
    
    private func makeItemsJson(_ items: [[String: Any]]) -> Data {
        let itemsJson = [
            "items": items
        ]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
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
        
        func completeWithResponse(code: Int, jsonData: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success(data: jsonData, response: response))
        }
    }
    
}
