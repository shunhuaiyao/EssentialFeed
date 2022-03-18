//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/3/18.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
