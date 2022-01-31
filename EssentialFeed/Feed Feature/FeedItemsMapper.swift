//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/31.
//

import Foundation

final class FeedItemsMapper {
    private struct Root: Decodable {
        let items: [item]
    }

    private struct item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image
            )
        }
    }
    
    private static let OK_200: Int = 200
    
    static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
        guard response.statusCode == OK_200 else { throw RemoteFeedLoader.Error.invalidData }
        return try JSONDecoder().decode(Root.self, from: data).items.map { $0.item }
    }
}
