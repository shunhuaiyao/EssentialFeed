//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/31.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static let OK_200: Int = 200
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else { throw RemoteFeedLoader.Error.invalidData }
        return root.items
    }
}
