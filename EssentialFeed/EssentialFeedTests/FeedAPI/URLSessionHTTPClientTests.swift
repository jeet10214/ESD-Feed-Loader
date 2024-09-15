//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Jeet Kapadia on 15/09/24.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { data, response, error in
            
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getfromURL_createDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session  = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLs, [url])
    }
    
    func test_getfromURL_resumesDataTaskWithURL() {
        let url = URL(string: "https://a-url.com")!
        let session  = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    // MARK: HELPER
    
    private class URLSessionSpy: URLSession {
        var receivedURLs: [URL] = []
        private var stubs: [URL: URLSessionDataTask] = [:]
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, (any Error)?) -> Void) -> URLSessionDataTask {
            receivedURLs.append(url)
            return stubs[url] ?? FakeURLSessionDataTask()
        }
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
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
