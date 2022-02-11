//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sean Yao on 2022/2/11.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCallCount: Int = 0
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() throws {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, .zero)
    }
    
    func test_save_requestsCacheDeletion() throws {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    // MARK: - Helpers
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: nil, location: nil, imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        URL(string: "https://any-url.com")!
    }
}
