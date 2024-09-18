//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jeet Kapadia on 15/09/24.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error {
                completion(.failure(error: error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getfromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session  = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url, completion: { _ in })
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getfromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let session  = URLSessionSpy()
        let error = NSError(domain: "a error", code: 1)
        session.stub(url: url, error: error)
        
        let sut = URLSessionHTTPClient(session: session)
        let exp = expectation(description: "checking for error")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(error, receivedError)
            default:
                XCTFail("Expected failure with error \(error) got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: HELPER
    
    private class URLSessionSpy: URLSession {
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
               fatalError("Couldn't find stub with the specified \(url)")
            }
            completionHandler(nil, nil, stubs[url]?.error)
            return stub.task
        }
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
