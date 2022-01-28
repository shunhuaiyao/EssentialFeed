//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Sean Yao on 2022/1/27.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
