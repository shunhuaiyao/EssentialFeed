//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sean Yao on 2022/2/11.
//

import XCTest

class FeedStore {
    var deleteCachedFeedCallCount: Int = 0
}

class LocalFeedLoader {
    let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() throws {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, .zero)
    }
}
