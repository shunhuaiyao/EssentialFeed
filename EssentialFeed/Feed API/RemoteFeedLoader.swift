//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/27.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

public enum HTTPClientResult {
    case success(HTTPURLResponse)
    case failure(RemoteFeedLoader.Error)
}

public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public func load(completion: @escaping (HTTPClientResult) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let response):
                if response.statusCode == 200 {
                    completion(.success(response))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
