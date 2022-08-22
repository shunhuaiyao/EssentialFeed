//
//  LoadFeedFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sean Yao on 2022/1/27.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

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
        
        expect(sut, toCompleteWith: failure(.connectivity)) {
            client.complete(with: .connectivity)
        }
    }
    
    func test_load_deliversErrorOnNon200HTTPResponse() throws {
        let (client, sut) = makeSUT()
                
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, sample in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let data = makeItemsData([])
                client.complete(withStatusCode: sample, data: data, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidData() throws {
        let (client, sut) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidData = Data("invalid data".utf8)
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }
    
    func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJsonList() throws {
        let (client, sut) = makeSUT()

        expect(sut, toCompleteWith: .success([])) {
            let emptyJsonData = makeItemsData([])
            client.complete(withStatusCode: 200, data: emptyJsonData)
        }
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithJsonItems() throws {
        let (client, sut) = makeSUT()
        let item1 = makeItem(id: UUID(), imageURL: URL(string: "https://a-url.com")!)
        let item2 = makeItem(id: UUID(), description: "a description", location: "a location", imageURL: URL(string: "https://another-url.com")!)
        let items = [item1.model, item2.model]
        
        expect(sut, toCompleteWith: .success(items)) {
            let itemsData = makeItemsData([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: itemsData)
        }
    }
    
    func test_load_doesNotDeliversResultAfterSUTInstanceHasBeenDeallocated() {
        let url = URL(string: "https://any-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults: [RemoteFeedLoader.Result] = []
        sut?.load { capturedResults.append($0) }
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsData([]))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://www.google.com.tw/")!, file: StaticString = #filePath, line: UInt = #line) -> (client: HTTPClientSpy, sut: RemoteFeedLoader) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (client, sut)
    }
    
    private func expect(_ sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult), instead")
            }
            exp.fulfill()
        }

        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: String]) {
        let item = FeedImage(
            id: id,
            description: description,
            location: location,
            url: imageURL
        )
        let json = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString
        ].compactMapValues { $0 }

        return (item, json)
    }
    
    private func makeItemsData(_ itemsJson: [[String: Any]]) -> Data {
        let json = [
            "items": itemsJson
        ]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: RemoteFeedLoader.Error, at index: Int = .zero) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data, at index: Int = .zero) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
