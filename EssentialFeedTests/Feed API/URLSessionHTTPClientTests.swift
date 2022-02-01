//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Sean Yao on 2022/2/1.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_getFromURL_resumeDataTaskWithURL() throws {
        let url = URL(string: "https://any-url.com")!
        // TODO: fix warning that init method was deprecated
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url) { _ in }
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() throws {
        let url = URL(string: "https://any-url.com")!
        // TODO: fix warning that init method was deprecated
        let session = URLSessionSpy()
        let error = NSError(domain: "any error", code: 1)
        session.stub(url: url, error: error)
        let sut = URLSessionHTTPClient(session: session)
        
        let exp = expectation(description: "wait for completion")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected failure with error \(error), got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private class URLSessionSpy: URLSession {
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: NSError?
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            // TODO: fix warning that init method was deprecated
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub from \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        // TODO: fix warning that init method was deprecated
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: NSError? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {
        override func resume() {}
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask {
        var resumeCallCount: Int = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
