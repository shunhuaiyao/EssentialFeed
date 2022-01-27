//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/27.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (RemoteFeedLoader.Result) -> Void)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Result {
        case failure(Error)
    }
    
    public enum Error {
        case connectivity
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (Result) -> Void = { _ in }) {
        client.get(from: url) { result in
            completion(result)
        }
    }
}
