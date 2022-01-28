//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sean Yao on 2022/1/27.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_init() throws {
        let (client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() throws {
        let url = URL(string: "https://www.google.com.tw/")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() throws {
        let url = URL(string: "https://www.google.com.tw/")!
        let (client, sut) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() throws {
        let (client, sut) = makeSUT()
        
        var capturedErrors: [RemoteFeedLoader.Error] = []
        sut.load { result in
            switch result {
            case .failure(let error):
                capturedErrors.append(error)
            default:
                break
            }
        }
        client.complete(with: .connectivity)
        
        XCTAssertEqual(capturedErrors, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() throws {
        let (client, sut) = makeSUT()
                
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, sample in
            var capturedErrors: [RemoteFeedLoader.Error] = []
            sut.load { result in
                switch result {
                case .failure(let error):
                    capturedErrors.append(error)
                default:
                    break
                }
            }
            client.complete(withStatusCode: sample, at: index)
            XCTAssertEqual(capturedErrors, [.invalidData])
        }
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com.tw/")!) -> (client: HTTPClientSpy, sut: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (client, sut)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: RemoteFeedLoader.Error, at index: Int = .zero) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, at index: Int = .zero) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(response))
        }
    }
}
