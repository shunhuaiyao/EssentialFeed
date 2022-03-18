//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/27.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
